subroutine rapid_net_mat

!PURPOSE
!This subroutine is specific for RAPID connectivity tables.  
!Creates a sparse network matrix.  "1" is recorded at Net(i,j) if the reach 
!in column j flows into the reach in line i. If some connection are missing
!between the subbasin and the entire domain, gives warnings.  Also creates two 
!Fortran vectors that are useful for PETSc programming within this river routing 
!model (IV_riv_index,IV_riv_loc1).  
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_riv_tot,IS_riv_bas,                                      &
                   JS_riv_tot,JS_riv_bas,JS_riv_bas2,                          &
                   IV_riv_bas_id,IV_riv_index,IV_riv_loc1,                     &
                   rapid_connect_file,riv_bas_id_file,                         &
                   ZM_Net,ZM_A,BS_logical,IV_riv_tot_id,                       &
                   IV_down,IV_nbup,IM_up,JS_up,IM_index_up,                    &
                   ierr,rank,                                                  &
                   IS_one,ZS_one,temp_char,IV_nz,IV_dnz,IV_onz,                &
                   IS_ownfirst,IS_ownlast

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "finclude/petscsys.h"       
!base PETSc routines
#include "finclude/petscvec.h"  
#include "finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "finclude/petscmat.h"    
!matrices
#include "finclude/petscksp.h"    
!Krylov subspace methods
#include "finclude/petscpc.h"     
!preconditioners
#include "finclude/petscviewer.h"
!viewers (allows writing results in file for example)


!*******************************************************************************
!Read data files
!*******************************************************************************
open(10,file=rapid_connect_file,status='old')
do JS_riv_tot=1,IS_riv_tot
     read(10,*) IV_riv_tot_id(JS_riv_tot), IV_down(JS_riv_tot),                &
                IV_nbup(JS_riv_tot), IM_up(JS_riv_tot,:)
enddo
close(10)

open(11,file=riv_bas_id_file,status='old')
read(11,*) IV_riv_bas_id
close(11)


!*******************************************************************************
!Creates vectors with indexes for basin considered
!*******************************************************************************
do JS_riv_bas=1,IS_riv_bas
     IV_riv_loc1(JS_riv_bas)=JS_riv_bas-1
enddo
!vector with zero-base index corresponding to one-base index


do JS_riv_bas=1,IS_riv_bas
do JS_riv_tot=1,IS_riv_tot
     if (IV_riv_bas_id(JS_riv_bas)==IV_riv_tot_id(JS_riv_tot)) then
          IV_riv_index(JS_riv_bas)=JS_riv_tot
     end if 
end do
end do 
!vector with (Fortran, 1-based) indexes corresponding to reaches of basin 
!within whole network
!IV_riv_index has two advantages.  1) it is needed in order to read inflow  
!data (Vlat for ex).  2) It allows to avoid one other nested loop in the 
!following, which reduces tremendously the computation time.

!print *, IV_riv_loc1 
!print *, IV_riv_index 


!*******************************************************************************
!Matrix preallocation
!*******************************************************************************
IS_ownfirst=0
IS_ownlast=0
do JS_riv_bas=1,IS_riv_bas
     IV_nz(JS_riv_bas)=0
     IV_dnz(JS_riv_bas)=0
     IV_onz(JS_riv_bas)=0
end do
!Initialize to zero

call MatGetOwnerShipRange(ZM_Net,IS_ownfirst,IS_ownlast,ierr)

do JS_riv_bas=1,IS_riv_bas
do JS_riv_bas2=1,IS_riv_bas
do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))

if (IV_riv_tot_id(IV_riv_index(JS_riv_bas))==                                  &
    IM_up(IV_riv_index(JS_riv_bas2),JS_up)) then

     !Here JS_riv_bas is determined upstream of JS_riv_bas2
     IV_nz(JS_riv_bas2)=IV_nz(JS_riv_bas2)+1 
     if (JS_riv_bas>=IS_ownfirst+1 .and. JS_riv_bas < IS_ownlast+1) then
          IV_dnz(JS_riv_bas2)=IV_dnz(JS_riv_bas2)+1 
     else
          IV_onz(JS_riv_bas2)=IV_onz(JS_riv_bas2)+1 
     end if
     !both IS_riv_bas2 and IS_riv_bas are used here because the location
     !of nonzeros depends on row and column in an parallel matrix

     IM_index_up(JS_riv_bas2,JS_up)=JS_riv_bas
     !used for traditional Muskingum method

end if 

end do
end do
end do

call MatSeqAIJSetPreallocation(ZM_Net,PETSC_NULL_INTEGER,IV_nz,ierr)
call MatMPIAIJSetPreallocation(ZM_Net,                                         &
                               PETSC_NULL_INTEGER,                             &
                               IV_dnz(IS_ownfirst+1:IS_ownlast),               &
                               PETSC_NULL_INTEGER,                             &
                               IV_onz(IS_ownfirst+1:IS_ownlast),ierr)
call MatSeqAIJSetPreallocation(ZM_A,PETSC_NULL_INTEGER,IV_nz+1,ierr)
call MatMPIAIJSetPreallocation(ZM_A,                                           &
                               PETSC_NULL_INTEGER,                             &
                               IV_dnz(IS_ownfirst+1:IS_ownlast)+1,             &
                               PETSC_NULL_INTEGER,                             &
                               IV_onz(IS_ownfirst+1:IS_ownlast),ierr)

call PetscPrintf(PETSC_COMM_WORLD,'Network matrix preallocated'//char(10),ierr)


!*******************************************************************************
!Creates network matrix
!*******************************************************************************
if (rank==0) then
!only first processor sets values
do JS_riv_bas=1,IS_riv_bas
     if (IV_nbup(IV_riv_index(JS_riv_bas))/=0) then
          do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas))
               do JS_riv_bas2=1,IS_riv_bas

     if (  IM_up(IV_riv_index(JS_riv_bas),JS_up)==                             &
           IV_riv_tot_id(IV_riv_index(JS_riv_bas2))  ) then
          call MatSetValues(ZM_Net,IS_one,JS_riv_bas-1,IS_one,JS_riv_bas2-1,   &
                            ZS_one,INSERT_VALUES,ierr)
          CHKERRQ(ierr)
          call MatSetValues(ZM_A  ,IS_one,JS_riv_bas-1,IS_one,JS_riv_bas2-1,   &
                            ZS_one,INSERT_VALUES,ierr)
          CHKERRQ(ierr)
     end if

                end do
          enddo
     end if
call MatSetValues(ZM_A  ,IS_one,JS_riv_bas-1,IS_one,JS_riv_bas-1,              &
                  0*ZS_one,INSERT_VALUES,ierr)
CHKERRQ(ierr)
enddo
end if

call MatAssemblyBegin(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyBegin(ZM_A  ,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_A  ,MAT_FINAL_ASSEMBLY,ierr)
!sparse matrices need be assembled once their elements have been filled
call PetscPrintf(PETSC_COMM_WORLD,'Network matrix created'//char(10),ierr)


!*******************************************************************************
!Checks for missing connections and gives warning
!*******************************************************************************
do JS_riv_bas=1,IS_riv_bas
     do JS_riv_tot=1,IS_riv_tot
          if (IV_down(JS_riv_tot)==                                            &
              IV_riv_tot_id(IV_riv_index(JS_riv_bas))) then             
          !Within connectivity table, index JS_riv_tot has been determined as
          !Flowing into reach located at index JS_riv_bas.  The following is 
          !to check that the reach corresponding to JS_riv_tot is within the 
          !basin too. If not, gives a warning.
          BS_logical=.false.
          do JS_riv_bas2=1,IS_riv_bas
          BS_logical=( BS_logical .or.                                         &
                       (IV_riv_tot_id(JS_riv_tot)==IV_riv_bas_id(JS_riv_bas2)) )
          end do 
          if (.not. BS_logical) then
          write(temp_char,'(i10)') IV_riv_tot_id(JS_riv_tot)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           'WARNING: reach ID' // temp_char,ierr)
          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           ' should be connected upstream   of reach ID'       &
                           // temp_char // char(10),ierr)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           '         Make sure upstream forcing is available'  &
                           // char(10),ierr)
          end if 
          end if     

          if (IV_down(IV_riv_index(JS_riv_bas))==                              &
              IV_riv_tot_id(JS_riv_tot)) then             
          !Within connectivity table, index JS_riv_tot has been determined as
          !Flowing out of reach located at index JS_riv_bas.  The following is 
          !to check that the reach corresponding to JS_riv_tot is within the 
          !basin too. If not, gives a warning.
          BS_logical=.false.
          do JS_riv_bas2=1,IS_riv_bas
          BS_logical=( BS_logical .or.                                         &
                       (IV_riv_tot_id(JS_riv_tot)==IV_riv_bas_id(JS_riv_bas2)) )
          end do 
          if (.not. BS_logical) then
          write(temp_char,'(i10)') IV_riv_tot_id(JS_riv_tot)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           'WARNING: reach ID' // temp_char,ierr)
          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           ' should be connected downstream of reach ID'       &
                           // temp_char // char(10),ierr)
          end if 
               
     end if
end do
end do 
call PetscPrintf(PETSC_COMM_WORLD,'Checked for missing connections between '// &
                 'basin studied and rest of domain'//char(10),ierr)


!*******************************************************************************
!End
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)
!call PetscPrintf(PETSC_COMM_WORLD,'ZM_Net'//char(10),ierr)
!call MatView(ZM_Net,PETSC_VIEWER_STDOUT_WORLD,ierr)


end subroutine rapid_net_mat

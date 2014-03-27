subroutine rapid_obs_mat

!PURPOSE
!Creates a kronecker-type diagonal sparse matrix.  "1" is recorded at the line 
!and column where observations are available.  Calculates IS_gagebas.  Also 
!creates vectors IV_gage_index and IV_gage_loc
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_reachtot,JS_reachtot,IS_reachbas,JS_reachbas,            &
                   IS_gagetot,JS_gagetot,IS_gagebas,JS_gagebas,                &
                   nhdplus_connect_file,basin_id_file,gage_id_file,            &
                   IV_basin_id,IV_gage_id,IV_gage_index,IV_gage_loc,           &
                   ZM_Obs,ZS_norm,                                             &
                   ierr,                                                       &
                   IS_one,ZS_one,temp_char   

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "finclude/petsc.h"       
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
#include "finclude/tao_solver.h" 
!TAO solver


!*******************************************************************************
!Read data files
!*******************************************************************************
!open(11,file=nhdplus_connect_file,status='old')
!do JS_reachtot=1,IS_reachtot
!     read(11,'(4i12)') IV_connect_id(JS_reachtot), IV_fromnode(JS_reachtot),   &
!     read(11,*) IV_connect_id(JS_reachtot), IV_fromnode(JS_reachtot),   &
!                       IV_tonode(JS_reachtot), IV_diverg(JS_reachtot)
!enddo
!close(11)

open(15,file=basin_id_file,status='old')
!read(15,'(i12)') IV_basin_id
read(15,*) IV_basin_id
close(15)

open(16,file=gage_id_file,status='old')
!read(16,'(i12)') IV_gage_id
read(16,*) IV_gage_id
close(16)


!*******************************************************************************
!Calculates IS_gagebas, creates the vectors IV_gage_index and IV_gage_loc
!*******************************************************************************
IS_gagebas=0
do JS_gagetot=1,IS_gagetot
     do JS_reachbas=1,IS_reachbas
          if (IV_gage_id(JS_gagetot)==IV_basin_id(JS_reachbas)) then
               IS_gagebas=IS_gagebas+1
!               print *, 'IS_gagebas              =', IS_gagebas
!               print *, 'JS_reachbas             =', JS_reachbas
!               print *, 'IV_basin_id(JS_reachbas)=', IV_basin_id(JS_reachbas)
          end if
     end do
end do
write(temp_char,'(i10)') IS_gagebas
call PetscPrintf(PETSC_COMM_WORLD,'Number of gaging stations in basin studied:'&
                                  // temp_char // char(10),ierr)
!Calculates IS_gagebas

allocate(IV_gage_index(IS_gagebas))
allocate(IV_gage_loc(IS_gagebas))
JS_gagebas=1
do JS_gagetot=1,IS_gagetot
     do JS_reachbas=1,IS_reachbas
          if (IV_gage_id(JS_gagetot)==IV_basin_id(JS_reachbas)) then
               IV_gage_index(JS_gagebas)=JS_gagetot
               IV_gage_loc(JS_gagebas)=JS_reachbas-1
               JS_gagebas=JS_gagebas+1
          end if
     end do
end do
!Creates vector IV_gage_index and IV_gage_loc

!print *, 'IV_gage_index=', IV_gage_index 
!print *, 'IV_gage_loc  =', IV_gage_loc 


!*******************************************************************************
!Creation of the observation matrix
!*******************************************************************************
do JS_reachbas=1,IS_reachbas
     do JS_gagebas=1,IS_gagebas
          if (IV_gage_id(IV_gage_index(JS_gagebas))==IV_basin_id(JS_reachbas)) then
          call MatSetValues(ZM_Obs,IS_one,JS_reachbas-1,IS_one,JS_reachbas-1,  &
                            ZS_one,INSERT_VALUES,ierr)
!          print *, 'JS_gagebas                           =', JS_gagebas
!          print *, 'IV_gage_id(IV_gage_index(JS_gagebas))=', IV_gage_id(IV_gage_index(JS_gagebas))
!          print *, 'JS_reachbas                          =', JS_reachbas
!          print *, 'IV_basin_id(JS_reachbas)             =', IV_basin_id(JS_reachbas)
          else
          endif
     enddo 
enddo

call MatAssemblyBegin(ZM_Obs,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_Obs,MAT_FINAL_ASSEMBLY,ierr)
!sparse matrices need be assembled once their elements have been filled


!*******************************************************************************
!Optional: calculation of number of gaging stations used in subbasin
!*******************************************************************************
call MatNorm(ZM_Obs,NORM_FROBENIUS,ZS_norm,ierr)
ZS_norm=ZS_norm*ZS_norm
write(temp_char,'(f5.1)') ZS_norm
call PetscPrintf(PETSC_COMM_WORLD,'Number of gaging stations used (based on norm): '           &
                                  // temp_char // char(10),ierr)


!*******************************************************************************
!End
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'Observation matrix created',ierr)
call PetscPrintf(PETSC_COMM_WORLD,char(10),ierr)

!call PetscPrintf(PETSC_COMM_WORLD,'ZM_Obs:'//char(10),ierr)
!call MatView(ZM_Obs,PETSC_VIEWER_STDOUT_WORLD,ierr)

end subroutine rapid_obs_mat

subroutine rapid_obs_mat

!PURPOSE
!Creates a kronecker-type diagonal sparse matrix.  "1" is recorded at the line 
!and column where observations are available.  Calculates IS_obs_bas.  Also 
!creates vectors IV_obs_index and IV_obs_loc1
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_riv_bas,JS_riv_bas,                                      &
                   IS_obs_tot,JS_obs_tot,IS_obs_use,JS_obs_use,                &
                   IS_obs_bas,JS_obs_bas,                                      &
                   obs_tot_id_file,obs_use_id_file,                            &
                   IV_riv_bas_id,IV_obs_tot_id,IV_obs_use_id,                  & 
                   IV_obs_index,IV_obs_loc1,                                   &
                   ZM_Obs,ZS_norm,                                             &
                   ierr,                                                       &
                   IS_one,ZS_one,temp_char   


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
open(12,file=obs_tot_id_file,status='old')
read(12,*) IV_obs_tot_id
close(12)

open(13,file=obs_use_id_file,status='old')
read(13,*) IV_obs_use_id
close(13)


!*******************************************************************************
!Calculates IS_obs_bas, creates the vectors IV_obs_index and IV_obs_loc1
!*******************************************************************************
!-------------------------------------------------------------------------------
!Calculates IS_obs_bas
!-------------------------------------------------------------------------------
write(temp_char,'(i10)') IS_obs_tot
call PetscPrintf(PETSC_COMM_WORLD,'Number of gage IDs in obs_tot_file '    //  &
                 '                  :' // temp_char // char(10),ierr)
write(temp_char,'(i10)') IS_obs_use
call PetscPrintf(PETSC_COMM_WORLD,'Number of gage IDs in obs_use_file '    //  &
                 '                  :' // temp_char // char(10),ierr)

IS_obs_bas=0
!initialize to zero

do JS_obs_use=1,IS_obs_use
     do JS_riv_bas=1,IS_riv_bas
          if (IV_obs_use_id(JS_obs_use)==IV_riv_bas_id(JS_riv_bas)) then
               IS_obs_bas=IS_obs_bas+1
          end if 
     end do
end do

write(temp_char,'(i10)') IS_obs_bas
call PetscPrintf(PETSC_COMM_WORLD,'Number of gage IDs in '                 //  &
                 'this simulation                :'//temp_char // char(10),ierr)


!-------------------------------------------------------------------------------
!Allocates and populates the vectors IV_obs_index and IV_obs_loc1
!-------------------------------------------------------------------------------
allocate(IV_obs_index(IS_obs_bas))
allocate(IV_obs_loc1(IS_obs_bas))
!allocate vector size

do JS_obs_bas=1,IS_obs_bas
     IV_obs_index(JS_obs_bas)=0
     IV_obs_loc1(JS_obs_bas)=0
end do
!Initialize both vectors to zero

JS_obs_bas=1
do JS_obs_use=1,IS_obs_use
do JS_riv_bas=1,IS_riv_bas
     if (IV_obs_use_id(JS_obs_use)==IV_riv_bas_id(JS_riv_bas)) then
          do JS_obs_tot=1,IS_obs_tot
               if (IV_obs_use_id(JS_obs_use)==IV_obs_tot_id(JS_obs_tot)) then
                    IV_obs_index(JS_obs_bas)=JS_obs_tot
               end if
          end do
          IV_obs_loc1(JS_obs_bas)=JS_riv_bas-1
          JS_obs_bas=JS_obs_bas+1
     end if
end do
end do
!Creates vector IV_obs_index and IV_obs_loc1

!print *, 'IV_obs_index=', IV_obs_index 
!print *, 'IV_obs_loc1  =', IV_obs_loc1 


!*******************************************************************************
!Preallocation of the observation matrix
!*******************************************************************************
call MatSeqAIJSetPreallocation(ZM_Obs,1*IS_one,PETSC_NULL_INTEGER,ierr)
call MatMPIAIJSetPreallocation(ZM_Obs,1*IS_one,PETSC_NULL_INTEGER,0*IS_one,    &
                               PETSC_NULL_INTEGER,ierr)
!Very basic preallocation assuming that all reaches have one gage.  Cannot use
!IV_obs_loc1 for preallocation because it is of size IS_obs_bas and not 
!IS_riv_bas. To do a better preallocation one needs to count the diagonal 
!elements in a new vector

!call PetscPrintf(PETSC_COMM_WORLD,'Observation matrix preallocated'//char(10), &
!                 ierr)


!*******************************************************************************
!Creation of the observation matrix
!*******************************************************************************
do JS_riv_bas=1,IS_riv_bas
     do JS_obs_bas=1,IS_obs_bas

if (IV_obs_tot_id(IV_obs_index(JS_obs_bas))==IV_riv_bas_id(JS_riv_bas)) then
          call MatSetValues(ZM_Obs,IS_one,JS_riv_bas-1,IS_one,JS_riv_bas-1,    &
                            ZS_one,INSERT_VALUES,ierr)
end if

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
write(temp_char,'(f10.1)') ZS_norm
call PetscPrintf(PETSC_COMM_WORLD,'Number of gage IDs in '           //        &
                 'this simulation (based on norm):' // temp_char // char(10),  &
                 ierr)


!*******************************************************************************
!Display matrix on stdout
!*******************************************************************************
!call PetscPrintf(PETSC_COMM_WORLD,'ZM_Obs:'//char(10),ierr)
!call MatView(ZM_Obs,PETSC_VIEWER_STDOUT_WORLD,ierr)


!*******************************************************************************
!End
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'Observation matrix created'//char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)


end subroutine rapid_obs_mat

subroutine rapid_net_mat_brk

!PURPOSE
!This subroutine modifies the network matrix based on a list of river IDs. 
!The connectivity is broken between each given river ID and its downstream 
!river.
!When forcing option is activated, the flow exiting each given river ID is 
!read from a file and added to the inflow of its downstream river.  
!Three Fortran vectors are created that are useful here: 
! - IV_for_bas_id(IS_for_bas) allows to know the IDs of the forcing locations
!   flowing into the subbasin 
! - IV_for_index(IS_for_bas) allows to know where the flow values are 
!   located in Qfor_file using the 1-based ZV_read_for_tot
! - IV_for_loc2(IS_for_bas) allows to know where to add the flow values
!   in the current modeling domain using the 0-based ZV_Qfor
!When dam option is activated, the flow exiting each given river ID is 
!obtained from a model and added to the inflow of its downstream river.  
!Four Fortran vectors are created that are useful here: 
! - IV_dam_bas_id(IS_dam_bas) allows to know the IDs of the dam locations
!   in the subbasin 
! - IV_dam_index(IS_dam_bas) allows to know where the flow values are 
!   located in dam model array using the 1-based ZV_read_dam_tot
! - IV_dam_loc2(IS_dam_bas) allows to know where to add the flow values
!   in the current modeling domain using the 0-based ZV_Qdam
! - IV_dam_pos(IS_dam_bas) allows to know where to read the flow values for the 
!   dam model in the current modeling domain using the 0-based ZV_Qdam
!Author: Cedric H. David, 2013 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_riv_tot,IS_riv_bas,                                      &
                   JS_riv_tot,JS_riv_bas,JS_riv_bas2,                          &
                   IV_riv_bas_id,IV_riv_index,IV_riv_loc1,                     &
                   ZM_Net,ZM_A,BS_logical,IV_riv_tot_id,IV_down,               &
                   IV_nbup,JS_up,IM_index_up,                                  &
                   for_tot_id_file,for_use_id_file,                            &
                   IS_for_tot,JS_for_tot,IV_for_tot_id,                        &
                   IS_for_use,JS_for_use,IV_for_use_id,                        &
                   IS_for_bas,JS_for_bas,                                      &
                   IV_for_bas_id,IV_for_index,IV_for_loc2,                     &
                   dam_tot_id_file,dam_use_id_file,                            &
                   IS_dam_tot,JS_dam_tot,IV_dam_tot_id,IV_dam_pos,             &
                   IS_dam_use,JS_dam_use,IV_dam_use_id,                        &
                   IS_dam_bas,JS_dam_bas,IV_dam_bas_id,IV_dam_index,           &
                   IV_dam_loc2,                                                &
                   ierr,rank,                                                  &
                   IS_one,ZS_one,temp_char,IV_nz,IV_dnz,IV_onz,                &
                   IS_ownfirst,IS_ownlast,                                     &
                   BS_opt_for,BS_opt_dam

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
!If forcing is used
!*******************************************************************************
if (BS_opt_for) then
call PetscPrintf(PETSC_COMM_WORLD,'WARNING: Forcing option activated'//        &
                 char(10),ierr)

!-------------------------------------------------------------------------------
!Read data files
!-------------------------------------------------------------------------------
open(16,file=for_tot_id_file,status='old')
read(16,*) IV_for_tot_id
close(16)

open(17,file=for_use_id_file,status='old')
read(17,*) IV_for_use_id
close(17)

!-------------------------------------------------------------------------------
!Calculates IS_for_bas
!-------------------------------------------------------------------------------
write(temp_char,'(i10)') IS_for_tot
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of forcing IDs in ' //&
                 'for_tot_id_file:' // temp_char // char(10),ierr)

write(temp_char,'(i10)') IS_for_use
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of forcing IDs in ' //&
                 'for_use_id_file:' // temp_char // char(10),ierr)

IS_for_bas=0
!initialize to zero

do JS_for_use=1,IS_for_use
     do JS_riv_tot=1,IS_riv_tot
          if (IV_for_use_id(JS_for_use)==IV_riv_tot_id(JS_riv_tot)) then

     do JS_riv_bas=1,IS_riv_bas
          if (IV_down(JS_riv_tot)==IV_riv_bas_id(JS_riv_bas)) then 
               IS_for_bas=IS_for_bas+1
          end if
     end do

          end if 
     end do
end do

write(temp_char,'(i10)') IS_for_bas
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of forcing IDs in ' //&
                 'this simulation:' // temp_char // char(10),ierr)

!-------------------------------------------------------------------------------
!Allocate and initialize the vectors IV_for_index and IV_for_loc2
!-------------------------------------------------------------------------------
allocate(IV_for_bas_id(IS_for_bas))
allocate(IV_for_index(IS_for_bas))
allocate(IV_for_loc2(IS_for_bas))

IV_for_bas_id=0
IV_for_index=0
IV_for_loc2=0

!-------------------------------------------------------------------------------
!Populate IV_for_bas_id
!-------------------------------------------------------------------------------
if (IS_for_bas>0) then

JS_for_bas=0
!initialize to zero

do JS_for_use=1,IS_for_use
     do JS_riv_tot=1,IS_riv_tot
          if (IV_for_use_id(JS_for_use)==IV_riv_tot_id(JS_riv_tot)) then

     do JS_riv_bas=1,IS_riv_bas
          if (IV_down(JS_riv_tot)==IV_riv_bas_id(JS_riv_bas)) then 
               JS_for_bas=JS_for_bas+1
               IV_for_bas_id(JS_for_bas)=IV_for_use_id(JS_for_use)
          end if
     end do

          end if 
     end do
end do

end if

!-------------------------------------------------------------------------------
!Populate IV_for_index
!-------------------------------------------------------------------------------
do JS_for_bas=1,IS_for_bas
do JS_for_tot=1,IS_for_tot
     if (IV_for_bas_id(JS_for_bas)==IV_for_tot_id(JS_for_tot)) then
          IV_for_index(JS_for_bas)=JS_for_tot
     end if
end do
end do

!-------------------------------------------------------------------------------
!Populate IV_for_loc2
!-------------------------------------------------------------------------------
do JS_for_bas=1,IS_for_bas
do JS_riv_tot=1,IS_riv_tot
     if (IV_for_bas_id(JS_for_bas)==IV_riv_tot_id(JS_riv_tot)) then
          do JS_riv_bas=1,IS_riv_bas

if (IV_down(JS_riv_tot)==IV_riv_bas_id(JS_riv_bas)) then
     IV_for_loc2(JS_for_bas)=IV_riv_loc1(JS_riv_bas)
end if

          end do
     end if
end do
end do

!-------------------------------------------------------------------------------
!Print warning when forcing is used
!-------------------------------------------------------------------------------
if (rank==0 .and. IS_for_bas>0) then
     print *, '        Forcing flows replace computed flows, using:'
     !print *, '        IV_for_tot_id   =', IV_for_tot_id
     print *, '        IV_for_use_id   =', IV_for_use_id
     print *, '        IV_for_bas_id   =', IV_for_bas_id
     print *, '        IV_for_index    =', IV_for_index
     print *, '        IV_for_loc2     =', IV_for_loc2
end if
!Warning about forcing downstream basins

!-------------------------------------------------------------------------------
!Breaks matrix connectivity in case forcing used is inside basin studied
!-------------------------------------------------------------------------------
if (IS_for_bas>0) then 
call PetscPrintf(PETSC_COMM_WORLD,'Modifying network matrix'//char(10),ierr)
end if

if (rank==0) then
!only first processor sets values
do JS_for_bas=1,IS_for_bas
     do JS_riv_bas=1,IS_riv_bas
          if (IV_for_bas_id(JS_for_bas)==IV_riv_bas_id(JS_riv_bas)) then

     do JS_riv_bas2=1,IS_riv_bas
          if (IV_down(IV_riv_index(JS_riv_bas))==IV_riv_bas_id(JS_riv_bas2))then
          !here JS_riv_bas2 is determined as directly downstream of JS_riv_bas
          !and the connection between both needs be broken

          call MatSetValues(ZM_Net,IS_one,JS_riv_bas2-1,IS_one,JS_riv_bas-1,   &
                            0*ZS_one,INSERT_VALUES,ierr)
          CHKERRQ(ierr)
          !Breaks connection for matrix-based Muskingum method

          do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))
               if (IM_index_up(JS_riv_bas2,JS_up)==JS_riv_bas) then
                    IM_index_up(JS_riv_bas2,JS_up)=0
               end if
          end do
          !Breaks connection for traditional Muskingum method

          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           '         connection broken downstream of reach ID' &
                            // temp_char,ierr)
          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas2)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           ' forcing data will be used for reach ID'           &
                           // temp_char // char(10),ierr)
          !Writes information on connection that was just broken in stdout

          end if
     end do 

          end if
     end do
end do
end if
call MatAssemblyBegin(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
!!sparse matrices need be assembled once their elements have been filled
call PetscPrintf(PETSC_COMM_WORLD,'Network matrix modified for forcing'//      &
                 char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

!-------------------------------------------------------------------------------
!End if forcing is used
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!If dam model is used
!*******************************************************************************
if (BS_opt_dam) then
call PetscPrintf(PETSC_COMM_WORLD,'WARNING: Dam option activated'//            &
                 char(10),ierr)

!-------------------------------------------------------------------------------
!Read data files
!-------------------------------------------------------------------------------
open(18,file=dam_tot_id_file,status='old')
read(18,*) IV_dam_tot_id
close(18)

open(19,file=dam_use_id_file,status='old')
read(19,*) IV_dam_use_id
close(19)

!-------------------------------------------------------------------------------
!Calculate IS_dam_bas 
!-------------------------------------------------------------------------------
write(temp_char,'(i10)') IS_dam_tot
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of dam IDs in ' //    &
                 'dam_tot_id_file:' // temp_char // char(10),ierr)

write(temp_char,'(i10)') IS_dam_use
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of dam IDs in ' //    &
                 'dam_use_id_file:' // temp_char // char(10),ierr)

IS_dam_bas=0

do JS_dam_use=1,IS_dam_use
do JS_riv_bas=1,IS_riv_bas
     if (IV_dam_use_id(JS_dam_use)==IV_riv_tot_id(IV_riv_index(JS_riv_bas)))then
          IS_dam_bas=IS_dam_bas+1
     end if 
end do
end do

write(temp_char,'(i10)') IS_dam_bas
call PetscPrintf(PETSC_COMM_WORLD,'         Total number of dam IDs in ' //    &
                 'this simulation:' // temp_char // char(10),ierr)

!-------------------------------------------------------------------------------
!Allocate and initialize IV_dam_bas_id,IV_dam_index and IV_dam_loc2
!-------------------------------------------------------------------------------
allocate(IV_dam_bas_id(IS_dam_bas))
allocate(IV_dam_index(IS_dam_bas))
allocate(IV_dam_loc2(IS_dam_bas))
allocate(IV_dam_pos(IS_dam_tot))

IV_dam_bas_id=0
IV_dam_index=0
IV_dam_loc2=0
IV_dam_pos=0

!-------------------------------------------------------------------------------
!Populate IV_dam_bas_id
!-------------------------------------------------------------------------------
if (IS_dam_bas>0) then

JS_dam_bas=0

do JS_dam_use=1,IS_dam_use
do JS_riv_bas=1,IS_riv_bas
     if (IV_dam_use_id(JS_dam_use)==IV_riv_tot_id(IV_riv_index(JS_riv_bas)))then
          JS_dam_bas=JS_dam_bas+1
          IV_dam_bas_id(JS_dam_bas)=IV_riv_tot_id(IV_riv_index(JS_riv_bas))
     end if 
end do
end do

end if

!-------------------------------------------------------------------------------
!Populate IV_dam_index 
!-------------------------------------------------------------------------------
do JS_dam_bas=1,IS_dam_bas
do JS_dam_tot=1,IS_dam_tot
     if (IV_dam_bas_id(JS_dam_bas)==IV_dam_tot_id(JS_dam_tot)) then
          IV_dam_index(JS_dam_bas)=JS_dam_tot
     end if
end do
end do

!-------------------------------------------------------------------------------
!Populate IV_dam_loc2
!-------------------------------------------------------------------------------
do JS_dam_bas=1,IS_dam_bas
do JS_riv_tot=1,IS_riv_tot
     if (IV_dam_bas_id(JS_dam_bas)==IV_riv_tot_id(JS_riv_tot)) then
          do JS_riv_bas=1,IS_riv_bas

if (IV_riv_bas_id(JS_riv_bas)==IV_down(JS_riv_tot)) then
          IV_dam_loc2(JS_dam_bas)=JS_riv_bas-1
end if 
          end do
     end if
end do
end do

!!-------------------------------------------------------------------------------
!!Populate IV_dam_pos
!!-------------------------------------------------------------------------------
do JS_dam_tot=1,IS_dam_tot
do JS_riv_bas=1,IS_riv_bas
     if (IV_dam_tot_id(JS_dam_tot)==IV_riv_bas_id(JS_riv_bas)) then
          IV_dam_pos(JS_dam_tot)=JS_riv_bas-1
     end if
end do
end do

!-------------------------------------------------------------------------------
!Print warning when dam model is used
!-------------------------------------------------------------------------------
if (rank==0 .and. IS_dam_bas>0) then
     print *, '        Dam flows replace computed flows, using:'
     !print *, '        IV_dam_tot_id   =', IV_dam_tot_id
     print *, '        IV_dam_use_id   =', IV_dam_use_id
     print *, '        IV_dam_bas_id   =', IV_dam_bas_id
     print *, '        IV_dam_index    =', IV_dam_index
     print *, '        IV_dam_loc2     =', IV_dam_loc2
     print *, '        IV_dam_pos      =', IV_dam_pos
end if
!Warning about forcing downstream basins

!-------------------------------------------------------------------------------
!Breaks matrix connectivity in case dam model is used inside basin studied
!-------------------------------------------------------------------------------
if (IS_dam_bas>0) then 
call PetscPrintf(PETSC_COMM_WORLD,'Modifying network matrix'//char(10),ierr)
end if

if (rank==0) then
!only first processor sets values
do JS_dam_bas=1,IS_dam_bas
     do JS_riv_bas=1,IS_riv_bas
          if (IV_dam_bas_id(JS_dam_bas)==IV_riv_bas_id(JS_riv_bas)) then

     do JS_riv_bas2=1,IS_riv_bas
          if (IV_down(IV_riv_index(JS_riv_bas))==IV_riv_bas_id(JS_riv_bas2))then
          !here JS_riv_bas2 is determined as directly downstream of JS_riv_bas
          !and the connection between both needs be broken

          call MatSetValues(ZM_Net,IS_one,JS_riv_bas2-1,IS_one,JS_riv_bas-1,   &
                            0*ZS_one,INSERT_VALUES,ierr)
          CHKERRQ(ierr)
          !Breaks connection for matrix-based Muskingum method

          do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))
               if (IM_index_up(JS_riv_bas2,JS_up)==JS_riv_bas) then
                    IM_index_up(JS_riv_bas2,JS_up)=0
               end if
          end do
          !Breaks connection for traditional Muskingum method

          
          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           '         connection broken downstream of reach ID' &
                            // temp_char,ierr)
          write(temp_char,'(i10)') IV_riv_bas_id(JS_riv_bas2)
          call PetscPrintf(PETSC_COMM_WORLD,                                   &
                           ' forcing data will be used for reach ID'           &
                           // temp_char // char(10),ierr)
          !Writes information on connection that was just broken in stdout

          end if
     end do 

          end if
     end do
end do
end if
call MatAssemblyBegin(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_Net,MAT_FINAL_ASSEMBLY,ierr)
!sparse matrices need be assembled once their elements have been filled
call PetscPrintf(PETSC_COMM_WORLD,'Network matrix modified for dams'//         &
                 char(10),ierr)
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

!-------------------------------------------------------------------------------
!End if dam model is used
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!Display matrix on stdout
!*******************************************************************************
!call PetscPrintf(PETSC_COMM_WORLD,'ZM_Net'//char(10),ierr)
!call MatView(ZM_Net,PETSC_VIEWER_STDOUT_WORLD,ierr)


!*******************************************************************************
!End
!*******************************************************************************


end subroutine rapid_net_mat_brk

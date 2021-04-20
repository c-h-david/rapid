!*******************************************************************************
!Program - rapid_main
!*******************************************************************************
program rapid_main

!Purpose:
!Allows to route water through a river network, and to estimate optimal 
!parameters using the inverse method 
!Author: 
!Cedric H. David, 2008-2021.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petsctao.h>
use petsctao
use rapid_var, only :                                                          &
                   namelist_file,                                              &
                   Vlat_file,Qfor_file,Qhum_file,                              &
                   Qout_file,V_file,                                           &
                   IS_M,JS_M,JS_RpM,IS_RpM,IS_RpF,IS_RpH,                      &
                   ZS_TauR,                                                    &
                   ZV_pnorm,                                                   &
                   ZV_k,ZV_x,ZV_C1,ZV_C2,ZV_C3,                                &
                   ZV_Qext,ZV_Qfor,ZV_Qlat,ZV_Qhum,ZV_Qdam,                    &
                   ZV_Vlat,                                                    &
                   ZV_QoutR,ZV_QoutinitR,ZV_QoutbarR,                          &
                   ZV_VR,ZV_VinitR,ZV_VbarR,                                   &
                   ierr,rank,stage,temp_char,temp_char2,                       &
                   ZS_one,                                                     &
                   IS_riv_tot,IS_riv_bas,IS_for_bas,IS_dam_bas,IS_hum_bas,     &
                   ZS_time1,ZS_time2,ZS_time3,ZS_time4,                        &
                   IV_nc_start,IV_nc_count,IV_nc_count2,                       &
                   BS_opt_V,BS_opt_for,BS_opt_hum,BS_opt_dam,IS_opt_run,       &
                   BS_opt_uq,                                                  &
                   tao,                                                        &
                   Qobs_file,ZV_Qobs,                                          &
                   ZV_Qbmean,ZV_dQeb,ZS_val,                                   &
                   ZV_QoutinitR_save
implicit none
external rapid_phiroutine
!because the subroutine is called by a function


!*******************************************************************************
!Initialize
!*******************************************************************************
namelist_file='./rapid_namelist' 
call rapid_init


!*******************************************************************************
!OPTION 1 - use to calculate flows and volumes and generate output data 
!*******************************************************************************
if (IS_opt_run==1) then

!-------------------------------------------------------------------------------
!Open Vlat file
!-------------------------------------------------------------------------------
call rapid_open_Vlat_file(Vlat_file)
call rapid_meta_Vlat_file(Vlat_file)

!-------------------------------------------------------------------------------
!Quantify uncertainty
!-------------------------------------------------------------------------------
if (BS_opt_uq) call rapid_uq

!-------------------------------------------------------------------------------
!Create and open Qout file
!-------------------------------------------------------------------------------
call rapid_create_Qout_file(Qout_file)
call rapid_open_Qout_file(Qout_file)

!-------------------------------------------------------------------------------
!Create and open V_file
!-------------------------------------------------------------------------------
if (BS_opt_V) call rapid_create_V_file(V_file)
if (BS_opt_V) call rapid_open_V_file(V_file)

!-------------------------------------------------------------------------------
!Open remaining files          
!-------------------------------------------------------------------------------
if (BS_opt_for) call rapid_open_Qfor_file(Qfor_file)
if (BS_opt_hum) call rapid_open_Qhum_file(Qhum_file)

!-------------------------------------------------------------------------------
!Make sure the vectors potentially used for inflow to dams are initially null
!-------------------------------------------------------------------------------
call VecSet(ZV_Qext,0*ZS_one,ierr)                         !Qext=0
call VecSet(ZV_QoutbarR,0*ZS_one,ierr)                     !QoutbarR=0
!This should be done by PETSc but just to be safe

!-------------------------------------------------------------------------------
!Set initial value of Qext from Qout_dam0
!-------------------------------------------------------------------------------
if (BS_opt_dam .and. IS_dam_bas>0) then
     call rapid_set_Qext0                                  !Qext from Qout_dam0
     !call VecView(ZV_Qext,PETSC_VIEWER_STDOUT_WORLD,ierr)
end if

!-------------------------------------------------------------------------------
!Read, compute and write          
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Read Comp Write',stage,ierr)
call PetscLogStagePush(stage,ierr)
ZS_time3=0

IV_nc_start=(/1,1/)
IV_nc_count=(/IS_riv_tot,1/)
IV_nc_count2=(/IS_riv_bas,1/)

do JS_M=1,IS_M

do JS_RpM=1,IS_RpM

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set surface and subsurface volumes 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call rapid_read_Vlat_file

call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set upstream forcing
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (BS_opt_for .and. IS_for_bas>0                                              &
                   .and. mod((JS_M-1)*IS_RpM+JS_RpM,IS_RpF)==1) then

call rapid_read_Qfor_file

end if 

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Run dam model based on previous values of QoutbarR and Qext to get Qdam
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (BS_opt_dam .and. IS_dam_bas>0) then

call rapid_get_Qdam

end if

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Read/set human induced flows 
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (BS_opt_hum .and. IS_hum_bas>0                                              &
                   .and. mod((JS_M-1)*IS_RpM+JS_RpM,IS_RpH)==1) then

call rapid_read_Qhum_file

end if 

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!calculation of Qext
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecCopy(ZV_Qlat,ZV_Qext,ierr)                            !Qext=Qlat
if (BS_opt_for) call VecAXPY(ZV_Qext,ZS_one,ZV_Qfor,ierr)     !Qext=Qext+1*Qfor
if (BS_opt_dam) call VecAXPY(ZV_Qext,ZS_one,ZV_Qdam,ierr)     !Qext=Qext+1*Qdam
if (BS_opt_hum) call VecAXPY(ZV_Qext,ZS_one,ZV_Qhum,ierr)     !Qext=Qext+1*Qhum

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Routing procedure
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call PetscTime(ZS_time1,ierr)

call rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                                  &
                   ZV_QoutinitR,                                               &
                   ZV_QoutR,ZV_QoutbarR)

if (BS_opt_V) call rapid_QtoV(ZV_k,ZV_x,ZV_QoutbarR,ZV_Qext,ZV_VbarR)

call PetscTime(ZS_time2,ierr)
ZS_time3=ZS_time3+ZS_time2-ZS_time1


!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Update variables
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call VecCopy(ZV_QoutR,ZV_QoutinitR,ierr)
call VecCopy(ZV_VR,ZV_VinitR,ierr)
     
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!write outputs         
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call rapid_write_Qout_file
if (BS_opt_V) call rapid_write_V_file

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Update netCDF location         
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine


end do
end do

!-------------------------------------------------------------------------------
!Performance statistics
!-------------------------------------------------------------------------------
call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for routing only'           &
                                  //char(10),ierr)
write(temp_char ,'(i10)')   rank
write(temp_char2,'(f10.2)') ZS_time3
call PetscSynchronizedPrintf(PETSC_COMM_WORLD,'Rank     :'//temp_char //', '// &
                                              'Time     :'//temp_char2//       &
                                               char(10),ierr)
call PetscSynchronizedFlush(PETSC_COMM_WORLD,PETSC_NULL_INTEGER,ierr)

call PetscLogStagePop(ierr)
call PetscPrintf(PETSC_COMM_WORLD,'Output data created'//char(10),ierr)


!-------------------------------------------------------------------------------
!Close files          
!-------------------------------------------------------------------------------
call rapid_close_Qout_file
call rapid_close_Vlat_file
if (BS_opt_for) call rapid_close_Qfor_file(Qfor_file)
if (BS_opt_hum) call rapid_close_Qhum_file(Qhum_file)
if (BS_opt_V) call rapid_close_V_file(V_file)


!-------------------------------------------------------------------------------
!End of OPTION 1
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!OPTION 2 - Optimization 
!*******************************************************************************
if (IS_opt_run==2) then

!-------------------------------------------------------------------------------
!Only one computation of phi - For testing purposes only
!-------------------------------------------------------------------------------
!call PetscLogStageRegister('One comp of phi',stage,ierr)
!call PetscLogStagePush(stage,ierr)
!!do JS_M=1,5
!call rapid_phiroutine(tao,ZV_pnorm,ZS_phi,PETSC_NULL,ierr)
!!enddo
!call PetscLogStagePop(ierr)

!-------------------------------------------------------------------------------
!Optimization procedure
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Optimization   ',stage,ierr)
call PetscLogStagePush(stage,ierr)
call TaoSetObjectiveRoutine(tao,rapid_phiroutine,PETSC_NULL_INTEGER,ierr)
call TaoSetInitialVector(tao,ZV_pnorm,ierr)
call TaoSolve(tao,ierr)

call TaoView(tao,PETSC_VIEWER_STDOUT_WORLD,ierr)
call PetscPrintf(PETSC_COMM_WORLD,'final normalized p=(k,x)'//char(10),ierr)
call VecView(ZV_pnorm,PETSC_VIEWER_STDOUT_WORLD,ierr)
call PetscLogStagePop(ierr)

!-------------------------------------------------------------------------------
!End of OPTION 2
!-------------------------------------------------------------------------------
end if


!*******************************************************************************
!OPTION 3/4 - data assimilation (of discharge to correct runoff input)
!*******************************************************************************
if ((IS_opt_run==3).or.(IS_opt_run==4)) then

!-------------------------------------------------------------------------------
!Open Vlat file
!-------------------------------------------------------------------------------
call rapid_open_Vlat_file(Vlat_file)
call rapid_meta_Vlat_file(Vlat_file)

!-------------------------------------------------------------------------------
!Compute runoff error covariance matrix
!-------------------------------------------------------------------------------
call rapid_cov_mat
call rapid_kf_cov_mat

!-------------------------------------------------------------------------------
!Open observation file
!-------------------------------------------------------------------------------
call rapid_open_Qobs_file(Qobs_file)

!-------------------------------------------------------------------------------
!Create and open Qout file
!-------------------------------------------------------------------------------
call rapid_create_Qout_file(Qout_file)
call rapid_open_Qout_file(Qout_file)

!-------------------------------------------------------------------------------
!Create and open V_file
!-------------------------------------------------------------------------------
if (BS_opt_V) call rapid_create_V_file(V_file)
if (BS_opt_V) call rapid_open_V_file(V_file)

!-------------------------------------------------------------------------------
!Make sure the vectors potentially used for inflow to dams are initially null
!-------------------------------------------------------------------------------
call VecSet(ZV_Qext,0*ZS_one,ierr)                         !Qext=0
call VecSet(ZV_QoutbarR,0*ZS_one,ierr)                     !QoutbarR=0
!This should be done by PETSc but just to be safe

!-------------------------------------------------------------------------------
!Read, compute, Kalman, and write          
!-------------------------------------------------------------------------------
call PetscLogStageRegister('Read Comp KF Write',stage,ierr)
call PetscLogStagePush(stage,ierr)
ZS_time3=0
ZS_time4=0

IV_nc_start=(/1,1/)
IV_nc_count=(/IS_riv_tot,1/)
IV_nc_count2=(/IS_riv_bas,1/)

do JS_M=1,IS_M

!write(temp_char,'(i10)') IS_M 
!write(temp_char2,'(i10)') JS_M    
!call PetscPrintf(PETSC_COMM_WORLD,'Assimilation day '                          &
!                                  //temp_char2//'/'//temp_char//               &
!                                  char(10),ierr)

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Initialize ZV_Qbmean and ZV_dQeb for assimilation and save initial condition
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
call VecSet(ZV_Qbmean,0*ZS_one,ierr)    !Daily-averaged simulated discharge
call VecSet(ZV_dQeb,0*ZS_one,ierr)      !Kalman filter correction 
call VecSet(ZV_Qobs,0*ZS_one,ierr)      !Observation vector (size IS_riv_bas)

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Run RAPID forecast          
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Save initial condition for later (analysis) run
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_QoutinitR,ZV_QoutinitR_save,ierr)

do JS_RpM=1,IS_RpM

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Read/set surface and subsurface volumes 
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call rapid_read_Vlat_file

call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!calculation of Qext
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_Qlat,ZV_Qext,ierr)                            !Qext=Qlat

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Routing procedure with background runoff
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call PetscTime(ZS_time1,ierr)

call rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                                  &
                   ZV_QoutinitR,                                               &
                   ZV_QoutR,ZV_QoutbarR)

if (BS_opt_V) call rapid_QtoV(ZV_k,ZV_x,ZV_QoutbarR,ZV_Qext,ZV_VbarR)

call PetscTime(ZS_time2,ierr)
ZS_time3=ZS_time3+ZS_time2-ZS_time1

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update ZV_Qbmean
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
ZS_val= ZS_one/(REAL(IS_RpM))
call VecAXPY(ZV_Qbmean,ZS_val,ZV_QoutbarR,ierr)

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update variables
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_QoutR,ZV_QoutinitR,ierr)
call VecCopy(ZV_VR,ZV_VinitR,ierr)

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update netCDF location         
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine

end do

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Kalman filtering
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
call PetscTime(ZS_time1,ierr)

call rapid_read_Qobs_file
!Build observation vector

call rapid_kf_update
!Kalman filter update

call PetscTime(ZS_time2,ierr)
ZS_time4=ZS_time4+ZS_time2-ZS_time1

!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
!Run RAPID analysis          
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Re-set initial condition and netcdf location 
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_QoutinitR_save,ZV_QoutinitR,ierr)
if (rank==0) IV_nc_start(2)=IV_nc_start(2)-IS_RpM

do JS_RpM=1,IS_RpM

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Read/set surface and subsurface volumes 
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call rapid_read_Vlat_file

call VecCopy(ZV_Vlat,ZV_Qlat,ierr)            !Qlat=Vlat
call VecScale(ZV_Qlat,1/ZS_TauR,ierr)         !Qlat=Qlat/TauR

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update surface and subsurface flow with Kalman Filter correction 
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecAXPY(ZV_Qlat,ZS_one,ZV_dQeb,ierr)         !Qlat=Qlat+dQeb

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!calculation of Qext
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_Qlat,ZV_Qext,ierr)                            !Qext=Qlat+dQeb

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Routing procedure with analysis runoff
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call PetscTime(ZS_time1,ierr)

call rapid_routing(ZV_C1,ZV_C2,ZV_C3,ZV_Qext,                                  &
                   ZV_QoutinitR,                                               &
                   ZV_QoutR,ZV_QoutbarR)

if (BS_opt_V) call rapid_QtoV(ZV_k,ZV_x,ZV_QoutbarR,ZV_Qext,ZV_VbarR)

call PetscTime(ZS_time2,ierr)
ZS_time3=ZS_time3+ZS_time2-ZS_time1

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update variables
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call VecCopy(ZV_QoutR,ZV_QoutinitR,ierr)
call VecCopy(ZV_VR,ZV_VinitR,ierr)

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!write outputs         
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
call rapid_write_Qout_file
if (BS_opt_V) call rapid_write_V_file

!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
!Update netCDF location         
!  -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
if (rank==0) IV_nc_start(2)=IV_nc_start(2)+1
!do not comment out if writing directly from the routing subroutine


end do

end do

!-------------------------------------------------------------------------------
!Performance statistics
!-------------------------------------------------------------------------------
call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for routing (background '// &
                                  'and analysis)'//char(10),ierr)
write(temp_char ,'(i10)')   rank
write(temp_char2,'(f10.2)') ZS_time3
call PetscSynchronizedPrintf(PETSC_COMM_WORLD,'Rank     :'//temp_char //', '// &
                                              'Time     :'//temp_char2//       &
                                               char(10),ierr)
call PetscSynchronizedFlush(PETSC_COMM_WORLD,PETSC_NULL_INTEGER,ierr)

call PetscPrintf(PETSC_COMM_WORLD,'Cumulative time for Kalman filtering'       &
                                  //char(10),ierr)
write(temp_char ,'(i10)')   rank
write(temp_char2,'(f10.2)') ZS_time4
call PetscSynchronizedPrintf(PETSC_COMM_WORLD,'Rank     :'//temp_char //', '// &
                                              'Time     :'//temp_char2//       &
                                               char(10),ierr)
call PetscSynchronizedFlush(PETSC_COMM_WORLD,PETSC_NULL_INTEGER,ierr)

call PetscLogStagePop(ierr)
call PetscPrintf(PETSC_COMM_WORLD,'Output data created'//char(10),ierr)


!-------------------------------------------------------------------------------
!Close files          
!-------------------------------------------------------------------------------
call rapid_close_Qout_file
call rapid_close_Vlat_file
call rapid_close_Qobs_file
if (BS_opt_V) call rapid_close_V_file(V_file)

!-------------------------------------------------------------------------------
!End of OPTION 3/4
!-------------------------------------------------------------------------------
end if



!*******************************************************************************
!Finalize
!*******************************************************************************
call rapid_final


!*******************************************************************************
!End program
!*******************************************************************************
end program rapid_main

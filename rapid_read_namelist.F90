subroutine rapid_read_namelist

!PURPOSE
!This subroutine allows to read the RAPID namelist and hence to run the model
!multiple times without ever have to recompile.  Some information on the options
!used is also printed in the stdout
!Author: Cedric H. David, 2011 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                     BS_opt_Qinit,BS_opt_forcing,BS_opt_babsmax,               &
                     IS_opt_routing,IS_opt_run,IS_opt_phi,                     &
                     IS_reachtot,modcou_connect_file,m3_nc_file,IS_max_up,     &
                     IS_reachbas,basin_id_file,                                &
                     Qinit_file,                                               &
                     IS_forcingtot,forcingtot_id_file,Qfor_file,               &
                     IS_forcinguse,forcinguse_id_file,                         &
                     babsmax_file,                                             &
                     k_file,x_file,Qout_nc_file,                               &
                     kfac_file,xfac_file,ZS_knorm_init,ZS_xnorm_init,          &
                     IS_gagetot,gagetot_id_file,IS_gageuse,gageuse_id_file,    &
                     Qobs_file,Qobsbarrec_file,                                &
                     ZS_TauM,ZS_dtM,ZS_TauO,ZS_dtO,ZS_TauR,ZS_dtR,             &
                     ZS_phifac,IS_strt_opt,                                    &
                     NL_namelist,namelist_file,                                &
                     rank


implicit none


!*******************************************************************************
!Read namelist file 
!*******************************************************************************
open(88,file=namelist_file,status='old',form='formatted')
read(88, NL_namelist)
close(88)


!*******************************************************************************
!Optional prints what was read 
!*******************************************************************************
!print *, namelist_file
!print *, 'IS_reachtot=', IS_reachtot
!print *, 'IS_reachbas=', IS_reachbas
!print *, 'basin_id_file', basin_id_file
!print *, 'Qinit_file', Qinit_file
!print *, 'Qfor_file', Qfor_file
!print *, ZS_TauM,ZS_dtM,ZS_TauO,ZS_dtO,ZS_TauR,ZS_dtR
!print *, IS_strt_opt
!print *, IS_max_up


end subroutine rapid_read_namelist

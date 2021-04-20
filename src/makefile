#*******************************************************************************
#makefile
#*******************************************************************************

#Purpose:
#This file, along with the make utility allows compiling/linking RAPID
#Author:
#Cedric H. David, 2008-2021.


#*******************************************************************************
#PETSc rules and variables (where environment variables and options are)
#*******************************************************************************
include ${PETSC_DIR}/lib/petsc/conf/variables
include ${PETSC_DIR}/lib/petsc/conf/rules


#*******************************************************************************
#Location of netCDF include and lib directories
#*******************************************************************************
NETCDF_LIB=-L ${TACC_NETCDF_LIB} -lnetcdff
NETCDF_INCLUDE=-I ${TACC_NETCDF_INC}


#*******************************************************************************
#Get version of RAPID 
#*******************************************************************************
RAPID_VERSION="'$(shell ./rapid_version.sh)'"


#*******************************************************************************
#makefile instructions 
#*******************************************************************************

#-------------------------------------------------------------------------------
#Test that environment variables are properly read by make
#-------------------------------------------------------------------------------
dummy: 
	echo ${FLINKER}

#-------------------------------------------------------------------------------
#Link RAPID main
#-------------------------------------------------------------------------------
rapid:	rapid_main.o \
	rapid_init.o \
	rapid_read_namelist.o \
	rapid_arrays.o \
	rapid_create_obj.o \
	rapid_create_Qfinal_file.o \
	rapid_create_Qout_file.o \
	rapid_create_V_file.o \
	rapid_open_Qfinal_file.o \
	rapid_open_Qinit_file.o \
	rapid_open_Qout_file.o \
	rapid_open_V_file.o \
	rapid_open_Vlat_file.o \
	rapid_open_Qobs_file.o \
	rapid_open_Qfor_file.o \
	rapid_open_Qhum_file.o \
	rapid_meta_Vlat_file.o \
	rapid_write_Qfinal_file.o \
	rapid_write_Qout_file.o \
	rapid_write_V_file.o \
	rapid_read_Qinit_file.o \
	rapid_read_Vlat_file.o \
	rapid_read_Qobs_file.o \
	rapid_read_Qfor_file.o \
	rapid_read_Qhum_file.o \
	rapid_close_Qfinal_file.o \
	rapid_close_Qinit_file.o \
	rapid_close_Qout_file.o \
	rapid_close_V_file.o \
	rapid_close_Vlat_file.o \
	rapid_close_Qobs_file.o \
	rapid_close_Qfor_file.o \
	rapid_close_Qhum_file.o \
	rapid_get_Qdam.o \
	rapid_set_Qext0.o \
	rapid_hsh_mat.o \
	rapid_mus_mat.o \
	rapid_runoff2streamflow_mat.o \
	rapid_run2strm_mat_smpl.o \
	rapid_kf_obs_mat.o \
	rapid_net_mat.o \
	rapid_net_mat_brk.o \
	rapid_obs_mat.o \
	rapid_QtoV.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_final.o \
	rapid_uq.o \
        rapid_kf_update.o \
        rapid_kf_cov_mat.o \
        rapid_cov_mat.o \
	rapid_var.o
	${FLINKER} -o \
	rapid \
	rapid_main.o \
	rapid_init.o \
	rapid_read_namelist.o \
	rapid_arrays.o \
	rapid_create_obj.o \
	rapid_create_Qfinal_file.o \
	rapid_create_Qout_file.o \
	rapid_create_V_file.o \
	rapid_open_Qfinal_file.o \
	rapid_open_Qinit_file.o \
	rapid_open_Qout_file.o \
	rapid_open_V_file.o \
	rapid_open_Vlat_file.o \
	rapid_open_Qobs_file.o \
	rapid_open_Qfor_file.o \
	rapid_open_Qhum_file.o \
	rapid_meta_Vlat_file.o \
	rapid_write_Qfinal_file.o \
	rapid_write_Qout_file.o \
	rapid_write_V_file.o \
	rapid_read_Qinit_file.o \
	rapid_read_Vlat_file.o \
	rapid_read_Qobs_file.o \
	rapid_read_Qfor_file.o \
	rapid_read_Qhum_file.o \
	rapid_close_Qfinal_file.o \
	rapid_close_Qinit_file.o \
	rapid_close_Qout_file.o \
	rapid_close_V_file.o \
	rapid_close_Vlat_file.o \
	rapid_close_Qobs_file.o \
	rapid_close_Qfor_file.o \
	rapid_close_Qhum_file.o \
	rapid_get_Qdam.o \
	rapid_set_Qext0.o \
	rapid_hsh_mat.o \
	rapid_mus_mat.o \
	rapid_runoff2streamflow_mat.o \
	rapid_run2strm_mat_smpl.o \
	rapid_kf_obs_mat.o \
	rapid_net_mat.o \
	rapid_net_mat_brk.o \
	rapid_QtoV.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_obs_mat.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_final.o \
	rapid_uq.o \
	rapid_kf_update.o \
	rapid_kf_cov_mat.o \
	rapid_cov_mat.o \
	rapid_var.o \
	${PETSC_LIB} ${NETCDF_LIB}
	${RM} *.o *.mod 
	ln -sf ../src/rapid ../tst/rapid

#-------------------------------------------------------------------------------
#Compile RAPID
#-------------------------------------------------------------------------------
rapid_main.o: 			rapid_main.F90 rapid_var.mod 
	${FLINKER} -c rapid_main.F90 ${PETSC_FC_INCLUDES}

rapid_final.o:			rapid_final.F90 rapid_var.mod
	${FLINKER} -c rapid_final.F90 ${PETSC_FC_INCLUDES}

rapid_destro_obj.o: 		rapid_destro_obj.F90 rapid_var.mod
	${FLINKER} -c rapid_destro_obj.F90 ${PETSC_FC_INCLUDES}

rapid_phiroutine.o: 		rapid_phiroutine.F90 rapid_var.mod
	${FLINKER} -c rapid_phiroutine.F90 ${PETSC_FC_INCLUDES}

rapid_QtoV.o: 			rapid_QtoV.F90 rapid_var.mod
	${FLINKER} -c rapid_QtoV.F90 ${PETSC_FC_INCLUDES}

rapid_routing.o: 		rapid_routing.F90 rapid_var.mod
	${FLINKER} -c rapid_routing.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_init.o: 			rapid_read_namelist.o rapid_var.mod
	${FLINKER} -c rapid_init.F90 ${PETSC_FC_INCLUDES} -D RAPID_VERSION=${RAPID_VERSION}

rapid_routing_param.o: 		rapid_routing_param.F90 rapid_var.mod
	${FLINKER} -c rapid_routing_param.F90 ${PETSC_FC_INCLUDES}

rapid_obs_mat.o: 		rapid_obs_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_obs_mat.F90 ${PETSC_FC_INCLUDES}

rapid_net_mat_brk.o: 		rapid_net_mat_brk.F90 rapid_var.mod
	${FLINKER} -c rapid_net_mat_brk.F90 ${PETSC_FC_INCLUDES}

rapid_net_mat.o: 		rapid_net_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_net_mat.F90 ${PETSC_FC_INCLUDES}

rapid_kf_obs_mat.o:  rapid_kf_obs_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_kf_obs_mat.F90 ${PETSC_FC_INCLUDES}

rapid_run2strm_mat_smpl.o:  rapid_run2strm_mat_smpl.F90 rapid_var.mod
	${FLINKER} -c rapid_run2strm_mat_smpl.F90 ${PETSC_FC_INCLUDES}

rapid_runoff2streamflow_mat.o:  rapid_runoff2streamflow_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_runoff2streamflow_mat.F90 ${PETSC_FC_INCLUDES}

rapid_mus_mat.o: 		rapid_mus_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_mus_mat.F90 ${PETSC_FC_INCLUDES}

rapid_hsh_mat.o: 		rapid_hsh_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_hsh_mat.F90 ${PETSC_FC_INCLUDES}

rapid_get_Qdam.o: 		rapid_get_Qdam.F90 rapid_var.mod 
	${FLINKER} -c rapid_get_Qdam.F90 ${PETSC_FC_INCLUDES}

rapid_set_Qext0.o: 		rapid_set_Qext0.F90 rapid_var.mod 
	${FLINKER} -c rapid_set_Qext0.F90 ${PETSC_FC_INCLUDES}

rapid_close_Qfor_file.o: 	rapid_close_Qfor_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qfor_file.F90

rapid_close_Qhum_file.o: 	rapid_close_Qhum_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qhum_file.F90

rapid_close_Qobs_file.o: 	rapid_close_Qobs_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qobs_file.F90

rapid_close_Vlat_file.o: 	rapid_close_Vlat_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Vlat_file.F90 ${NETCDF_INCLUDE} 

rapid_close_Qfinal_file.o: 	rapid_close_Qfinal_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qfinal_file.F90 ${NETCDF_INCLUDE} 

rapid_close_Qinit_file.o: 	rapid_close_Qinit_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qinit_file.F90 ${NETCDF_INCLUDE} 

rapid_close_Qout_file.o: 	rapid_close_Qout_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_Qout_file.F90 ${NETCDF_INCLUDE} 

rapid_close_V_file.o: 		rapid_close_V_file.F90 rapid_var.mod
	${FLINKER} -c rapid_close_V_file.F90 ${NETCDF_INCLUDE} 

rapid_meta_Vlat_file.o: 	rapid_meta_Vlat_file.F90 rapid_var.mod
	${FLINKER} -c rapid_meta_Vlat_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_uq.o: 	rapid_uq.F90 rapid_var.mod
	${FLINKER} -c rapid_uq.F90 ${PETSC_FC_INCLUDES}

rapid_read_Qfor_file.o: 	rapid_read_Qfor_file.F90 rapid_var.mod
	${FLINKER} -c rapid_read_Qfor_file.F90 ${PETSC_FC_INCLUDES}

rapid_read_Qhum_file.o: 	rapid_read_Qhum_file.F90 rapid_var.mod
	${FLINKER} -c rapid_read_Qhum_file.F90 ${PETSC_FC_INCLUDES}

rapid_read_Qobs_file.o: 	rapid_read_Qobs_file.F90 rapid_var.mod
	${FLINKER} -c rapid_read_Qobs_file.F90 ${PETSC_FC_INCLUDES}

rapid_read_Qinit_file.o: 	rapid_read_Qinit_file.F90 rapid_var.mod
	${FLINKER} -c rapid_read_Qinit_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_read_Vlat_file.o: 	rapid_read_Vlat_file.F90 rapid_var.mod
	${FLINKER} -c rapid_read_Vlat_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_write_Qfinal_file.o: 	rapid_write_Qfinal_file.F90 rapid_var.mod
	${FLINKER} -c rapid_write_Qfinal_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_write_Qout_file.o: 	rapid_write_Qout_file.F90 rapid_var.mod
	${FLINKER} -c rapid_write_Qout_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_write_V_file.o: 		rapid_write_V_file.F90 rapid_var.mod
	${FLINKER} -c rapid_write_V_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_open_Qfor_file.o: 	rapid_open_Qfor_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qfor_file.F90 

rapid_open_Qhum_file.o: 	rapid_open_Qhum_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qhum_file.F90 

rapid_open_Qobs_file.o: 	rapid_open_Qobs_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qobs_file.F90 

rapid_open_Vlat_file.o: 	rapid_open_Vlat_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Vlat_file.F90 ${NETCDF_INCLUDE}

rapid_open_Qfinal_file.o: 	rapid_open_Qfinal_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qfinal_file.F90 ${NETCDF_INCLUDE}

rapid_open_Qinit_file.o: 	rapid_open_Qinit_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qinit_file.F90 ${NETCDF_INCLUDE}

rapid_open_Qout_file.o: 	rapid_open_Qout_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_Qout_file.F90 ${NETCDF_INCLUDE}

rapid_open_V_file.o: 		rapid_open_V_file.F90 rapid_var.mod
	${FLINKER} -c rapid_open_V_file.F90 ${NETCDF_INCLUDE}

rapid_create_Qfinal_file.o: 	rapid_create_Qfinal_file.F90 rapid_var.mod
	${FLINKER} -c rapid_create_Qfinal_file.F90 ${NETCDF_INCLUDE}

rapid_create_Qout_file.o: 	rapid_create_Qout_file.F90 rapid_var.mod
	${FLINKER} -c rapid_create_Qout_file.F90 ${NETCDF_INCLUDE}

rapid_create_V_file.o: 		rapid_create_V_file.F90 rapid_var.mod
	${FLINKER} -c rapid_create_V_file.F90 ${NETCDF_INCLUDE}

rapid_create_obj.o: 		rapid_create_obj.F90 rapid_var.mod
	${FLINKER} -c rapid_create_obj.F90 ${PETSC_FC_INCLUDES}

rapid_arrays.o:			rapid_arrays.F90 rapid_var.mod
	${FLINKER} -c rapid_arrays.F90 ${PETSC_FC_INCLUDES}
	
rapid_read_namelist.o:		rapid_read_namelist.F90 rapid_var.mod
	${FLINKER} -c rapid_read_namelist.F90

rapid_kf_update.o: 		rapid_kf_update.F90 rapid_var.mod
	${FLINKER} -c rapid_kf_update.F90 ${PETSC_FC_INCLUDES}

rapid_kf_cov_mat.o: 		rapid_kf_cov_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_kf_cov_mat.F90 ${PETSC_FC_INCLUDES}

rapid_cov_mat.o: 		rapid_cov_mat.F90 rapid_var.mod
	${FLINKER} -c rapid_cov_mat.F90 ${PETSC_FC_INCLUDES}
	
rapid_var.o rapid_var.mod:	rapid_var.F90
	${FLINKER} -c rapid_var.F90 ${PETSC_FC_INCLUDES} 

	
#-------------------------------------------------------------------------------
#Clean
#-------------------------------------------------------------------------------
clean::
	${RM} *.o *.mod rapid ../tst/rapid


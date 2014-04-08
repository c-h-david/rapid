#*******************************************************************************
#PETSc and TAO rules and variables (where environment variables and options are)
#*******************************************************************************

#-------------------------------------------------------------------------------
#Default RAPID - includes optimization with TAO 
#-------------------------------------------------------------------------------
FPPFLAGS=
include ${TAO_DIR}/conf/tao_base

#-------------------------------------------------------------------------------
#If want to use RAPID without TAO, in which case the optimization is unavailable
#-------------------------------------------------------------------------------
#FPPFLAGS=-D NO_TAO
#include ${PETSC_DIR}/conf/variables
#include ${PETSC_DIR}/conf/rules


#*******************************************************************************
#Location of netCDF include and lib directories
#*******************************************************************************
NETCDF_LIB=-L ${TACC_NETCDF_LIB} -lnetcdf
NETCDF_INCLUDE=-I ${TACC_NETCDF_INC}


#*******************************************************************************
#makefile instructions 
#*******************************************************************************

#-------------------------------------------------------------------------------
#Test that environment variables are properly read by make
#-------------------------------------------------------------------------------
dummy: 
	echo ${FLINKER} ${FPPFLAGS}

#-------------------------------------------------------------------------------
#Link RAPID
#-------------------------------------------------------------------------------
rapid:	rapid_main.o \
	rapid_init.o \
	rapid_read_namelist.o \
	rapid_create_obj.o \
	rapid_create_Qout_file.o \
	rapid_open_Qout_file.o \
	rapid_open_Vlat_file.o \
	rapid_open_Qobs_file.o \
	rapid_open_Qfor_file.o \
	rapid_write_Qout_file.o \
	rapid_read_Vlat_file.o \
	rapid_read_Qobs_file.o \
	rapid_read_Qfor_file.o \
	rapid_close_Qout_file.o \
	rapid_close_Vlat_file.o \
	rapid_close_Qobs_file.o \
	rapid_close_Qfor_file.o \
	rapid_get_Qdam.o \
	rapid_net_mat.o \
	rapid_net_mat_brk.o \
	rapid_obs_mat.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_final.o \
	rapid_var.o
	-${FLINKER} ${FPPFLAGS} -o \
	rapid \
	rapid_main.o \
	rapid_init.o \
	rapid_read_namelist.o \
	rapid_create_obj.o \
	rapid_create_Qout_file.o \
	rapid_open_Qout_file.o \
	rapid_open_Vlat_file.o \
	rapid_open_Qobs_file.o \
	rapid_open_Qfor_file.o \
	rapid_write_Qout_file.o \
	rapid_read_Vlat_file.o \
	rapid_read_Qobs_file.o \
	rapid_read_Qfor_file.o \
	rapid_close_Qout_file.o \
	rapid_close_Vlat_file.o \
	rapid_close_Qobs_file.o \
	rapid_close_Qfor_file.o \
	rapid_get_Qdam.o \
	rapid_net_mat.o \
	rapid_net_mat_brk.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_obs_mat.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_final.o \
	rapid_var.o \
	${TAO_FORTRAN_LIB} ${TAO_LIB} ${PETSC_LIB} ${NETCDF_LIB}
	${RM} *.o *.mod 
	ln -s ../src/rapid ../run/rapid

#-------------------------------------------------------------------------------
#Compile RAPID
#-------------------------------------------------------------------------------
rapid_main.o: 	rapid_main.F90 rapid_var.o 
	-${FLINKER} ${FPPFLAGS} -c rapid_main.F90 ${PETSC_FC_INCLUDES} ${TAO_INCLUDE} ${NETCDF_INCLUDE}

rapid_final.o:		rapid_final.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_final.F90 ${PETSC_FC_INCLUDES}

rapid_destro_obj.o: 	rapid_destro_obj.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_destro_obj.F90 ${PETSC_FC_INCLUDES} ${TAO_INCLUDE}

rapid_phiroutine.o: 	rapid_phiroutine.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_phiroutine.F90 ${PETSC_FC_INCLUDES} ${TAO_INCLUDE} ${NETCDF_INCLUDE}

rapid_routing.o: 	rapid_routing.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_routing.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_init.o: 		rapid_read_namelist.o rapid_net_mat.o rapid_obs_mat.o \
                        rapid_routing_param.o rapid_create_obj.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_init.F90 ${PETSC_FC_INCLUDES}

rapid_routing_param.o: 	rapid_routing_param.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_routing_param.F90 ${PETSC_FC_INCLUDES}

rapid_obs_mat.o: 	rapid_obs_mat.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_obs_mat.F90 ${PETSC_FC_INCLUDES}

rapid_net_mat_brk.o: 	rapid_net_mat_brk.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_net_mat_brk.F90 ${PETSC_FC_INCLUDES}

rapid_net_mat.o: 	rapid_net_mat.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_net_mat.F90 ${PETSC_FC_INCLUDES}

rapid_get_Qdam.o: 	rapid_get_Qdam.F90 rapid_var.o 
	-${FLINKER} ${FPPFLAGS} -c rapid_get_Qdam.F90 ${PETSC_FC_INCLUDES}

rapid_close_Qfor_file.o: 	rapid_close_Qfor_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_close_Qfor_file.F90

rapid_close_Qobs_file.o: 	rapid_close_Qobs_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_close_Qobs_file.F90

rapid_close_Vlat_file.o: 	rapid_close_Vlat_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_close_Vlat_file.F90 ${NETCDF_INCLUDE} 

rapid_close_Qout_file.o: 	rapid_close_Qout_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_close_Qout_file.F90 ${NETCDF_INCLUDE} 

rapid_read_Qfor_file.o: 	rapid_read_Qfor_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_read_Qfor_file.F90 ${PETSC_FC_INCLUDES}

rapid_read_Qobs_file.o: 	rapid_read_Qobs_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_read_Qobs_file.F90 ${PETSC_FC_INCLUDES}

rapid_read_Vlat_file.o: 	rapid_read_Vlat_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_read_Vlat_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_write_Qout_file.o: 	rapid_write_Qout_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_write_Qout_file.F90 ${PETSC_FC_INCLUDES} ${NETCDF_INCLUDE}

rapid_open_Qfor_file.o: 	rapid_open_Qfor_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_open_Qfor_file.F90 

rapid_open_Qobs_file.o: 	rapid_open_Qobs_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_open_Qobs_file.F90 

rapid_open_Vlat_file.o: 	rapid_open_Vlat_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_open_Vlat_file.F90 ${NETCDF_INCLUDE}

rapid_open_Qout_file.o: 	rapid_open_Qout_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_open_Qout_file.F90 ${NETCDF_INCLUDE}

rapid_create_Qout_file.o: 	rapid_create_Qout_file.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_create_Qout_file.F90 ${NETCDF_INCLUDE}

rapid_create_obj.o: 	rapid_create_obj.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_create_obj.F90 ${PETSC_FC_INCLUDES} ${TAO_INCLUDE}

rapid_read_namelist.o:	rapid_read_namelist.F90 rapid_var.o
	-${FLINKER} ${FPPFLAGS} -c rapid_read_namelist.F90
	
rapid_var.o:	rapid_var.F90
	-${FLINKER} ${FPPFLAGS} -c rapid_var.F90 ${PETSC_FC_INCLUDES} ${TAO_INCLUDE} 
	
#-------------------------------------------------------------------------------
#Clean
#-------------------------------------------------------------------------------
clean::
	${RM} *.o *.mod rapid ../run/rapid

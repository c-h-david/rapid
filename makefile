include ${TAO_DIR}/bmake/tao_common


rapid:	rapid_main.o \
	rapid_create_obj.o \
	rapid_net_mat.o \
	rapid_obs_mat.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_var.o \
	tao_chkopts
	-${FLINKER} -o \
	rapid \
	rapid_main.o \
	rapid_create_obj.o \
	rapid_net_mat.o \
	rapid_routing.o \
	rapid_routing_param.o \
	rapid_obs_mat.o \
	rapid_phiroutine.o \
	rapid_destro_obj.o \
	rapid_var.o \
	${TAO_FORTRAN_LIB} ${TAO_LIB} ${PETSC_LIB} -L ${TACC_NETCDF_LIB} -lnetcdf
	${RM} rapid_main.o

dummy: 
	echo ${PETSC_FORTRAN_LIB}

rapid_main.o: 	rapid_main.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_main.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE} \
	-I ${TACC_NETCDF_INC}

rapid_destro_obj.o: 	rapid_destro_obj.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_destro_obj.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE}

rapid_phiroutine.o: 	rapid_phiroutine.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_phiroutine.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE} \
	-I ${TACC_NETCDF_INC}

rapid_routing.o: 	rapid_routing.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_routing.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE} \
	-I ${TACC_NETCDF_INC}

rapid_routing_param.o: 	rapid_routing_param.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_routing_param.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE}

rapid_obs_mat.o: 	rapid_obs_mat.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_obs_mat.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE}

rapid_net_mat.o: 	rapid_net_mat.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_net_mat.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE}

rapid_create_obj.o: 	rapid_create_obj.F90 rapid_var.o tao_chkopts
	-${FLINKER} -c rapid_create_obj.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE}

rapid_var.o:	rapid_var.F90 tao_chkopts
	-${FLINKER} -c rapid_var.F90 ${PETSC_INCLUDE} ${TAO_INCLUDE} 
	
clean::
	rm -f *.o *.mod rapid


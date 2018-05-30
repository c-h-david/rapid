!*******************************************************************************
!Module - rapid_var
!*******************************************************************************
module rapid_var

!Purpose:
!Module where all the variables are defined. 
!Author: 
!Cedric H. David, 2008-2018.

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "petsc/finclude/petscsys.h"       
!base PETSc routines
#include "petsc/finclude/petscvec.h"  
#include "petsc/finclude/petscvec.h90"
!vectors, and Fortran90-specific vectors 
#include "petsc/finclude/petscmat.h"    
!matrices
#include "petsc/finclude/petscksp.h"    
!Krylov subspace methods
#include "petsc/finclude/petscpc.h"     
!preconditioners
#include "petsc/finclude/petscviewer.h"
!viewers (allows writing results in file for example)
!#include "petsc/finclude/petsclog.h" 
!Profiling log
#include "petsc/finclude/petsctao.h" 
!!TAO solver


!*******************************************************************************
!Declaration of variables - runtime options
!*******************************************************************************
logical :: BS_opt_Qinit
!.false. --> no read initial flow    .true. --> read initial flow
logical :: BS_opt_Qfinal
!.false. --> no write final flow     .true. --> write final flow 
logical :: BS_opt_V
!.false. --> no compute volume       .true. --> compute volume
logical :: BS_opt_hum
!.false. --> no human-induced flows  .true. --> human-induced flows
logical :: BS_opt_for
!.false. --> no forcing              .true. --> forcing
logical :: BS_opt_dam
!.false. --> no dam model used       .true. --> dam model used
logical :: BS_opt_influence
!.false. --> no output influence     .true. --> output influence
logical :: BS_opt_uq
!.false. --> no uncertainty quantif. .true. --> uncertainty quantif.
PetscInt :: IS_opt_routing
!1       --> matrix-based Muskingum  2      --> traditional Muskingum
!3       --> Transbnd. matrix-based  4      --> Muskingum operator
PetscInt :: IS_opt_run
!1       --> regular run             2      --> parameter optimization
PetscInt :: IS_opt_phi
!1       --> phi1                    2      --> phi2


!*******************************************************************************
!Declaration of variables - input and output files
!*******************************************************************************
character(len=200) :: rapid_connect_file
!unit 10 - file with connectivity information using RAPID connectivity format
character(len=200) :: riv_bas_id_file
!unit 11 - file with all the IDs of the reaches in _riv considered
character(len=200) :: obs_tot_id_file
!unit 12 - file with all the IDs of the all reaches with gage measurements
character(len=200) :: obs_use_id_file
!unit 13 - file with all the IDs of the reaches used
character(len=200) :: hum_tot_id_file
!unit 14 - file with all the IDs of the reaches with human-induced flow added
character(len=200) :: hum_use_id_file
!unit 15 - file with all the IDs of the reaches used
character(len=200) :: for_tot_id_file
!unit 16 - file with all the IDs where flows can be used as forcing to their 
!corresponding downstream reach  
character(len=200) :: for_use_id_file
!unit 17 - file with all the IDs of the reaches used 
character(len=200) :: dam_tot_id_file
!unit 18 - file with all the IDs of the reaches where the dam model runs and 
!flows to their corresponding downstream reach  
character(len=200) :: dam_use_id_file
!unit 19 - file with all the IDs of the reaches used

character(len=200) :: k_file
!unit 20 - file with values for k (possibly from previous param. estim.)
character(len=200) :: x_file
!unit 21 - file with values for x (possibly from previous param. estim.)
character(len=200) :: kfac_file  
!unit 22 - file with kfac for all reaches of the domain
character(len=200) :: xfac_file
!unit 23 - file with xfac for all reaches of the domain

character(len=200) :: Qinit_file
!unit 30 - file where initial flowrates can be stored to run the model with them
character(len=200) :: Qfinal_file
!unit 31 - file where final flowrates can be stored at the end of model run 
character(len=200) :: Vlat_file

character(len=200) :: Qobs_file
!unit 33 - file where the flowrates observations are given
character(len=200) :: Qfor_file
!unit 34 - file where forcing flowrates are stored.  Forcing is taken as the
!flow coming from upstream reach.
character(len=200) :: Qobsbarrec_file
!unit 35 - file where the reciprocal (1/xi) of the average obs are stored.
character(len=200) :: Qhum_file
!unit 36 - file where human-induced flowrates are stored.  These flows are added 
!upstream.

character(len=200) :: babsmax_file
!unit 42 - file where the maximum of the absolute values of the right-hand-side
!are stored
character(len=200) :: QoutRabsmin_file
!unit 43 - file where the minimum of the absolute values of the instantaneous 
!flows are stored 
character(len=200) :: QoutRabsmax_file
!unit 44 - file where the maximum of the absolute values of the instantaneous 
!flows are stored 
character(len=200) :: Qout_file
!        - file where the flow of water at the outlet of each reach are stored
character(len=200) :: V_file
!        - file where the volume of water in each reach are stored


!*******************************************************************************
!Declaration of variables - temporal parameters
!*******************************************************************************
PetscScalar :: ZS_TauM
!Duration of main procedure, in seconds
PetscScalar :: ZS_dtM
!Time step of main procedure, in seconds
PetscInt :: IS_M
!Number of time steps within the main precedure
PetscInt :: JS_M
!Index of main procedure 

PetscScalar :: ZS_TauO
!Duration of optimization procedure, in seconds
PetscScalar :: ZS_dtO
!Time step of optimization procedure, in seconds
PetscInt :: IS_O
!Number of time steps within the optimization precedure
PetscInt :: JS_O
!Index of optimization procedure 

PetscScalar :: ZS_TauR
!Duration of river routing procedure, in seconds
PetscScalar :: ZS_dtR  
!Time step of river routing procedure, in seconds  
PetscInt :: IS_R
!Number of time steps within the river routing procedure
PetscInt :: JS_R
!Index of river routing procedure

PetscScalar :: ZS_dtF
!Time step of forcing data, in seconds  
PetscScalar :: ZS_dtH
!Time step of human-induced data, in seconds  

PetscInt :: IS_RpO, JS_RpO
!Number routing procedures needed per optimization time step, and index
PetscInt :: IS_RpM, JS_RpM
!Number routing procedures needed per main time step, and index 
PetscInt :: IS_RpF
!Number routing procedures needed per forcing time step 
PetscInt :: IS_RpH
!Number routing procedures needed per human-induced time step


!*******************************************************************************
!Declaration of variables - River flow variables
!*******************************************************************************
PetscInt :: IS_riv_tot,JS_riv_tot,JS_riv_tot2
!total number of river reaches, corresponds to the size of rapid_connect_file
PetscInt :: IS_riv_bas,JS_riv_bas,JS_riv_bas2
!size of the matrix and the vectors in this _riv, corresponds to the number of
!reaches in the _riv
PetscInt, dimension(:), allocatable :: IV_riv_tot_id
!unique IDs of reaches in rapid_connect_file
PetscInt, dimension(:), allocatable :: IV_down
!vector of the downstream river reach of each river reach
PetscInt, dimension(:), allocatable :: IV_nbup
!vector of the number of direct upstream river reach of each river reach 
PetscInt :: IS_max_up
!maximum number of upstream river reaches for each river reach
PetscInt, dimension(:,:), allocatable :: IM_up
!matrix with the ID of the upstream river reaches of each river reach
PetscInt :: JS_up
!JS_up for the corresponding upstream reaches
PetscInt :: IS_row,IS_col
!index of rows and columns used to fill up the network matrix
PetscInt,dimension (:,:), allocatable :: IM_index_up
!matrix with the index of the upstream river reaches of each river reach
!index goes from 1 to IS_riv_bas 
PetscInt, dimension(:),allocatable :: IV_riv_bas_id
!unique IDs in riv_bas_id_file, of length IS_riv_bas
PetscInt, dimension(:), allocatable :: IV_riv_index
!indexes (Fortran, 1-based) of the reaches in the _riv within the whole network
!size IS_riv_bas
PetscInt,dimension(:), allocatable :: IV_riv_loc1
!vector giving the zero-base index corresponding to the river reaches within 
!the _riv studied only, to be used in VecSetValues. size IS_riv_bas
Mat :: ZM_hsh_tot
!flat matrix with size IS_riv_id_max*ncore that serves a hashtable-like purpose 
!in which the index over the domain (JS_riv_tot) is stored at the location of 
!each reach ID. Each row contains the exact same data.
Mat :: ZM_hsh_bas
!flat matrix with size IS_riv_id_max*ncore that serves a hashtable-like purpose 
!in which the index over the basin (JS_riv_bas) is stored at the location of 
!each reach ID. Each row contains the exact same data.
PetscInt :: IS_riv_id_max=1000000000
!Maximum value allowed for the unique integer IDs corresponding to each reach

!*******************************************************************************
!Declaration of variables - Observation flow variables
!*******************************************************************************
PetscInt :: IS_obs_tot, JS_obs_tot
!total number of reaches that have observations (gaged reaches), corresponds to
!the number of lines in obs_tot_id_file 
PetscInt :: IS_obs_use, JS_obs_use
!Number of gages available in obs_use_id_file
PetscInt :: IS_obs_bas, JS_obs_bas
!Number of gages within _riv studied.  Will be calculated based on 
!obs_tot_id_file, obs_use_id_file and riv_bas_id_file
PetscInt, dimension(:), allocatable :: IV_obs_tot_id
!vector where are stored the river ID of each gage available
PetscInt, dimension(:), allocatable :: IV_obs_use_id
!vector where are stored the river ID of each gage used in current run
PetscInt, allocatable, dimension(:) :: IV_obs_index
!vector where the Fortran 1-based indexes of the gages within the Qobs_file. 
!Will be allocated size IS_obs_bas
PetscInt, allocatable, dimension(:) :: IV_obs_loc1
!vector where the C (0-based) vector indexes of where gages are. This is 
!within the _riv only, not all domain. Will be used in VecSet.  Will be 
!allocated size IS_obs_bas


!*******************************************************************************
!Declaration of variables - Human-induced flow variables
!*******************************************************************************
PetscInt :: IS_hum_tot, JS_hum_tot
!total number of reaches where human-induced flow data are available. 
PetscInt :: IS_hum_use, JS_hum_use
!total number of reaches where human-induced will be used if in sub_riv
PetscInt :: IS_hum_bas, JS_hum_bas
!number of reaches with human-induced flow, within _riv. Calculated on the fly
!from hum_tot_if_file, hum_use_id_file and riv_bas_id_file
PetscInt, dimension(:), allocatable :: IV_hum_tot_id
!IDs of the reaches where human-induced flow data are available
PetscInt, dimension(:), allocatable :: IV_hum_use_id
!IDs of the reaches where human-induced flow data will be used if in sub_riv
PetscInt, dimension(:), allocatable :: IV_hum_bas_id
!IDs of the reaches where human-indeced flow data to be used is in sub_riv
PetscInt, allocatable, dimension(:) :: IV_hum_index
!vector where the Fortran 1-based indexes of the human-induced flow data are 
!stored. This is of size IS_hum_bas and its elements belong to [1,IS_hum_tot]. 
PetscInt, allocatable, dimension(:) :: IV_hum_loc1
!vector where the C (0-based) vector indexes of where the above human-induced 
!flow data are going to be applied. This is of size IS_hum_bas and its elements 
!belong to [0,IS_riv_bas-1]. Applied on the river ID itself.


!*******************************************************************************
!Declaration of variables - Forcing flow variables
!*******************************************************************************
PetscInt :: IS_for_tot, JS_for_tot
!total number of reaches where forcing flow data are available. 
PetscInt :: IS_for_use, JS_for_use
!total number of reaches where forcing will be used if in sub_riv
PetscInt :: IS_for_bas, JS_for_bas
!number of reaches forced by observations, within _riv. Calculated on the fly
!from for_tot_id_file, for_use_id_file and riv_bas_id_file
PetscInt, dimension(:), allocatable :: IV_for_tot_id
!IDs of the reaches where forcing flow data are available
PetscInt, dimension(:), allocatable :: IV_for_use_id
!IDs of the reaches where forcing flow data will be used if in sub_riv
PetscInt, dimension(:), allocatable :: IV_for_bas_id
!IDs of the reaches where forcing flow data to be used is in sub_riv
PetscInt, allocatable, dimension(:) :: IV_for_index
!vector where the Fortran 1-based indexes of the forcing flow data are 
!available. This is of size IS_for_bas and its elements belong to [1,IS_for_tot] 
PetscInt, allocatable, dimension(:) :: IV_for_loc2
!vector where the C (0-based) vector indexes of where the above forcing 
!flow data are going to be applied. This is of size IS_for_bas and its elements 
!belong to [0,IS_riv_bas-1]. Applied on the river ID downstream.


!*******************************************************************************
!Declaration of variables - dam model flow variables
!*******************************************************************************
PetscInt :: IS_dam_tot, JS_dam_tot
!total number of reaches where dam model flow data are available. 
PetscInt :: IS_dam_use, JS_dam_use
!total number of reaches where dam model will be used if in sub_riv
PetscInt :: IS_dam_bas, JS_dam_bas
!number of reaches forced by observations, within _riv. Calculated on the fly
!from dam_tot_id_file, dam_use_id_file and riv_bas_id_file. 
PetscInt, dimension(:), allocatable :: IV_dam_tot_id
!IDs of the reaches where dam model flow data are available
PetscInt, dimension(:), allocatable :: IV_dam_use_id
!IDs of the reaches where dam model flow data will be used if in sub_riv
PetscInt, dimension(:), allocatable :: IV_dam_bas_id
!IDs of the reaches where dam model flow data to be used is in sub_riv
PetscInt, allocatable, dimension(:) :: IV_dam_index
!vector where the Fortran 1-based indexes of the dam model flow data are 
!available. This is of size IS_dam_bas and its elements belong to [1,IS_dam_tot] 
PetscInt, allocatable, dimension(:) :: IV_dam_loc2
!vector where the C (0-based) vector indexes of where the above dam model
!flow data are going to be applied. This is of size IS_dam_bas and its elements 
!belong to [0,IS_riv_bas-1]. Applied on the river ID downstream.
PetscInt, allocatable, dimension(:) :: IV_dam_pos
!vector where the Fortran 1-based vector indexes of where flows will be given to 
!the above dam model. This is of size IS_dam_tot and its elements belong to 
![1,IS_riv_bas] except when a dam ID is outside of basin studied where it is 0. 
!Applied on the river ID itself.

PetscScalar, allocatable, dimension(:) :: ZV_Qin_dam,ZV_Qin_dam_prev
PetscScalar, allocatable, dimension(:) :: ZV_Qout_dam,ZV_Qout_dam_prev
PetscScalar, allocatable, dimension(:) :: ZV_Qin_dam0,ZV_Qout_dam0
!Fortran vectors where the inflows and outflows for the dam module are saved. 
!These will be allocated to size IS_dam_tot


!*******************************************************************************
!Declaration of variables - Network matrix variables and routing variables
!*******************************************************************************
Mat :: ZM_Net
!Network matrix
Mat :: ZM_A
!Matrix used to solve linear system 
Mat :: ZM_T
!Transboundary matrix
Mat :: ZM_TC1
!Matrix used as a trick to solve linear system faster
Logical :: BS_logical
!Boolean used during network matrix creation to give warnings if connectivity pb
Mat :: ZM_M
!Muskingum operator: (I-C1*N)^(-1)
PetscScalar :: ZS_threshold
!Used to limit the storage of the Muskingum operator by removing small elements

Vec :: ZV_k,ZV_x
!Muskingum expression constants vectors, k in seconds, x has no dimension
Vec :: ZV_p, ZV_pnorm,ZV_pfac
!vector of the problem parameters, p=(k,x).  normalized version and 
!corresponding factors p=pnorm*pfac
Vec :: ZV_C1,ZV_C2,ZV_C3,ZV_Cdenom 
!Muskingum method constants (last is the common denominator, for calculations)
Vec :: ZV_b,ZV_babsmax,ZV_bhat
!Used for linear system A*Qout=b

!Input variables (contribution)
Vec :: ZV_Qext,ZV_Qfor,ZV_Qlat,ZV_Qhum,ZV_Qdam
!flowrates Qext is the sum of forced and lateral
Vec :: ZV_Vext,ZV_Vfor,ZV_Vlat 
!volumes (same as above)

!Main only variables
Vec :: ZV_QoutM,ZV_QoutinitM,ZV_QoutprevM,ZV_QoutbarM
Vec :: ZV_VM,ZV_VinitM,ZV_VprevM,ZV_VbarM

!Optimization only variables
Vec :: ZV_QoutO,ZV_QoutinitO,ZV_QoutprevO,ZV_QoutbarO
Vec :: ZV_VO,ZV_VinitO,ZV_VprevO,ZV_VbarO

!Routing only variables
Vec :: ZV_QoutR,ZV_QoutinitR,ZV_QoutprevR,ZV_QoutbarR,ZV_QoutRhat,ZV_QinbarR
Vec :: ZV_QoutRabsmin,ZV_QoutRabsmax
Vec :: ZV_VR,ZV_VinitR,ZV_VprevR,ZV_VbarR
Vec :: ZV_VoutR


!*******************************************************************************
!Declaration of variables - Observation matrix and optimization variables
!*******************************************************************************
Mat :: ZM_Obs
!Observation matrix
Vec :: ZV_Qobs
!Observation vector
PetscScalar :: ZS_norm
!norm of matrix ZM_Obs, used to calculate the number of gaging stations used

PetscScalar :: ZS_phi,ZS_phitemp
!cost function
PetscInt :: IS_Iter
!number of iterations needed for optimization procedure to end
Vec :: ZV_temp1,ZV_temp2
!temporary vectors, used for calculations
PetscScalar :: ZS_phifac
PetscInt :: IS_strt_opt
!first time step at which Vlat data is read during optimization

Vec :: ZV_kfac
!Vector of size IS_riv_bas a multiplication factor for k for all river reaches
!in _riv
Vec :: ZV_Qobsbarrec
!Vector with the reciprocal (1/xi) of the average observations

PetscScalar :: ZS_knorm, ZS_xnorm
!constants (k,x) in Muskingum expression, normalized
PetscScalar :: ZS_knorm_init, ZS_xnorm_init
!constants (k,x) in Muskingum expression, normalized, initial values for opt.
PetscScalar, parameter :: ZS_kfac=3600,ZS_xfac=0.1
!corresponding factors, k in seconds, x has no dimension
PetscScalar :: ZS_k,ZS_x
!constants (k,x) in Muskingum expression.  k in seconds, x has no dimension


!*******************************************************************************
!Declaration of variables - routing parameters and initial values 
!*******************************************************************************
PetscScalar :: ZS_V0=10000,ZS_Qout0=0
!values to be used in the intitial state of V and Qout for river routing
!initial volume for each reach (m^3), initial outflow for each reach (m^3/s)


!*******************************************************************************
!Declaration of variables - Uncertainty quantification
!*******************************************************************************
PetscScalar :: ZS_alpha_uq
!Proportion (belongs to [0, 1]) of the variance in outflow that is attributed to 
!bias in runoff. The remainder of the variance is attributed to random errors at
!the reach level

Vec :: ZV_sQlat, ZV_vQlat, ZV_sQout, ZV_vQout
!Vectors of size IS_riv_bas storing the standard error and the variance of Qlat 
!and Qout 
PetscScalar,dimension(:), allocatable :: ZV_riv_tot_sQlat, ZV_riv_tot_vQlat
!Vectors of size IS_riv_tot storing standard error and variance of Qlat
PetscScalar,dimension(:), allocatable :: ZV_riv_bas_sQout, ZV_riv_bas_vQout
!Vectors of size IS_riv_bas storing standard error and variance of Qout
PetscScalar,dimension(:), allocatable :: ZV_riv_bas_sV, ZV_riv_bas_vV
!Vectors of size IS_riv_bas storing standard error and variance of V


!*******************************************************************************
!Declaration of variables - PETSc specific objects and variables
!*******************************************************************************
PetscErrorCode :: ierr
!needed for error check of PETSc functions
KSP :: ksp
!object used for linear system solver
PC :: pc
!preconditioner object
PetscMPIInt :: rank
!integer where the number of each processor is stored, 0 will be main processor 
PetscMPIInt :: ncore
!integer where the number of cores used is stored 
VecScatter :: vecscat
!Allows for scattering and gathering vectors from in parallel environement
PetscLogEvent :: stage
!Stage for investigating performance

PetscInt :: IS_ksp_iter, IS_ksp_iter_max
!integer where the number of iterations in KSP is solved
PetscInt :: IS_one=1
!integer of value 1.  to be used in MatSetValues and VecSet. Directly using 
!the value 1 in the functions crashes PETSc
PetscScalar :: ZS_one=1
!Scalars of values 1 and 0, same remark as above
PetscScalar :: ZS_val
!Temporary scalar used to store the results of MatGetValues()
Vec :: ZV_one
!vector with only ones, useful for creation of matrices here
Vec :: ZV_SeqZero
!Sequential vector of size IS_riv_bas, allows for gathering data on zeroth 
!precessor before writing in file

PetscScalar,dimension(:), allocatable :: ZV_read_riv_tot
!temp vector that stores information from a 'read', before setting the value
!in the object, this vector has the size of the total number of reaches
PetscScalar,dimension(:), allocatable :: ZV_read_obs_tot
!same as previous, with size IS_obs_tot
PetscScalar,dimension(:), allocatable :: ZV_read_hum_tot
!same as previous, with size IS_hum_tot
PetscScalar,dimension(:), allocatable :: ZV_read_for_tot
!same as previous, with size IS_for_tot
PetscScalar,dimension(:), allocatable :: ZV_read_dam_tot
!same as previous, with size IS_dam_tot
PetscScalar :: ZS_time1, ZS_time2, ZS_time3
!to estimate computing time

PetscScalar, pointer :: ZV_pointer(:)
!used to point to a PETSc vector and to output formatted as needed in a file
character(len=10) :: temp_char,temp_char2
!usefull to print variables on output.  write a variable in this character and
!then use PetscPrintf

PetscInt, dimension(:), allocatable :: IV_nz, IV_dnz, IV_onz
!number of nonzero elements per row for network matrix.  nz for sequential, dnz 
!and onz for distributed matrix (diagonal and off-diagonal elements)
PetscInt :: IS_ownfirst, IS_ownlast
!Ownership of each processor


!*******************************************************************************
!Declaration of variables - TAO specific objects and variables
!*******************************************************************************
Tao :: tao
!TAO solver object
Vec :: ZV_1stIndex, ZV_2ndIndex
!ZV_1stIndex=[1;0], ZV_2ndIndex=[0,1].  Used with VecDot to extract first and 
!second indexes of the vector of parameter


!*******************************************************************************
!Declaration of variables - netCDF variables
!*******************************************************************************
PetscInt :: IS_nc_status
PetscInt :: IS_nc_id_fil_Vlat,IS_nc_id_fil_Qout,IS_nc_id_fil_V,                &
            IS_nc_id_fil_Qinit,IS_nc_id_fil_Qfinal
PetscInt :: IS_nc_id_var_Vlat,IS_nc_id_var_Qout,IS_nc_id_var_rivid,            &
            IS_nc_id_var_V,IS_nc_id_var_time,IS_nc_id_var_lon,IS_nc_id_var_lat,&
            IS_nc_id_var_time_bnds,IS_nc_id_var_crs,                           &
            IS_nc_id_var_Vlat_err,IS_nc_id_var_Qout_err,IS_nc_id_var_V_err,    &
            IS_nc_id_var_Qinit,IS_nc_id_var_Qfinal
PetscInt :: IS_nc_id_dim_rivid,IS_nc_id_dim_time,IS_nc_id_dim_nv
PetscInt, parameter :: IS_nc_ndim=2
PetscInt, dimension(IS_nc_ndim) :: IV_nc_id_dim, IV_nc_start, IV_nc_count,     &
                                   IV_nc_count2


!*******************************************************************************
!Declaration of variables - Metadata variables
!*******************************************************************************
PetscInt, dimension(8) :: IV_now
!Integer array containing current time information
character(len=25) :: YV_now
!Character string containing current time information formatted using ISO 8601
character(len=30) :: YV_version
!Character string containing the version of RAPID 
character(len=100) :: YV_title
!Character string containing the title of simulation
character(len=100) :: YV_institution
!Character string containing the institution
character(len=100) :: YV_comment
!Character string containing the comment

character(len=100) :: YV_time_units
!Character string containing the units of time 
character(len=100) :: YV_crs_sma
!Character string containing the semi major axis of the spheroid
character(len=100) :: YV_crs_iflat
!Character string containing the inverse flattening of the spheroid

PetscScalar,dimension(:), allocatable :: ZV_riv_tot_lon, ZV_riv_tot_lat
PetscInt,dimension(:), allocatable :: IV_time
PetscInt,dimension(:,:), allocatable :: IM_time_bnds
PetscInt :: IS_time, JS_time


!*******************************************************************************
!Namelist
!*******************************************************************************
namelist /NL_namelist/                                                         &
                       BS_opt_Qinit,BS_opt_Qfinal,BS_opt_V,                    &
                       BS_opt_hum,BS_opt_for,BS_opt_dam,BS_opt_influence,      &
                       BS_opt_uq,                                              &
                       IS_opt_routing,IS_opt_run,IS_opt_phi,                   &
                       IS_riv_tot,rapid_connect_file,Vlat_file,IS_max_up,      &
                       iS_riv_bas,riv_bas_id_file,                             &
                       Qinit_file,Qfinal_file,                                 &
                       Qhum_file,                                              &
                       IS_hum_tot,hum_tot_id_file,                             &
                       IS_hum_use,hum_use_id_file,                             &
                       IS_for_tot,for_tot_id_file,                             &
                       Qfor_file,                                              &
                       IS_for_use,for_use_id_file,                             &
                       IS_dam_tot,dam_tot_id_file,                             &
                       IS_dam_use,dam_use_id_file,                             &
                       babsmax_file,QoutRabsmin_file,QoutRabsmax_file,         &
                       ZS_alpha_uq,                                            &
                       ZS_threshold,                                           &
                       k_file,x_file,Qout_file,V_file,                         &
                       kfac_file,xfac_file,ZS_knorm_init,ZS_xnorm_init,        &
                       IS_obs_tot,obs_tot_id_file,IS_obs_use,obs_use_id_file,  &
                       Qobs_file,Qobsbarrec_file,                              &
                       ZS_TauM,ZS_dtM,ZS_TauO,ZS_dtO,ZS_TauR,ZS_dtR,           &
                       ZS_dtF,ZS_dtH,                                          &
                       ZS_phifac,IS_strt_opt
 
character(len=200) :: namelist_file
!unit 88 - Namelist


!*******************************************************************************
!End module
!*******************************************************************************
end module rapid_var

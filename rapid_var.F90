!*******************************************************************************
!Module to declare variables
!*******************************************************************************
module rapid_var


!PURPOSE
!Module where all the variables are defined 
!Author: Cedric H. David, 2008 


implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "finclude/petscsys.h"       
!base PETSc routines
#include "finclude/petscvec.h"  
#include "finclude/petscvec.h90"
!vectors, and Fortran90-specific vectors 
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
!#include "finclude/petsclog.h" 
!Profiling log


!*******************************************************************************
!Declaration of variables - Basin variables and number of observed reaches
!*******************************************************************************
PetscInt,parameter :: IS_reachtot=24264!5175!68143!5175!182240
!total number of river reaches, corresponds to the size of the table Ficvid
PetscInt, parameter :: IS_reachbas=24264!5175!68143!5175!182240
!size of the matrix and the vectors in this basin, corresponds to the number of
!reaches in the basin
PetscInt :: JS_reachtot,JS_reachbas
PetscInt :: JS_reachtot2,JS_reachbas2
!JS_reachtot is index for all network and JS_reachbas for all river reaches in 
!considered basin only

PetscInt, dimension(IS_reachbas) :: IV_basin_id
!unique IDs in basin_id_file, of length IS_reachbas
integer*8, dimension(IS_reachbas) :: IV_basin_index
!indexes (Fortran, 1-based) of the reaches in the basin within the whole network
PetscInt,dimension(IS_reachbas) :: IV_basin_loc
!vector giving the zero-base index corresponding to the river reaches within 
!the basin studied only, to be used in VecSetValues

PetscInt, parameter :: IS_gagetot=291!36!289!294!32!36
!total number of reaches that have observations (gaged reaches), corresponds to
!the number of lines in gage_id_file 
PetscInt :: JS_gagetot
!loop index corresponding to the number of gaged reaches (IS_gagetot)

PetscInt, parameter :: IS_forcingtot=0!493!0!0!3!0!289
!total number of reaches that where forcing is available, corresponds to the 
!number of lines in forcingtot_id_file 
PetscInt :: JS_forcingtot
!loop index corresponding to the number of gaged reaches (IS_forcingtot)
PetscInt, parameter :: IS_forcinguse=0!1!3!0!3!0!4!0
!total number of reaches where forcing will be used if in basin considered
PetscInt :: JS_forcinguse


!*******************************************************************************
!Declaration of variables - input and output files
!*******************************************************************************
character(len=100) :: modcou_connect_file='./input_France/rapid_connect_France.csv'
!unit 10 - file with connectivity information following MODCOU notations
character(len=100) :: nhdplus_connect_file='./input_France/connect_France.csv' 
!unit 11 - file with connectivity information following NHDPlus notations
character(len=100) :: basin_id_file='./input_France/rivsurf_France.csv'
!unit 15 - file with all the IDs of the reaches used in subbasin considered
character(len=100) :: gage_id_file='./input_France/gage_id_1995_1996_full_nash.csv'
!unit 16 - file with all the IDs of the reaches that have gage measurements
character(len=100) :: forcingtot_id_file='./input_France/forcingtot_id_1995_1996_full.csv'
!unit 17 - file with the IDs where flows can be used as forcing to their 
!corresponding downstream reach  
character(len=100) :: forcinguse_id_file='./input_France/forcinguse_id_rhone_pougny.csv'
!unit 18 - file with the IDs of the reaches with forcing used 

character(len=100) :: k_file='./input_France/k_modcou_b.csv'
!unit 20 - file with values for k (possibly from previous param. estim.)
character(len=100) :: x_file='./input_France/x_modcou_b.csv'
!unit 21 - file with values for x (possibly from previous param. estim.)
character(len=100) :: kfac_file='./input_France/kfac_modcou_1km_hour.csv'   
!unit 22 - file with kfac for all reaches of the domain
character(len=100) :: xfac_file='' 
!unit 23 - file with xfac for all reaches of the domain

character(len=100) :: Qinit_file='./input_France/Qinit_93.csv'
!unit 30 - file where initial flowrates can be stored to run the model with them
character(len=100) :: m3_sur_file='./input_France/m3_riv_ksat_93.dat'
!unit 31 - file where the surface inflow volumes (forced) are given
character(len=100) :: m3_nc_file='./input_France/m3_riv_France_1995_2005_ksat_201101_c_zvol_ext.nc'

character(len=100) :: Qobs_file='./input_France/Qobs_1995_1996_full_nash_93.csv'
!unit 33 - file where the flowrates observations are given
character(len=100) :: Qfor_file='./input_France/Qfor_1995_1996_full_93.csv'    
!unit 34 - file where forcing flowrates are stored.  Forcing is taken as the
!flow coming from upstream reach.
character(len=100) :: Qobsbarrec_file='./input_France/Qobsbarrec_1995_1996_full_nash.csv'     
!unit 35 - file where the reciprocal (1/xi) of the average forcing are stored.

character(len=100) :: Qout_file='./'
!unit 40 - file where model-calculated flows are stored
character(len=100) :: V_file='./output/'
!unit 41 - file where model-calculated volumes are stored

character(len=100) :: Qout_nc_file='./output/Qout_France_201101_c_zvol_ext_366days_pb_dtR=1800s_nx.nc'


!*******************************************************************************
!Declaration of variables - routing parameters and initial values 
!*******************************************************************************
PetscScalar :: ZS_knorm, ZS_xnorm
!constants (k,x) in Muskingum expression, normalized
PetscScalar, parameter :: ZS_knorm_init=2, ZS_xnorm_init=3
!constants (k,x) in Muskingum expression, normalized, initial values for opt.
PetscScalar, parameter :: ZS_kfac=3600,ZS_xfac=0.1
!corresponding factors, k in seconds, x has no dimension
PetscScalar :: ZS_k,ZS_x
!constants (k,x) in Muskingum expression.  k in seconds, x has no dimension

PetscScalar :: ZS_V0=10000,ZS_Qout0=0
!values to be used in the intitial state of V and Qout for river routing
!initial volume for each reach (m^3), initial outflow for each reach (m^3/s)


!*******************************************************************************
!Declaration of variables - temporal parameters
!*******************************************************************************
PetscScalar, parameter :: ZS_TauM=3600*24*366!53!6!1460!182!365!100
!Duration of main procedure, in seconds
PetscScalar, parameter :: ZS_dtM=3600*24
!Time step of main procedure, in seconds
PetscInt, parameter :: IS_M=int(ZS_TauM/ZS_dtM)
!Number of time steps within the main precedure
PetscInt :: JS_M
!Index of main procedure 

PetscScalar, parameter :: ZS_TauO=3600*24*152
!Duration of optimization procedure, in seconds
PetscScalar, parameter :: ZS_dtO=3600*24
!Time step of optimization procedure, in seconds
PetscInt, parameter :: IS_O=int(ZS_TauO/ZS_dtO)
!Number of time steps within the optimization precedure
PetscInt :: JS_O
!Index of optimization procedure 

PetscScalar, parameter :: ZS_TauR=3600*3
!Duration of river routing procedure, in seconds
PetscScalar, parameter :: ZS_dtR=1800  
!Time step of river routing procedure, in seconds  
PetscInt, parameter :: IS_R=int(ZS_TauR/ZS_dtR)
!Number of time steps within the river routing procedure
PetscInt :: JS_R
!Index of river routing procedure

PetscInt, parameter :: IS_RpO=int(ZS_dtO/ZS_TauR)
!Number routing procedures needed per optimization time step 
PetscInt :: JS_RpO
!Index 

PetscInt, parameter :: IS_RpM=int(ZS_dtM/ZS_TauR)
!Number routing procedures needed per optimization time step 
PetscInt :: JS_RpM
!Index 


!*******************************************************************************
!Declaration of variables - Network matrix variables
!*******************************************************************************
Mat :: ZM_Net
!Network matrix
Logical :: BS_logical
!Boolean used during network matrix creation to give warnings if connectivity pb

!Variables for MODCOU network 
PetscInt, dimension(IS_reachtot) :: IV_down
!vector of the downstream river reach of each river reach (corresponds to ipere)
PetscInt, dimension(IS_reachtot) :: IV_nbup
!vector of the number of direct upstream river reach of each river reach 
!(corresponds to nbfils)
PetscInt, dimension(IS_reachtot,4) :: IM_up
!matrix with the ID of the upstream river reaches of each river reach (max 4)
PetscInt :: JS_up
!JS_up for the corresponding upstream reaches
PetscInt :: IS_row,IS_col
!index of rows and columns used to fill up the network matrix
PetscInt,dimension (IS_reachbas,4) :: IM_index_up
!matrix with the index of the upstream river reaches of each river reach (max 4)
!index goes from 1 to IS_reachbas 

!Variables for NHDPlus network
PetscInt, dimension(IS_reachtot) :: IV_connect_id
!unique IDs of reaches in nhdplus_connect_file
integer*8, dimension(IS_reachtot) :: IV_fromnode
!fromnode in nhdplus_connect_file.  Different type because very long integer
integer*8, dimension(IS_reachtot) :: IV_tonode
!tonode in nhdplus_connect_file
PetscInt, dimension(IS_reachtot) :: IV_diverg
!divergence flag in nhdplus_connect_file


!*******************************************************************************
!Declaration of variables - Observation matrix and optimization variables
!*******************************************************************************
Mat :: ZM_Obs
!Observation matrix
Vec :: ZV_Qobs
!Observation vector
PetscScalar :: ZS_norm
!norm of matrix ZM_Obs, used to calculate the number of gaging stations used

PetscInt :: IS_gagebas
!Number of gages within basin studied.  Will be calculated based on 
!gage_id_file and basin_id_file
PetscInt :: JS_gagebas
!Corresponding index

PetscInt, dimension(IS_gagetot) :: IV_gage_id
!vector were are stored the river ID of each gage
PetscInt, allocatable, dimension(:) :: IV_gage_index
!vector where the Fortran 1-based indexes of the gages within the Qobs_file. 
!Will be allocated size IS_gagebas
PetscInt, allocatable, dimension(:) :: IV_gage_loc
!vector where the C (0-based) vector indexes of where gages are. This is 
!within the basin only, not all domain. Will be used in VecSet.  Will be 
!allocated size IS_gagebas

PetscScalar :: ZS_phi,ZS_phitemp
!cost function
PetscInt :: IS_Iter
!number of iterations needed for optimization procedure to end
Vec :: ZV_temp1,ZV_temp2
!temporary vectors, used for calculations
PetscScalar, parameter :: ZS_phifac=1./1000

Vec :: ZV_kfac
!Vector of size IS_reachbas a multiplication factor for k for all river reaches
!in basin
Vec :: ZV_Qobsbarrec
!Vector with the reciprocal (1/xi) of the average observations
 

!*******************************************************************************
!Declaration of variables - Forcing variables
!*******************************************************************************
PetscInt :: IS_forcingbas
!number of reaches forced by observations, within basin. Calculated on the fly
!from forcing_id_file and basin_id_file
PetscInt :: JS_forcingbas
!corresponding index
PetscInt, dimension(IS_forcingtot) :: IV_forcingtot_id
!IDs of the reaches where forcing data are available
PetscInt, dimension(IS_forcinguse) :: IV_forcinguse_id
!IDs of the reaches where forcing date will be used 
PetscInt, allocatable, dimension(:) :: IV_forcing_index
!vector where the Fortran 1-based indexes of the forcing needed is stored 
!(useful for disconnected network or forcing by gage measurement).  used to 
!read forcing_file, the index is within the whole domain.  This is upstream
!of the missing connection
PetscInt, allocatable, dimension(:) :: IV_forcing_loc
!vector where the C (0-based) vector indexes of where the above forcing is going
!to be applied (calculated thanks to connectivity and basin_id tables).  This is 
!within the basin only, not all domain. Will be used in VecSet


!*******************************************************************************
!Declaration of variables - Routing matrices and vectors
!*******************************************************************************
Mat :: ZM_A
!Matrix used to solve linear system 
Vec :: ZV_k,ZV_x
!Muskingum expression constants vectors, k in seconds, x has no dimension
Vec :: ZV_p, ZV_pnorm,ZV_pfac
!vector of the problem parameters, p=(k,x).  normalized version and 
!corresponding factors p=pnorm*pfac
Vec :: ZV_C1,ZV_C2,ZV_C3,ZV_Cdenom 
!Muskingum method constants (last is the common denominator, for calculations)
Vec :: ZV_b,ZV_b1,ZV_b2,ZV_b3
!Used for linear system A*Qout=b, (b=b1+b2+b3) 

!Input variables (contribution)
Vec :: ZV_Qext,ZV_Qfor,ZV_Qlat
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
Vec :: ZV_QoutR,ZV_QoutinitR,ZV_QoutprevR,ZV_QoutbarR
Vec :: ZV_VR,ZV_VinitR,ZV_VprevR,ZV_VbarR
Vec :: ZV_VoutR


!*******************************************************************************
!Declaration of variables - PETSc and TAO specific objects
!*******************************************************************************
PetscErrorCode :: ierr
!needed for error check of PETSc functions
KSP :: ksp
!object used for linear system solver
PC :: pc
!preconditioner object
TAO_SOLVER :: tao
!TAO solver object
TAO_APPLICATION :: taoapp
!TAO application object
TaoTerminateReason :: reason
!TAO terminate reason object
PetscMPIInt :: rank
!integer where the number of each processor is stored, 0 will be main processor 
VecScatter :: vecscat
!Allows for scattering and gathering vectors from in parallel environement
PetscLogEvent :: stage
!Stage for investigating performance


!*******************************************************************************
!Declaration of variables - PETSc and TAO useful variables
!*******************************************************************************
PetscInt :: IS_one=1
!integer of value 1.  to be used in MatSetValues and VecSet. Directly using 
!the value 1 in the functions crashes PETSc
PetscScalar :: ZS_one=1
!Scalars of values 1 and 0, same remark as above
Vec :: ZV_one
!vector with only ones, useful for creation of matrices here
Vec :: ZV_SeqZero
!Sequential vector of size IS_reachbas, allows for gathering data on zeroth 
!precessor before writing in file
Vec :: ZV_1stIndex, ZV_2ndIndex
!ZV_1stIndex=[1;0], ZV_2ndIndex=[0,1].  Used with VecDot to extract first and 
!second indexes of the vector of parameter
PetscScalar,dimension(IS_reachtot) :: ZV_read_reachtot
!temp vector that stores information from a 'read', before setting the value
!in the object, this vector has the size of the total number of reaches
PetscScalar,dimension(IS_gagetot) :: ZV_read_gagetot
!same as previous, with size IS_gagetot
PetscScalar,dimension(IS_forcingtot) :: ZV_read_forcingtot
!same as previous, with size IS_forcingtot
PetscScalar :: ZS_time1, ZS_time2, ZS_time3

PetscScalar, pointer :: ZV_pointer(:)
!used to point to a PETSc vector and to output formatted as needed in a file
character(len=10) :: temp_char
!usefull to print variables on output.  write a variable in this character and
!then use PetscPrintf

PetscInt, dimension(IS_reachbas) :: IV_nz, IV_dnz, IV_onz
!number of nonzero elements per row for network matrix.  nz for sequential, dnz 
!and onz for distributed matrix (diagonal and off-diagonal elements)
PetscInt :: IS_ownfirst, IS_ownlast
!Ownership of each processor


!*******************************************************************************
!Declaration of variables - netCDF variables
!*******************************************************************************
PetscInt :: IS_nc_status
PetscInt :: IS_nc_id_fil_m3,IS_nc_id_fil_Qout
PetscInt :: IS_nc_id_var_m3,IS_nc_id_var_Qout,IS_nc_id_var_comid
PetscInt :: IS_nc_id_dim_comid,IS_nc_id_dim_time
PetscInt, parameter :: IS_nc_ndim=2
PetscInt, dimension(IS_nc_ndim) :: IV_nc_id_dim, IV_nc_start, IV_nc_count


end module rapid_var

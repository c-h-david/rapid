!*******************************************************************************
!subroutine create_petsc_objects 
!*******************************************************************************
subroutine rapid_create_obj 

!PURPOSE
!All PETSc and TAO objects need be created (requirement of both mathematical 
!libraries).  PETSc and TAO also need be initialized.  This is what's done here.
!Author: Cedric H. David, 2008 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   IS_reachbas,                                                &
                   ZM_Net,                                                     &
                   ZM_Obs,ZV_Qobs,ZV_temp1,ZV_temp2,ZV_kfac,                   &
                   ZM_A,                                                       &
                   ZV_k,ZV_x,ZV_p,ZV_pnorm,ZV_pfac,                            &
                   ZV_C1,ZV_C2,ZV_C3,ZV_Cdenom,                                &
                   ZV_b,ZV_b1,ZV_b2,ZV_b3,ZV_babsmax,                          &
                   ZV_Qext,ZV_Qfor,ZV_Qlat,                                    &
                   ZV_Vext,ZV_Vfor,ZV_Vlat,                                    &
                   ZV_VinitM,ZV_QoutinitM,ZV_QoutinitO,                        &
                   ZV_QoutbarO,                                                &
                   ZV_QoutR,ZV_QoutinitR,ZV_QoutprevR,ZV_QoutbarR,             &
                   ZV_VR,ZV_VinitR,ZV_VprevR,ZV_VbarR,ZV_VoutR,                &
                   ZV_Qobsbarrec,                                              &
                   ierr,ksp,tao,taoapp,reason,vecscat,ZV_SeqZero,              &
                   ZV_1stIndex,ZV_2ndIndex,ZV_pointer,ZS_one,ZV_one,IS_one


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
#include "finclude/tao_solver.h" 
!TAO solver


!*******************************************************************************
!Initialize PETSc and TAO, and create all the objects
!*******************************************************************************

!Initialize PETSc and TAO-------------------------------------------------------
call PetscInitialize(PETSC_NULL_CHARACTER,ierr)
call TaoInitialize(PETSC_NULL_CHARACTER,ierr)


!Create TAO App and KSP solver--------------------------------------------------
call TaoCreate(PETSC_COMM_WORLD,'tao_nm',tao,ierr)

call TaoApplicationCreate(PETSC_COMM_WORLD,taoapp,ierr)

call KSPCreate(PETSC_COMM_WORLD,ksp,ierr)


!Matrices-----------------------------------------------------------------------
call MatCreate(PETSC_COMM_WORLD,ZM_Net,ierr)
call MatSetSizes(ZM_Net,PETSC_DECIDE,PETSC_DECIDE,IS_reachbas,IS_reachbas,ierr)
!call MatSetType(ZM_Net,MATMPIAIJ,ierr) !Unnecessary, the type is picked at runtime
call MatSetFromOptions(ZM_Net,ierr)
!call MatSeqAIJSetPreallocation(ZM_Net,3*IS_one,PETSC_NULL_INTEGER,ierr)
!call MatMPIAIJSetPreallocation(ZM_Net,3*IS_one,PETSC_NULL_INTEGER,2*IS_one,    &
!                               PETSC_NULL_INTEGER,ierr)
!Very basic preallocation assuming no more than 3 upstream elements anywhere
!Not used here because proper preallocation is done within rapid_net_mat.F90

call MatCreate(PETSC_COMM_WORLD,ZM_A,ierr)
call MatSetSizes(ZM_A,PETSC_DECIDE,PETSC_DECIDE,IS_reachbas,IS_reachbas,ierr)
!call MatSetType(ZM_A,MATMPIAIJ,ierr) !Unnecessary, the type is picked at runtime
call MatSetFromOptions(ZM_A,ierr)
!call MatSeqAIJSetPreallocation(ZM_A,4*IS_one,PETSC_NULL_INTEGER,ierr)
!call MatMPIAIJSetPreallocation(ZM_A,4*IS_one,PETSC_NULL_INTEGER,2*IS_one,      &
!                               PETSC_NULL_INTEGER,ierr)
!Very basic preallocation assuming no more than 3 upstream elements anywhere
!Not used here because proper preallocation is done within rapid_net_mat.F90

call MatCreate(PETSC_COMM_WORLD,ZM_Obs,ierr)
call MatSetSizes(ZM_Obs,PETSC_DECIDE,PETSC_DECIDE,IS_reachbas,IS_reachbas,ierr)
!call MatSetType(ZM_Obs,MATMPIAIJ,ierr) !Unnecessary, the type is picked at runtime
call MatSetFromOptions(ZM_Obs,ierr)
call MatSeqAIJSetPreallocation(ZM_Obs,1*IS_one,PETSC_NULL_INTEGER,ierr)
call MatMPIAIJSetPreallocation(ZM_Obs,1*IS_one,PETSC_NULL_INTEGER,0*IS_one,    &
                               PETSC_NULL_INTEGER,ierr)
!Very basic preallocation assuming that all reaches have one gage.

!These matrices are all square of size IS_reachbas.  PETSC_DECIDE allows PETSc 
!to determine the local sizes on its own. MatSetFromOptions allows to use many
!different options at runtime, such as "-mat_type aijmumps".


!Vectors of size IS_reachbas----------------------------------------------------
!call VecCreateMPI(PETSC_COMM_WORLD,PETSC_DECIDE,IS_reachbas,ZV_k,ierr)
call VecCreate(PETSC_COMM_WORLD,ZV_k,ierr)
call VecSetSizes(ZV_k,PETSC_DECIDE,IS_reachbas,ierr)
call VecSetFromOptions(ZV_k,ierr)
!same remarks as above for sizes

call VecDuplicate(ZV_k,ZV_x,ierr)
call VecDuplicate(ZV_k,ZV_C1,ierr)
call VecDuplicate(ZV_k,ZV_C2,ierr)
call VecDuplicate(ZV_k,ZV_C3,ierr)
call VecDuplicate(ZV_k,ZV_Cdenom,ierr)

call VecDuplicate(ZV_k,ZV_b,ierr)
call VecDuplicate(ZV_k,ZV_b1,ierr)
call VecDuplicate(ZV_k,ZV_b2,ierr)
call VecDuplicate(ZV_k,ZV_b3,ierr)
call VecDuplicate(ZV_k,ZV_babsmax,ierr)

call VecDuplicate(ZV_k,ZV_Qext,ierr)
call VecDuplicate(ZV_k,ZV_Qfor,ierr)
call VecDuplicate(ZV_k,ZV_Qlat,ierr)
call VecDuplicate(ZV_k,ZV_Vext,ierr)
call VecDuplicate(ZV_k,ZV_Vfor,ierr)
call VecDuplicate(ZV_k,ZV_Vlat,ierr)

call VecDuplicate(ZV_k,ZV_QoutinitM,ierr)
call VecDuplicate(ZV_k,ZV_QoutinitO,ierr)
call VecDuplicate(ZV_k,ZV_QoutbarO,ierr)

call VecDuplicate(ZV_k,ZV_QoutR,ierr)
call VecDuplicate(ZV_k,ZV_QoutinitR,ierr)
call VecDuplicate(ZV_k,ZV_QoutprevR,ierr)
call VecDuplicate(ZV_k,ZV_QoutbarR,ierr)

call VecDuplicate(ZV_k,ZV_VinitM,ierr)

call VecDuplicate(ZV_k,ZV_VR,ierr)
call VecDuplicate(ZV_k,ZV_VinitR,ierr)
call VecDuplicate(ZV_k,ZV_VprevR,ierr)
call VecDuplicate(ZV_k,ZV_VbarR,ierr)
call VecDuplicate(ZV_k,ZV_VoutR,ierr)

call VecDuplicate(ZV_k,ZV_temp1,ierr)
call VecDuplicate(ZV_k,ZV_temp2,ierr)
call VecDuplicate(ZV_k,ZV_Qobs,ierr)
call VecDuplicate(ZV_k,ZV_kfac,ierr)
call VecDuplicate(ZV_k,ZV_Qobsbarrec,ierr)
!all the other vector objects are duplicates of the first one


!Vectors of parameters----------------------------------------------------------
!call VecCreateMPI(PETSC_COMM_WORLD,PETSC_DECIDE,IS_one*2,ZV_p,ierr)
call VecCreate(PETSC_COMM_WORLD,ZV_p,ierr)
call VecSetSizes(ZV_p,PETSC_DECIDE,2*IS_one,ierr)
call VecSetFromOptions(ZV_p,ierr)
!same remarks as above for sizes

call VecDuplicate(ZV_p,ZV_pnorm,ierr)
call VecDuplicate(ZV_p,ZV_pfac,ierr)
 

!Vectors and objects useful for PETSc programming-------------------------------
call VecDuplicate(ZV_k,ZV_one,ierr)
call VecSet(ZV_one,ZS_one,ierr)
!this is a vector with ones a each row, used for computations

call VecScatterCreateToZero(ZV_k,vecscat,ZV_SeqZero,ierr)
!create scatter context from a distributed vector to a sequential vector on the 
!zeroth processor.  Also creates the vector ZV_SeqZero

call VecDuplicate(ZV_p,ZV_1stIndex,ierr)
call VecSetValues(ZV_1stIndex,IS_one,0*IS_one,ZS_one,INSERT_VALUES,ierr)
call VecAssemblyBegin(ZV_1stIndex,ierr)
call VecAssemblyEnd(ZV_1stIndex,ierr)
!ZV_1stindex=[1;0]

call VecDuplicate(ZV_p,ZV_2ndIndex,ierr)
call VecSetValues(ZV_2ndIndex,IS_one,IS_one,ZS_one,INSERT_VALUES,ierr)
call VecAssemblyBegin(ZV_2ndIndex,ierr)
call VecAssemblyEnd(ZV_2ndIndex,ierr)
!ZV_2ndindex=[0;1]


end subroutine rapid_create_obj

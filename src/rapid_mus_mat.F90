!*******************************************************************************
!Subroutine - rapid_mus_mat
!*******************************************************************************
subroutine rapid_mus_mat

!Purpose:
!Compute RAPID Muskingum operator M
!M=(I-C1*N)^(-1)
!Author: 
!Charlotte M. Emery, Feb 2018.
!Modifs :: 
!---March 7th, 2018---!
!-Update fill of ZM_MC (corrected)
!-Update count nz element in ZM_M
!---March 8th, 2018---!
!-Threshold for highest values: ZM_MC is filled with IV_nbrows which counts
!-how many rows respect the threshold. ZM_M is filled according to IV_nbrows

!*******************************************************************************
!Declaration of variables
!*******************************************************************************

use rapid_var, only :                                                          &
                IS_riv_bas,                                                    &
                JS_riv_bas,JS_riv_bas2,JS_up,                                  & 
                IV_nbup,IV_riv_index,IM_index_up,                              &
                IS_ownfirst,IS_ownlast,                                        &
                ZV_C1,                                                         &
                ZS_val,IS_one,ZS_one,                                          &
                ierr

implicit none

!*******************************************************************************
!Declaration of new variables
!*******************************************************************************

PetscInt :: JS_i
PetscInt :: IS_Knilpotent
PetscScalar :: ZS_threshold=0.001

PetscInt, dimension(:), allocatable :: IV_nzC, IV_dnzC, IV_onzC
PetscInt, dimension(:), allocatable :: IV_nzM, IV_dnzM, IV_onzM
PetscInt, dimension(:), allocatable :: IV_cols, IV_cols_duplicate
PetscInt, dimension(:), allocatable :: IV_ind, IV_rows
PetscInt, dimension(:), allocatable :: IV_nbrows

PetscScalar, dimension(:), allocatable :: ZV_cols

Mat :: ZM_MC
Mat :: ZM_M

!*******************************************************************************
!Includes
!*******************************************************************************
#include "petsc/finclude/petscsys.h"       
!base PETSc routines
#include "petsc/finclude/petscvec.h"  
#include "petsc/finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "petsc/finclude/petscmat.h"    
!matrices
#include "petsc/finclude/petscksp.h"    
!Krylov subspace methods
#include "petsc/finclude/petscpc.h"     
!preconditioners
#include "petsc/finclude/petscviewer.h"
!viewers (allows writing results in file for example)

!*******************************************************************************
!Routine
!*******************************************************************************

!-0.Create new matrix/vector PetsC object---------------------------------------
!-------------------------------------------------------------------------------

call MatCreate(PETSC_COMM_WORLD,ZM_MC,ierr)
call MatSetSizes(ZM_MC,PETSC_DECIDE,PETSC_DECIDE,IS_riv_bas,IS_riv_bas,ierr)
call MatSetFromOptions(ZM_MC,ierr)
call MatSetUp(ZM_MC,ierr)

call MatCreate(PETSC_COMM_WORLD,ZM_M,ierr)
call MatSetSizes(ZM_M,PETSC_DECIDE,PETSC_DECIDE,IS_riv_bas,IS_riv_bas,ierr)
call MatSetFromOptions(ZM_M,ierr)
call MatSetUp(ZM_M,ierr)

!-1.Count nz elements in MZ_MC -------------------------------------------------
!-------------------------------------------------------------------------------


allocate(IV_cols(IS_riv_bas))
allocate(IV_cols_duplicate(IS_riv_bas))
IV_cols(:)=0
IV_cols_duplicate(:)=0
do JS_riv_bas2=1,IS_riv_bas 
    do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))
        if (IM_index_up(JS_riv_bas2,JS_up)/=0) then

        JS_riv_bas=IM_index_up(JS_riv_bas2,JS_up)

        IV_cols(JS_riv_bas)=JS_riv_bas2
        IV_cols_duplicate(JS_riv_bas)=JS_riv_bas2

        end if
    end do
end do


allocate(IV_nzC(IS_riv_bas))
allocate(IV_dnzC(IS_riv_bas))
allocate(IV_onzC(IS_riv_bas))
IV_nzC(:)=0
IV_dnzC(:)=0
IV_onzC(:)=0
call MatGetOwnershipRange(ZM_MC,IS_ownfirst,IS_ownlast,ierr)

IV_nzC(1)=IS_riv_bas
if ( (1.ge.IS_ownfirst+1).and.(1.lt.IS_ownlast+1) ) then
    IV_dnzC(1)=IS_ownlast+1-IS_ownfirst+1
    IV_onzC(1)=IV_nzC(1)-IV_dnzC(1)
end if

JS_i=2
do while ( COUNT( (IV_cols(1:IS_riv_bas).eq.0) ).ne.IS_riv_bas )

    IV_nzC(JS_i)=COUNT( (IV_cols(1:IS_riv_bas).ne.0) ) 

    if ( (JS_i.ge.IS_ownfirst+1).and.(JS_i.lt.IS_ownlast+1) ) then
        do JS_riv_bas=1,IS_riv_bas
            if ( IV_cols(JS_riv_bas).ne.0 ) then
                if ( (IV_cols(JS_riv_bas).ge.IS_ownfirst+1).and. &
                     (IV_cols(JS_riv_bas).lt.IS_ownlast+1) ) then
                    IV_dnzC(JS_i)=IV_dnzC(JS_i)+1
                end if
                IV_cols(JS_riv_bas)=IV_cols_duplicate(IV_cols(JS_riv_bas))
            end if
        end do
        IV_onzC(JS_i)=IV_nzC(JS_i)-IV_dnzC(JS_i)

    else
        do JS_riv_bas=1,IS_riv_bas
            if ( IV_cols(JS_riv_bas).ne.0 ) then
                IV_cols(JS_riv_bas)=IV_cols_duplicate(IV_cols(JS_riv_bas))
            end if
        end do

    end if
    JS_i=JS_i+1
end do
IS_Knilpotent=JS_i-1
write(*,*) 'Knilpotent=', IS_Knilpotent

allocate(IV_ind(IS_riv_bas))
do JS_riv_bas=1,IS_riv_bas
    IV_cols(JS_riv_bas)=IV_cols_duplicate(JS_riv_bas)
    IV_ind(JS_riv_bas) = JS_riv_bas
end do

!-2.Preallocate ZM_MC ----------------------------------------------------------
!-------------------------------------------------------------------------------

call MatSeqAIJSetPreallocation(ZM_MC,PETSC_NULL_INTEGER,IV_nzC,ierr)
call MatMPIAIJSetPreallocation(ZM_MC,                                          &
                               PETSC_NULL_INTEGER,                             &
                               IV_dnzC(IS_ownfirst+1:IS_ownlast),              &
                               PETSC_NULL_INTEGER,                             &
                               IV_onzC(IS_ownfirst+1:IS_ownlast),ierr)

!-3.Fill ZM_MC -----------------------------------------------------------------
!-------------------------------------------------------------------------------

if (rank==0) then

allocate(ZV_cols(IS_riv_bas))
allocate(IV_nbrows(IS_riv_bas))
ZV_cols(:)=1
IV_nbrows(:)=1
do JS_i=0,IS_Knilpotent

    call MatSetValues(ZM_MC,   &
                      IS_one,JS_i,  &
                      IV_nzC(JS_i+1),IV_ind(1:IS_riv_bas)-1, &
                      ZV_cols(1:IS_riv_bas),INSERT_VALUES,ierr)

    if (JS_i.eq.0) then

        do JS_riv_bas2=1,IS_riv_bas
            if (IV_cols(JS_riv_bas2).ne.0) then

                call VecGetValues(ZV_C1,         &
                      IS_one,                    &
                      IV_cols(JS_riv_bas2)-1,     &
                      ZS_val,ierr)

                !ZV_cols(JS_riv_bas2)=ZV_cols(JS_riv_bas2)*ZS_val
                if ( ABS(ZV_cols(JS_riv_bas2)*ZS_val).lt.ZS_threshold ) then
                    IV_ind(JS_riv_bas2)=0
                    IV_cols(JS_riv_bas2)=0
                    !ZV_cols(JS_riv_bas2)=-999
                else
                    ZV_cols(JS_riv_bas2)=ZV_cols(JS_riv_bas2)*ZS_val
                    IV_nbrows(JS_riv_bas2)=IV_nbrows(JS_riv_bas2)+1
                end if

            else 
               IV_ind(JS_riv_bas2)=0
               !ZV_cols(JS_riv_bas2)=-999
            end if
        end do

    else

        do JS_riv_bas2=1,IS_riv_bas
            if (IV_cols_duplicate(IV_cols(JS_riv_bas2)).ne.0) then

                call VecGetValues(ZV_C1,                            &
                                  IS_one,                           &
                                  IV_cols_duplicate(IV_cols(JS_riv_bas2))-1, &
                                  ZS_val,ierr)

                !ZV_cols(JS_riv_bas2)=ZV_cols(JS_riv_bas2)*ZS_val 
                !IV_cols(JS_riv_bas2)=IV_cols_duplicate(IV_cols(JS_riv_bas2))
                if ( ABS(ZV_cols(JS_riv_bas2)*ZS_val).lt.ZS_threshold ) then
                    IV_ind(JS_riv_bas2)=0
                    IV_cols(JS_riv_bas2)=0
                    !ZV_cols(JS_riv_bas2)=-999
                else
                    ZV_cols(JS_riv_bas2)=ZV_cols(JS_riv_bas2)*ZS_val 
                    IV_cols(JS_riv_bas2)=IV_cols_duplicate(IV_cols(JS_riv_bas2))
                    IV_nbrows(JS_riv_bas2)=IV_nbrows(JS_riv_bas2)+1
                end if

            else
                IV_ind(JS_riv_bas2)=0
                !ZV_cols(JS_riv_bas2)=-999
            end if
        end do

     end if

     !when using threshold higher than 0, less iterations needed to fill ZM_MC
     if ( COUNT( (IV_ind(1:IS_riv_bas).eq.0) ).eq.IS_riv_bas ) then
         write(*,*) 'Exit at row =', JS_i+1
         EXIT
     endif
 
end do

end if

call MatAssemblyBegin(ZM_MC,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_MC,MAT_FINAL_ASSEMBLY,ierr)

!-4.Count nz elements in ZM_M --------------------------------------------------
!-------------------------------------------------------------------------------

allocate(IV_nzM(IS_riv_bas))
allocate(IV_dnzM(IS_riv_bas))
allocate(IV_onzM(IS_riv_bas))
do JS_riv_bas=1,IS_riv_bas
     IV_nzM(JS_riv_bas)=0
     IV_dnzM(JS_riv_bas)=1
     IV_onzM(JS_riv_bas)=0
end do
call MatGetOwnershipRange(ZM_M,IS_ownfirst,IS_ownlast,ierr)

do JS_riv_bas2=1,IS_riv_bas
     IV_nzM(JS_riv_bas2)=1
     if (IV_nbup(IV_riv_index(JS_riv_bas2)).gt.0) then
          do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))

              JS_riv_bas=IM_index_up(JS_riv_bas2,JS_up)
              IV_nzM(JS_riv_bas2)=IV_nzM(JS_riv_bas2)+IV_nzM(JS_riv_bas)

          end do
     end if
end do

do JS_riv_bas=1,IS_riv_bas   !loop over column
    JS_riv_bas2=IV_cols_duplicate(JS_riv_bas)
    do while (JS_riv_bas2.ne.0)    !loop over row
        if ( ((JS_riv_bas2.ge.IS_ownfirst+1).and.(JS_riv_bas2.lt.IS_ownlast+1)).and.   &
             ((JS_riv_bas.ge.IS_ownfirst+1).and.(JS_riv_bas.lt.IS_ownlast+1)) ) then
            IV_dnzM(JS_riv_bas2) = IV_dnzM(JS_riv_bas2)+1
        end if
        if ( ((JS_riv_bas2.ge.IS_ownfirst+1).and.(JS_riv_bas2.lt.IS_ownlast+1)).and.   &
             ((JS_riv_bas.lt.IS_ownfirst+1).or.(JS_riv_bas.ge.IS_ownlast+1)) ) then
            IV_onzM(JS_riv_bas2) = IV_onzM(JS_riv_bas2)+1
        end if
        JS_riv_bas2=IV_cols_duplicate(JS_riv_bas2)
    end do
end do

!-5.Preallocate ZM_M -----------------------------------------------------------
!-------------------------------------------------------------------------------

call MatSeqAIJSetPreallocation(ZM_M,PETSC_NULL_INTEGER,IV_nzM,ierr)
call MatMPIAIJSetPreallocation(ZM_M,                                         &
                               PETSC_NULL_INTEGER,                           &
                               IV_dnzM(IS_ownfirst+1:IS_ownlast),            &
                               PETSC_NULL_INTEGER,                           &
                               IV_onzM(IS_ownfirst+1:IS_ownlast),ierr)


do JS_riv_bas=1,IS_riv_bas
    IV_cols(JS_riv_bas) = IV_cols_duplicate(JS_riv_bas) 
    IV_ind(JS_riv_bas) = JS_riv_bas
end do

!-6.Fill ZM_M ------------------------------------------------------------------
!-------------------------------------------------------------------------------

allocate(IV_rows(IS_Knilpotent+1))
deallocate(ZV_cols)

if (rank==0) then

IV_rows(:)=0
do JS_riv_bas=0,IS_riv_bas-1

    IV_rows(1)=JS_riv_bas+1
    do JS_i=2,IV_nbrows(JS_riv_bas+1)
        IV_rows(JS_i)=IV_cols(IV_rows(JS_i-1))
    end do
    allocate(ZV_cols(IV_nbrows(JS_riv_bas+1)))
    
    call MatGetValues( ZM_MC,    &
                       IV_nbrows(JS_riv_bas+1),  &
                       IV_ind(1:IV_nbrows(JS_riv_bas+1))-1,   &
                       IS_one,JS_riv_bas,   &
                       ZV_cols,ierr )
 
    call MatSetValues( ZM_M,    &
                       IV_nbrows(JS_riv_bas+1),  &
                       IV_rows(1:IV_nbrows(JS_riv_bas+1))-1,   & 
                       IS_one, JS_riv_bas,   &
                       ZV_cols(1:IV_nbrows(JS_riv_bas+1)),  &
                       INSERT_VALUES,ierr )

    deallocate(ZV_cols)

end do

end if

call MatAssemblyBegin(ZM_M,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_M,MAT_FINAL_ASSEMBLY,ierr)


!-7.Finalize--------------------------------------------------------------------
!-------------------------------------------------------------------------------

deallocate(IV_cols)
deallocate(IV_cols_duplicate)
deallocate(IV_nzC)
deallocate(IV_dnzC)
deallocate(IV_onzC)
deallocate(IV_ind)
deallocate(IV_rows)
deallocate(IV_nbrows)

call Mat_Destroy(ZM_MC,ierr)

!*******************************************************************************
!End subroutine
!*******************************************************************************
end subroutine rapid_mus_mat

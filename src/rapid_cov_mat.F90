!*******************************************************************************
!Subroutine - rapid_cov_mat
!*******************************************************************************
subroutine rapid_cov_mat

!Purpose:
!Compute runoff error covariance matrix ZM_Pb for data assimilation
!Authors: 
!Charlotte M. Emery, and Cedric H. David, 2018-2021.


!*******************************************************************************
!Fortran includes, modules, and implicity
!*******************************************************************************
#include <petsc/finclude/petscmat.h>
use petscmat
use rapid_var, only :                                                          &
                IS_riv_bas,                                                    &
                JS_riv_bas,JS_riv_bas2,JS_up,                                  &
                IV_riv_index, IV_nbup,IM_index_up,                             &
                IV_nz,IV_dnz,IV_onz,                                           &
                IS_ownfirst,IS_ownlast,                                        &
                IS_one,                                                        &
                ierr,rank,                                                     &
                !new variables added in rapid_var.F90
                IS_radius,ZS_inflation,                                        &
                ZM_Pb,                                                         &
                ZV_riv_tot_vQlat,ZV_riv_tot_cdownQlat 
implicit none


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************

PetscInt :: JS_i

PetscInt, dimension(:), allocatable :: IV_index_down

!*******************************************************************************
!Prepare for preallocation of ZM_Pb
!*******************************************************************************

!-------------------------------------------------------------------------------
!Allocate and initialize temporary variables
!-------------------------------------------------------------------------------

allocate(IV_index_down(IS_riv_bas))
IV_index_down(:) = 0
!Indexes of downstream reaches

IV_nz(:)=0
IV_dnz(:)=0
IV_onz(:)=0
!The number of non-zero elements per row.

!-------------------------------------------------------------------------------
!Populate temporary variables
!-------------------------------------------------------------------------------

do JS_riv_bas2=1,IS_riv_bas 
    do JS_up=1,IV_nbup(IV_riv_index(JS_riv_bas2))
        if (IM_index_up(JS_riv_bas2,JS_up)/=0) then

        JS_riv_bas=IM_index_up(JS_riv_bas2,JS_up)

        IV_index_down(JS_riv_bas)=JS_riv_bas2

        end if
    end do
end do

!-------------------------------------------------------------------------------
!Count the number of non-zero elements (ZM_Pb)
!-------------------------------------------------------------------------------

do JS_riv_bas=1,IS_riv_bas   !row index

    IV_nz(JS_riv_bas) = IV_nz(JS_riv_bas)+1  !diagonal element
    IV_dnz(JS_riv_bas) = IV_dnz(JS_riv_bas)+1  !diagonal element

    JS_riv_bas2 = IV_index_down(JS_riv_bas)
    do JS_i = 1,IS_radius
    
        if (JS_riv_bas2.ne.0) then

            IV_nz(JS_riv_bas) = IV_nz(JS_riv_bas)+1
            IV_nz(JS_riv_bas2) = IV_nz(JS_riv_bas2)+1  !symmetry

            if (((JS_riv_bas.ge.IS_ownfirst+1).and.      &
                 (JS_riv_bas.lt.IS_ownlast+1)).and.      &
                ((JS_riv_bas2.ge.IS_ownfirst+1).and.     &
                 (JS_riv_bas2.lt.IS_ownlast+1))) then
 
                IV_dnz(JS_riv_bas) = IV_dnz(JS_riv_bas)+1
                IV_dnz(JS_riv_bas2) = IV_dnz(JS_riv_bas2)+1  !symmetry

            endif

            if (((JS_riv_bas.ge.IS_ownfirst+1).and.      &
                 (JS_riv_bas.lt.IS_ownlast+1)).and.      &
                ((JS_riv_bas2.lt.IS_ownfirst+1).or.     &
                 (JS_riv_bas2.ge.IS_ownlast+1))) then
 
                IV_onz(JS_riv_bas) = IV_onz(JS_riv_bas)+1
                
            endif

            if (((JS_riv_bas.lt.IS_ownfirst+1).or.       &
                 (JS_riv_bas.ge.IS_ownlast+1)).and.      &
                ((JS_riv_bas2.ge.IS_ownfirst+1).and.      &
                 (JS_riv_bas2.lt.IS_ownlast+1))) then

                IV_onz(JS_riv_bas2) = IV_onz(JS_riv_bas2)+1

            endif

            JS_riv_bas2 = IV_index_down(JS_riv_bas2)

        end if

    end do

end do

!*******************************************************************************
!Matrix preallocation (ZM_Pb)
!*******************************************************************************

call MatSeqAIJSetPreallocation(ZM_Pb,PETSC_DEFAULT_INTEGER,IV_nz,ierr)
call MatMPIAIJSetPreallocation(ZM_Pb,PETSC_DEFAULT_INTEGER, &
                                     IV_dnz(IS_ownfirst+1:IS_ownlast),   &
                                     PETSC_DEFAULT_INTEGER,  &
                                     IV_onz(IS_ownfirst+1:IS_ownlast),   &
                                     ierr)


!*******************************************************************************
!Populate matrix (ZM_Pb)
!*******************************************************************************

if (rank==0) then

do JS_riv_bas=1,IS_riv_bas   !row index

    !populate matrix diagonal
    call MatSetValues(ZM_Pb,                                          &
                     IS_one,                                         &
                     JS_riv_bas-1,                                   &
                     IS_one,                                         &
                     JS_riv_bas-1,                                   &
        ZV_riv_tot_vQlat(IV_riv_index(JS_riv_bas))*(ZS_inflation)**2,     &
                     INSERT_VALUES,ierr)

    JS_riv_bas2 = IV_index_down(JS_riv_bas)
    do JS_i = 1,IS_radius
    
        if (JS_riv_bas2.ne.0) then

            !populate downstream matrix element (same row, upper triangular part)
            call MatSetValues(ZM_Pb,                                              &
                             IS_one,                                              &
                             JS_riv_bas-1,                                        &
                             IS_one,                                              &
                             JS_riv_bas2-1,                                       &
               ZV_riv_tot_cdownQlat(IV_riv_index(JS_riv_bas),JS_i)*(ZS_inflation)**2,     &
                             INSERT_VALUES,ierr)

            !populate symmetry
            call MatSetValues(ZM_Pb,                                              &
                             IS_one,                                              &
                             JS_riv_bas2-1,                                       &
                             IS_one,                                              &
                             JS_riv_bas-1,                                       &
               ZV_riv_tot_cdownQlat(IV_riv_index(JS_riv_bas),JS_i)*(ZS_inflation)**2, &
                             INSERT_VALUES,ierr)

            JS_riv_bas2 = IV_index_down(JS_riv_bas2)

        end if

    end do

end do

end if

call MatAssemblyBegin(ZM_Pb,MAT_FINAL_ASSEMBLY,ierr)
call MatAssemblyEnd(ZM_Pb,MAT_FINAL_ASSEMBLY,ierr)

call PetscPrintf(PETSC_COMM_WORLD,'Runoff error covariance matrix created'       &
                                  //char(10),ierr)


!*******************************************************************************
!Free up memory used by local (temporary) variables
!*******************************************************************************
deallocate(IV_index_down)


!*******************************************************************************
!End subroutine
!*******************************************************************************
call PetscPrintf(PETSC_COMM_WORLD,'--------------------------'//char(10),ierr)

end subroutine rapid_cov_mat

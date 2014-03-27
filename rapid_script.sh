FILE=$(date +"%Y-%m-%d_%H-%M-%S_rapid_stdout.txt")
/usr/bin/time mpiexec -n 1 ./rapid                                             \
                           -ksp_type richardson                                \
                           1>$FILE 2>>$FILE
#-ksp_type preonly
#-ksp_type richardson 
#-ksp_monitor
#-ksp_view
#-log_summary
#-info
#-pc_type sor  
#-pc_type sor -pc_sor_backward 
#-pc_type sor -pc_sor_forward 
#-pc_type bjacobi -sub_pc_type sor -sub_pc_sor_forward 
#-mat_type mpiaij -ksp_type preonly -pc_type lu -pc_factor_mat_solver_package mumps
#-pc_factor_reuse_ordering -pc_factor_reuse_fill

#FILE is a name created based on the time when the model started running
#FILE contains stdout from running the model (through 1), but also stderr 
#(through 2).  The output of the time function is also included because 
#it is located in located in 2.

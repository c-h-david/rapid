#!/usr/bin/env python3
#*******************************************************************************
#rrr_drv_make_namelist_file.py
#*******************************************************************************
#Purpose:
#This program is designed to produce namelist file for RAPID for one entire month,
#and can be run with a simple set of instructions.
#Exemple usage:
#   rapid = RAPID('74', 'VIC', '3H', '2000-01')     # to create the RAPID class, paths and variabless
#   drv_write_namelist(rapid)                       # to write the namelist file
#   drv_run(rapid)                                  # to run RAPID
#This class combines the pfaf_level_02 code, the Land Surface Model (LSM) name,
#the LSM temporal resolution, and the month in yyyy-mm format to create the namelist.
#Authors:
#Cedric H. David, Quentin Bonassies, 2024-2024


#*******************************************************************************
#Import Python modules
#*******************************************************************************
import os
import subprocess
import datetime
import dateutil.relativedelta

FALSE = '.false.'
TRUE = '.true.'

#*******************************************************************************
#Define nomenclature inside Python class
#*******************************************************************************
class RAPID(object):
    basn_id: str
    lsm_mod: str
    lsm_stp: str
    yyyy_mm: str
     
    def __init__(self, basn_id, lsm_mod, lsm_stp, yyyy_mm) -> None:
        self.basn_id = basn_id
        self.lsm_mod = lsm_mod
        self.lsm_stp = lsm_stp
        self.yyyy_mm = yyyy_mm

        self.set_paths()
        self.set_vars()


    def set_paths(self):#Uses “formatted string literals” also known as f-strings.
        #--------------------------------------------------------------------- 
        #Directories
        #--------------------------------------------------------------------- 
        self.inp_dir = f'/home/rapid/input/pfaf_{self.basn_id}_2020/'
        os.makedirs(self.inp_dir, exist_ok=True)

        self.out_dir = f'/home/rapid/output/pfaf_{self.basn_id}_2020/'
        os.makedirs(self.out_dir, exist_ok=True)
        
        #---------------------------------------------------------------------
        #Namelist file
        #---------------------------------------------------------------------
        self.namelst = 'rapid_namelist'

        #--------------------------------------------------------------------- 
        #Hydrography {basn_id}
        #--------------------------------------------------------------------- 
        # self.kfc_csv = f'kfac_pfaf_{self.basn_id}_1km_hour.csv'
        # self.xfc_csv = f'xfac_pfaf_{self.basn_id}_0.1.csv'
        self.knr_csv = f'k_pfaf_{self.basn_id}_nrm.csv'
        self.xnr_csv = f'x_pfaf_{self.basn_id}_nrm.csv'

        self.bas_csv = f'riv_bas_id_pfaf_{self.basn_id}_topo.csv'
        self.con_csv = f'rapid_connect_pfaf_{self.basn_id}.csv'
        
        self.qini_nc = f'Qinit_pfaf_{self.basn_id}_GLDAS_{self.lsm_mod}_{self.lsm_stp}_{self.yyyy_mm}_utc.nc'
        self.qfin_nc = f'Qfinal_pfaf_{self.basn_id}_GLDAS_{self.lsm_mod}_{self.lsm_stp}_{self.yyyy_mm}_utc.nc'
        
        self.qout_nc = f'Qout_pfaf_{self.basn_id}_GLDAS_{self.lsm_mod}_{self.lsm_stp}_{self.yyyy_mm}_utc.nc'
        self.vfil_nc = f'V_pfaf_{self.basn_id}_GLDAS_{self.lsm_mod}_{self.lsm_stp}_{self.yyyy_mm}_utc.nc'

        #--------------------------------------------------------------------- 
        #Times {yyyy_mm}
        #--------------------------------------------------------------------- 
        self.dat_str = datetime.datetime.strptime(self.yyyy_mm,'%Y-%m')
        self.dat_end = self.dat_str                                          \
                    + dateutil.relativedelta.relativedelta( months=+1)        \
                    + dateutil.relativedelta.relativedelta(seconds=-1)
        self.iso_str = self.dat_str.isoformat()
        self.iso_end = self.dat_end.isoformat()
        
        #--------------------------------------------------------------------- 
        #Lateral inflow {basn_id} {lsm_mod} {lsm_stp} {yyyy_mm}
        #--------------------------------------------------------------------- 
        self.m3r_ncf = f'm3_riv_pfaf_{self.basn_id}_GLDAS_{self.lsm_mod}_{self.lsm_stp}_{self.yyyy_mm}_utc.nc4'


    def set_vars(self):
        #--------------------------------------------------------------------- 
        #Temporal variables
        #--------------------------------------------------------------------- 
        self.zs_Taum = datetime.timedelta(seconds=(self.dat_end - self.dat_str).total_seconds() + 1).total_seconds()
        self.zs_dtm  = datetime.timedelta(days=1).total_seconds()       #86400
        self.zs_Taur = datetime.timedelta(hours=3).total_seconds()      #10800
        self.zs_dtr  = datetime.timedelta(minutes=15).total_seconds()   #900
        #--------------------------------------------------------------------- 
        #Domain variables
        #--------------------------------------------------------------------- 
        with open(self.inp_dir + self.con_csv) as file:
            IV_nbup = [int(line.split(',')[2]) for line in file]
        self.is_riv_tot = len(IV_nbup)
        self.is_riv_bas = len(IV_nbup)
        self.is_max_up  = max(IV_nbup)
    
    
def drv_write_namelist(rapid: RAPID):
    # Write the namelist file
    sep = "!" + "*"*79 + '\n'
    empty = "" + '\n'
    with open(rapid.inp_dir + rapid.namelst, "w") as f:
        f.write("&NL_namelist" + "\n")
        f.write("!" + "*"*79 + "\n")
        f.write(f"!{rapid.inp_dir + rapid.namelst}\n")
        f.write("!" + "*"*79 + "\n")
        f.write(empty)
        f.write("!Purpose:" + "\n")
        f.write("!    rapid_namelist file created automatically with the RAPID class" + "\n")
        f.write("!Author: Cedric David and Quentin Bonassies\n")
        f.write("!Creation date: " + datetime.datetime.now().isoformat() + "\n"*2)
        f.write(empty)

        f.write(sep)
        f.write("!Runtime options" + "\n")
        f.write(sep)
        f.write("BS_opt_Qinit = " + TRUE + "\n")
        f.write("BS_opt_Qfinal = " + TRUE + "\n")
        f.write("BS_opt_V = " + TRUE + "\n")
        f.write("BS_opt_uq = " + FALSE + "\n")
        f.write("IS_opt_routing = 1" + "\n")
        f.write("IS_opt_run = 1" + "\n")
        f.write(empty)
        
        f.write(sep)
        f.write("!Temporal information" + "\n")
        f.write(sep)
        f.write("ZS_TauM = " + str(rapid.zs_Taum) + "\n")
        f.write("ZS_dtM = " + str(rapid.zs_dtm) + "\n")
        f.write("ZS_TauR = " + str(rapid.zs_Taur) + "\n")
        f.write("ZS_dtR = " + str(rapid.zs_dtr) + "\n")
        f.write(empty)
        
        f.write(sep)
        f.write("!Domain in which input data is available" + "\n")
        f.write(sep)
        f.write("IS_riv_tot = " + str(rapid.is_riv_tot) + "\n")
        f.write("IS_max_up = " + str(rapid.is_max_up) + "\n")
        f.write("rapid_connect_file = '" + rapid.inp_dir + rapid.con_csv + "'\n")
        f.write("Vlat_file = '" + rapid.inp_dir + rapid.m3r_ncf + "'\n")
        f.write(empty)
        
        f.write(sep)
        f.write("!Domain in which model runs" + "\n")
        f.write(sep)
        f.write("IS_riv_bas = " + str(rapid.is_riv_bas) + "\n")
        f.write("riv_bas_id_file = '" + rapid.inp_dir + rapid.bas_csv + "'\n")
        f.write(empty)
        
        f.write(sep)
        f.write("!Instantaneous flow file" + "\n")
        f.write(sep)
        f.write("Qinit_file = '" + rapid.out_dir + rapid.qini_nc + "'\n")
        f.write("Qfinal_file = '" + rapid.out_dir + rapid.qfin_nc + "'\n")
        f.write(empty)
        
        f.write(sep)
        f.write("!Regular model run" + "\n")
        f.write(sep)
        f.write("x_file = '" + rapid.inp_dir + rapid.xnr_csv + "'\n")
        f.write("k_file = '" + rapid.inp_dir + rapid.knr_csv + "'\n")
        f.write("Qout_file = '" + rapid.out_dir + rapid.qout_nc + "'\n")
        f.write("V_file = '" + rapid.out_dir + rapid.vfil_nc + "'\n")
        f.write(empty)
        
        f.write(sep)
        f.write("! End name list" + "\n")
        f.write(sep)
        f.write("/" + "\n")
    
    print("Namelist file created successfully.")


def drv_run(rapid: RAPID):
    # run those commands:
    #   mpiexec -n 1 /home/rapid/drv/rapid -nl path_nlst -ksp_type preonly
    path_nlst = rapid.inp_dir + rapid.namelst
    print("Run RAPID model...")
    subprocess.run(["mpiexec", "-n", "1", "/home/rapid/tst/rapid", "-nl", path_nlst, "-ksp_type", "preonly"], capture_output=False, check=True, text=True)
    print("...RAPID model run completed.")
        

#*******************************************************************************
# TEST CASE
#*******************************************************************************
if __name__ == '__main__':
    # Create the RAPID class
    rapid = RAPID('74', 'VIC', '3H', '2000-01')
    # Write the namelist file
    drv_write_namelist(rapid)
    # Run RAPID
    drv_run(rapid) #Needs to be run after RRR computation 

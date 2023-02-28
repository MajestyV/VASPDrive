#!/bin/bash
#SBATCH -J vasp
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p kshcexclu15

NP=4

# INCAR for density of states (DOS) calculation
cat >INCAR <<EOF
# Computing Resources Distribution
NCORE = 8            # NCORE determines the number of compute cores that work on an individual orbital (available as of VASP.5.2.13).

# Global Parameters
PREC = Accurate
ENCUT = 500
ISTART = 1           # Reading the WAVECAR file from SCF calculation
ICHARG = 11          # To obtain the eigenvalues (for band structure plots) or the DOS for a given charge density read from CHGCAR.
LREAL = .FALSE.      # LREAL determines whether the projection operators are evaluated in real-space or in reciprocal space.
LWAVE = .FALSE.      # Writing CHGCAR and CHG file
LCHARG = .FALSE.     # Writing WAVECAR file
LORBIT = 11          # Writing DOSCAR and Im-decomposed PROCAR files
ISYM = 2             # Key to GSE: Broken symmetry?!

# Crystal Lattice Relaxtion
NSW = 0              # Do not move the atoms in TDM calculations! NSW sets the maximum number of ionic steps.

# Electronic Relaxation
ISMEAR = 0           # The ISMEAR parameter does not have to be zero for electronic bands calculation, but it cannot be -5 because that will give an error, and a nonintuitive one at that!
SIGMA = 0.05
EDIFF = 1E-06
NEDOS = 5000         # NEDOS specifies number of gridpoints on which the DOS is evaluated, default is 301
NBANDS = 64          # NBANDS specifies the total number of KS or QP orbitals in the calculation.

# Electric field
LDIPOL = .TRUE.
DIPOL = 0.5 0.5 0.5
EFIELD = XXX
IDIPOL = 3
EOF

cat >KPOINTS <<EOF
New structure        
 0                    
Gamma point shift     
 31 31 1             # Try not to increase the k-mesh for integrating DOS when including SOC 
 0 0 0                
EOF

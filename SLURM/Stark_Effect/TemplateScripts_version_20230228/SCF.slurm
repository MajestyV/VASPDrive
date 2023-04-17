#!/bin/bash
#SBATCH -J vasp
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p kshcexclu15

NP=4

# Using the relaxed crystal structure
# cp CONTCAR POSCAR

# INCAR for static self-consistent field (scf) calculation
cat >INCAR <<EOF
# Computing Resources Distribution
NCORE = 8            # NCORE determines the number of compute cores that work on an individual orbital (available as of VASP.5.2.13).

# Global Parameters
PREC = Accurate
ENCUT = 500
ISTART = 0           # Reading the WAVECAR file from SCF calculation
ICHARG = 2           # To obtain the eigenvalues (for band structure plots) or the DOS for a given charge density read from CHGCAR.
LREAL = .FALSE.      # LREAL determines whether the projection operators are evaluated in real-space or in reciprocal space.
LWAVE = .TRUE.       # Writing CHGCAR and CHG file
LCHARG = .TRUE.      # Writing WAVECAR file
ISYM = 2             # Key to GSE: Broken symmetry?!

# Crystal Lattice Relaxtion
NSW = 0              # Do not move the atoms in TDM calculations! NSW sets the maximum number of ionic steps.

# Electronic Relaxation
ISMEAR = 0           # The ISMEAR parameter does not have to be zero for electronic bands calculation, but it cannot be -5 because that will give an error, and a nonintuitive one at that!
SIGMA = 0.05
EDIFF = 1E-06
NELM = 200           # Maximum number of electronic SC(self-consistency) steps
NBANDS = 64          # NBANDS specifies the total number of KS or QP orbitals in the calculation.

# Electric field
LDIPOL = .TRUE.
DIPOL = 0.5 0.5 0.5
EFIELD = XXX
IDIPOL = 3
EOF

cat >KPOINTS <<EOF
New structure         # This is a string
 0                    # 0 means automatically generate grid
Gamma point shift     # Shift the gamma point
 21 21 1              # Kpoint mesh along each reciprocal lattice vector
 0 0 0                # amount to shift the gamma point
EOF

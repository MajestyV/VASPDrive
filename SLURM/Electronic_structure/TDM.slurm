#!/bin/bash
#SBATCH -J vasp
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -p kshcexclu15

NP=4

# INCAR for transition dipole moment (TDM) calculations
cat >INCAR <<EOF
# Computing Resources Distribution
NCORE = 8            # NCORE determines the number of compute cores that work on an individual orbital (available as of VASP.5.2.13).

# Global Parameters
PREC = Accurate
ENCUT = 500
ISTART = 1           # Reading the WAVECAR file from SCF calculation
ICHARG = 11          # To obtain the eigenvalues (for band structure plots) or the DOS for a given charge density read from CHGCAR.
LREAL = .FALSE.      # LREAL determines whether the projection operators are evaluated in real-space or in reciprocal space.
LWAVE = .TRUE.       # LWAVE determines whether the wavefunctions are written to the WAVECAR file at the end of a run.
LCHARG = .TRUE.      # LCHARG determines whether the charge densities (files CHGCAR and CHG) are written.
ADDGRID= .TRUE.      # ADDGRID determines whether an additional support grid is used for the evaluation of the augmentation charges.

# Crystal Lattice Relaxtion
NSW = 0              # Do not move the atoms in TDM calculations! NSW sets the maximum number of ionic steps.

# Electronic Relaxation
ISMEAR = 0           # The ISMEAR parameter does not have to be zero for electronic bands calculation, but it cannot be -5 because that will give an error, and a nonintuitive one at that!
SIGMA = 0.05
EDIFF = 1E-05
NBANDS = 120         # NBANDS specifies the total number of KS or QP orbitals in the calculation.

# Spin-orbit Coupling (SOC)
# This calculation requires a nonlinear version of VASP.
ISPIN = 2            # spin polarized calculation
ISYM = 0            # switch off symmetry completely
LSORBIT = .TRUE.
SAXIS = 0 0 1
EOF

# For the calculation of TDM, it's better to use a line mode k-point path for the convenience of extracting data via vaspkit.
cat >KPOINTS <<EOF
High symmetry k-points path
 100              # number of points per path segment
line mode
fractional
  0    0    0    Γ
  0.5  0    0    M

  0.5  0    0    M
  0.3333333333333333 0.3333333333333333 0    K

  0.3333333333333333 0.3333333333333333 0    K
  0    0    0    Γ
EOF

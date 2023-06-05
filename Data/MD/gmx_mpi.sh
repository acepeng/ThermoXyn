#!/bin/bash
#This script needs to be edited for each run.
#Define PDB FileA3 & GROMACS Pameters
FORCEFIELD="amber99sb-ildn"
WATERMODEL="tip3p"
WATERTOPFILE="spc216.gro"
BOXTYPE="dodecahedron"
BOXORIENTATION="1.0"
BOXSIZE="5.0"
BOXCENTER="2.5"
source /usr/local/gromacs/bin/GMXRC
# generate GROMACS .gro file
gmx pdb2gmx -f TY1.pdb -o TY1.gro -ff $FORCEFIELD -water $WATERMODEL -ignh -p topol.top
# define the box
gmx editconf -f TY1.gro -o TY1_box.gro -bt $BOXTYPE -c -d $BOXORIENTATION
# energy minimization of the structure in vacuum
gmx grompp -f minim.mdp -c TY1_box.gro -p topol.top -o em-vacuum.tpr
# add solvate
gmx solvate -cp TY1_box.gro -cs $WATERTOPFILE -o TY1_solv.gro -p topol.top
# add icons
gmx grompp -f ions.mdp -c TY1_solv.gro -p topol.top -o ions.tpr
echo SOL | gmx genion -s ions.tpr -o TY1_solv_ions.gro -p topol.top -pname NA -nname CL -conc 0.1 -neutral
# energy minimization of the structure in solvate
gmx grompp -f minim.mdp -c TY1_solv_ions.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em
# nvt
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
gmx mdrun -v -deffnm nvt
# npt
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun -v -deffnm npt
# gmx energy -f npt.edr -o density.xvg
# md
gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr
gmx mdrun -deffnm md -nb gpu
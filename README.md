# CPL/OpenFOAM+LAMMPS containers with apptainer

Here are your quick instructions to get started:
```bash
git clone https://github.com/FoamScience/openfoam-apptainer-packaging /tmp/tainers
git clone https://github.com/FoamScience/cpl-openfoam-containers
cd cpl-openfoam-containers
ansible-playbook /tmp/tainers/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
# check containers/projects/cpl-openfoam-lammps*.sif
```
```bash
# Adjust the container path accordingly
alias cpl="apptainer run --sharens /path/to/cpl-openfoam-containers/containers/projects/cpl-openfoam-lammps*.sif"
cpl info
```

Now to use the container:
```bash
git clone https://github.com/Crompulence/CPL_APP_OPENFOAM
cd CPL_APP_OPENFOAM
# modify Pstream includes since OpenFOAM is patched on the container
find . -name options -exec sed -i 's;$(FOAM_CPL_APP_SRC)/CPLPstream/lnInclude;$(LIB_SRC)/Pstream/mpi/lnInclude;' {} \;
# Adjust the container path accordingly
alias cpl="apptainer run --sharens /path/to/cpl-openfoam-containers/containers/projects/cpl-openfoam-lammps*.sif"
# Due to SOURCEME.sh using CWD, you have to source it every time and work only from root folder of the repo
cpl "source SOURCEME.sh; wmake src/CPLSocketFOAM"
cpl "source SOURCEME.sh; wmake src/solvers/CPLTestFoam"
cpl "source SOURCEME.sh; cd examples/CPLTestFoam && ./run.sh"
# (You will have to make adjustments to Makefile if you want to compile with make)
```

Then you can post process on the host machine. Or, add processing tools to
[`projects/cpl-openfoam-lammps.def`](projects/cpl-openfoam-lammps.def) and rebuild the container.

If you want to alter the container itself in any way, create an overlay image and load it:
```bash
apptainer overlay create -s 1024 overlay.img #<- 1GB overlay image
apptainer run --sharens --overlay overlay.img path/to/cpl-openfoam-containers/containers/projects/cpl-openfoam-lammps*.sif
```

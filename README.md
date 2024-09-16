# CPL/OpenFOAM+LAMMPS containers with apptainer

> [!NOTE] Dependencies
> - Ansible
> ```bash
> sudo apt update
> sudo apt install software-properties-common
> sudo add-apt-repository --yes --update ppa:ansible/ansible
> sudo apt install ansible
>  ```
> - Apptainer
> ```bash
> sudo apt install -y wget
> cd /tmp
> wget https://github.com/apptainer/apptainer/releases/download/v1.3.4/apptainer_1.3.4_amd64.deb
> sudo apt install -y ./apptainer_1.3.4_amd64.deb
> ```

 
Here are your quick instructions to build the containers:
```bash
git clone https://github.com/FoamScience/openfoam-apptainer-packaging /tmp/tainers
git clone https://github.com/FoamScience/cpl-openfoam-containers
cd cpl-openfoam-containers
ansible-playbook /tmp/tainers/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
# check containers/projects/cpl-openfoam-lammps*.sif
```

But you can also just pull it from GHCR.io:
```bash
# Adjust the container path accordingly
# cd path/to/cpl-openfoam-apptainer
apptainer pull cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675.sif oras://ghcr.io/foamscience/cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675:latest
alias cpl="apptainer run --sharens cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675.sif"
cpl info
```

Now to use the container:

> [!NOTE]
> The CPL/OpenFOAM/LAMMPS container is set-up in way that favours continuous development.
> So, you can compile the socket and any solvers into your repo
> (check lib and bin folders after running the `wmake` commands bellow).
> This way, you can retain the binaries between separate runs of the container,
> which is the preferred way (compared to interactive shells inside the container)
> for reproducibility reasons.

```bash
# enter the container
cpl
# get cpl oF socket
git clone https://github.com/Crompulence/CPL_APP_OPENFOAM
cd CPL_APP_OPENFOAM
# modify Pstream includes since OpenFOAM is patched ON THE CONTAINER
# this will not affect openFOAM in host
find . -name options -exec sed -i 's;$(FOAM_CPL_APP_SRC)/CPLPstream/lnInclude;$(LIB_SRC)/Pstream/mpi/lnInclude;' {} \;

# make CPL APP
source SOURCEME.sh; wmake src/CPLSocketFOAM
source SOURCEME.sh; wmake src/solvers/CPLTestFoam
source SOURCEME.sh; cd examples/CPLTestFoam && ./run.sh
# (You will have to make adjustments to Makefile if you want to compile with make)
```

Then you can post process on the host machine. Or, add processing tools to
[`projects/cpl-openfoam-lammps.def`](projects/cpl-openfoam-lammps.def) and rebuild the container.

If you want to alter the container itself in any way, create an overlay image and load it:
```bash
apptainer overlay create -s 1024 overlay.img #<- 1GB overlay image
apptainer run --sharens --overlay overlay.img path/to/cpl-openfoam-lammps*.sif
```

# CPL/OpenFOAM+LAMMPS containers with apptainer

> [!NOTE]
> Install dependencies, if you do not already have them
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


> [!NOTE]
> The CPL/OpenFOAM/LAMMPS container is set-up in way that favours continuous development.
> So, you can compile the socket and any solvers into your repo
> (check lib and bin folders after running the `wmake` commands bellow).
> This way, you can retain the binaries between separate runs of the container,
> which is the preferred way (compared to interactive shells inside the container)
> for reproducibility reasons.


If you want to alter the container itself in any way, create an overlay image and load it:
```bash
apptainer overlay create -s 1024 overlay.img #<- 1GB overlay image
```
Syntax to run a container with overlay image:
```bash
apptainer run --sharens --overlay overlay.img path/to/cpl-openfoam-lammps*.sif
```


Now to use the container via 2 methods
- Build the container locally:
    1. Building the container
    ```bash
    git clone https://github.com/FoamScience/openfoam-apptainer-packaging /tmp/tainers
    git clone https://github.com/FoamScience/cpl-openfoam-containers
    cd cpl-openfoam-containers
    ansible-playbook /tmp/tainers/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
    # Now a container is made in ./containers/projects/
    ```
    2. Run the `source enter_container.sh` script 
    3. Type `run_cpl`, then press tab
    4. Type the location of the overlay image, if it is outside the repo path
    5. Press enter
- Pull the container
```bash
# change to the repo directory
# Get the container
apptainer pull cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0.sif oras://ghcr.io/foamscience/cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0:latest

# enter the container
apptainer run --hostname cpl --sharens cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0.sif
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

Post process can be done on the host machine (outside of the container). 
Or, add processing tools to [`projects/cpl-openfoam-lammps.def`](projects/cpl-openfoam-lammps.def) and rebuild the container.



# TODOs
1. build scripts: add a cloner line
2. cpl alias: grep the one file existing in ?, then sub into the cpl alias 
3. tools.img: make script to make and populate a consistent environment 
```
(make overlay)
apptainer exec --overlay my_overlay.img my_container.sif bash -c '
    {Commands here} &&
    {Commands here}
'

```
4. 

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

 
Here are your quick instructions to build the containers (assuming you are already inside the repo):
```bash
git clone https://github.com/FoamScience/openfoam-apptainer-packaging /tmp/tainers
ansible-playbook /tmp/tainers/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
# check containers/projects/cpl-openfoam-lammps*.sif
```

But you can also just pull it from GHCR.io:
```bash
# Adjust the container path accordingly
# cd path/to/cpl-openfoam-apptainer
apptainer pull cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0.sif oras://ghcr.io/foamscience/cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0:latest
alias cpl="apptainer run --hostname cpl --sharens cpl-openfoam-lammps-2112-fcbc37d5a40e6dbd91148921378d28fca5294675-8.2.0.sif"
cpl info
```

Now to use the container:
```bash
# enter the container
cpl
# get cpl oF socket
git clone https://github.com/Crompulence/CPL_APP_OPENFOAM
cd CPL_APP_OPENFOAM
# modify Pstream includes since OpenFOAM is patched ON THE CONTAINER
# this will not affect openFOAM in host
find . -name options -exec sed -i 's;$(FOAM_CPL_APP_SRC)/CPLPstream/lnInclude;$(LIB_SRC)/Pstream/mpi/lnInclude;' {} \;
> [!NOTE]
> The CPL/OpenFOAM/LAMMPS container is set-up in way that favours continuous development.
> So, you can compile the socket and any solvers into your repo
> (check lib and bin folders after running the `wmake` commands bellow).
> This way, you can retain the binaries between separate runs of the container,
> which is the preferred way (compared to interactive shells inside the container)
> for reproducibility reasons.


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
apptainer overlay create -s 1024  tools.img #<- 1GB overlay image
apptainer run --sharens --overlay tools.img path/to/cpl-openfoam-lammps*.sif
```

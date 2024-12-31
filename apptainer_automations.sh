#!/bin/bash
# run in repo root 

get_tainers()
{
    rm -rf /tmp/tainers
    git clone https://github.com/FoamScience/openfoam-apptainer-packaging /tmp/tainers
}

build_cpl()
{
    # TOD unclear if 
    ansible-playbook /tmp/tainers/build.yaml --extra-vars "original_dir=$PWD" --extra-vars "@config.yaml"
}

run_cpl()
{
    # get the first image file. Apptainer cannot load multiple overlay images
    # overlay=$(find . -type f -name "*.img" | head -n 1) 
    
    # search first for the second argument passed in command line, then image in current directory. If no image found run without
    if [ -n "$2" ]; then 
        apptainer run --hostname cpl --sharens $1  --overlay $2
    elif [ -n "$overlay" ]; then
        apptainer run --hostname cpl --sharens $1  # TODO  --overlay $overlay
    else 
        apptainer run --hostname cpl --sharens $1  
    fi 
}

_run_cpl_autocomplete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -f ./containers/projects/) )
}

complete -F _run_cpl_autocomplete run_cpl





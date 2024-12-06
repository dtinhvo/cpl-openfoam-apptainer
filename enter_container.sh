#!/usr/bin/env bash

# TODOs:
# runner: gets fed $1: name 
run_cpl()
{
    # get the first image file. Apptainer cannot load multiple overlay images
    overlay=$(find . -type f -name "*.img" | head -n 1)
    
    # search first for the second argument passed in command line, then image in current directory. If no image found run without
    if [ -n "$2" ]; then 
        apptainer run --hostname cpl --sharens $1  --overlay $2
    elif [ -n "$overlay" ]; then
        apptainer run --hostname cpl --sharens $1   --overlay $overlay
    else 
        apptainer run --hostname cpl --sharens $1  
    fi 
}

_run_cpl_autocomplete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -f ./containers/projects/) )
}

complete -F _run_cpl_autocomplete run_cpl


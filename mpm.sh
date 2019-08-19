#!/usr/bin/env sh
#flp - manage FL Studio projects

# CONFIGURATION VARIABLES -----------------------------------------------------
FLP_PROJECT_HOME="${FLP_PROJECT_HOME:-$HOME}"

# FUNCTIONS -------------------------------------------------------------------
increment_id() { #1: id
    printf "%05d" "$(( $(echo "$1"|sed 's/^0*//') + 1 ))"
}

# SUBCOMMANDS -----------------------------------------------------------------
flp_init() { #1: template
    #First check whether we have the required arguments
    if [ $# -ne 1 ]; then
        echo "usage: flp init TEMPLATE" >/dev/stderr
        return 1
    fi
    mkdir -p ".store" ".store/history" ".store/meta"
    #PWD is the current working directory, should be the song name
    #It then uses a form of parameter expansion (look it up) on it, to cut off
    #parent directory names, and just return the last.
    #The template is just a path given on the command line. Yes, more ergonomic
    #solutions to this *definitely* exist, but you need to get used to working
    #with files.
    cp "$1" "${PWD##*/}.flp"
    echo "${1##*/}" >".store/meta/template" #Save the starting template name
}

flp_commit() {
    #The character > redirects standard output of a command to a file. The file
    #that we redirect it to is /dev/stderr in this case, which is the error
    #output. This is not redirected with pipes, and therefore useful for
    #out-of-band signalling (what errors are most of the time)
    echo "Not implemented yet" >/dev/stderr
    #exit with status code false/error
    exit 1
    #What this function *should* do is find out the current commit id from
    #".store/HEAD", increment it in some way, write that back, copy the project
    #file from the working directory to ".store/history" with the new commit id
    #as name.
}

flp_log() {
    ls -1 ".store/history"
}

# MAIN ------------------------------------------------------------------------
#this whole block is roughly equivalent to
#flp_"$@"
#I recommend you check why this works and replace it
case "$1" in
init)
    #Initialize new project in current directory
    shift;
    flp_init "$@"
    ;;
commit)
    #Add current state of working directory to log
    shift;
    flp_commit "$@"
    ;;
log)
    #See the log of commits
    shift;
    flp_log "$@"
    ;;
esac


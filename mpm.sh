#!/usr/bin/env sh
#flp - manage FL Studio projects

# CONFIGURATION VARIABLES -----------------------------------------------------
FLP_PROJECT_HOME="${FLP_PROJECT_HOME:-$HOME}"

# FUNCTIONS -------------------------------------------------------------------
increment_id() { #1: id
    printf "%05d" "$(( $(echo "$1"|sed 's/^0*//') + 1 ))"
}

# SUBCOMMANDS -----------------------------------------------------------------
flp_init() {
    # CATCH ERROR: FLP in folder > 0
    flp_files=$(find . -maxdepth 1 -type f -name "*.flp" | wc -l)
    if [ $flp_files -gt 0 ]; then
        echo "Error: this location has already been initialized" >/dev/stderr
        return 1
    fi

    # CATCH ERROR: Arguments != 2
    if [ $# -ne 2 ]; then
        echo "Usage: mpm init TEMPLATE ALBUM" >/dev/stderr
        return 1
    fi

    # ARGUMENTS
    template_path=$1
    album=$2

    # EXECUTE
    mkdir -p ".store" ".store/history" ".store/meta" # Create repository skeleton
    cp "$template_path" "decloud - $album - ${PWD##*/}.flp" # Create main FLP
    echo "${1##*/}" >".store/meta/template" # Store the starting template name
    echo "current_commit:0" >".store/HEAD" # Init meta-data: current_commit
    # FUTHER META-DATA HERE
}

flp_commit() {
    # CATCH ERROR: Incorrect FLP filename or incorrect meta-data

    # CATCH ERROR: FLP in folder > 1
    flp_files_amount=$(find . -maxdepth 1 -type f -name "*.flp" | wc -l)
    if [ $flp_files_amount -gt 1 ]; then
        echo "Error: there can only be 1 .flp file in directory" >/dev/stderr
        return 1
    fi

    # CATCH ERROR: Arguments != 1
    if [ $# -ne 1 ]; then
        echo "Usage: mpm commit DESCRIPTION" >/dev/stderr
        return 1
    fi

    # ARGUMENTS
    commit_description=$1

    # VARIABLES META-DATA
    current_commit=$(awk '{
        split($1,key_value,":");
        if (key_value[1]=="current_commit")
            print key_value[2]
    }' .store/HEAD)
    increased_commit=$(($current_commit + 1))

    # VARIABLES FLP
    main_flp=$(find . -maxdepth 1 -name \*.flp)
    main_flp_info=$(find . -maxdepth 1 -name \*.flp | sed 's;./;;g' | sed 's/.flp//g' | sed 's/ - /:/g')
    album=$(echo $main_flp_info | awk -F: '{print $2}')
    title=$(echo $main_flp_info | awk -F: '{print $3}')

    # VARIABLES OTHER
    datetime=$(date +%Y%m%d%H%M)

    # LOGIC: increased_commit
    if [ $increased_commit -lt 10 ]
    then
        increased_commit_string="00"$increased_commit
    elif [ $increased_commit -lt 100 ]
    then
        increased_commit_string="0"$increased_commit
    else
        increased_commit_string=$increased_commit
    fi

    # EXECUTE
    cp "${main_flp}" ".store/history/${increased_commit_string}_${datetime}_${album}_${title}_${commit_description}.flp" # Copy FLP to history
    sed -i "s/current_commit:$current_commit/current_commit:$increased_commit/g" .store/HEAD # Update meta-data
}

flp_log() {
    # 00n    2019-07-29 14:35    album    title    commit_description
    ls -1 ".store/history" | awk '{
        split($0,info,"_");
        print info[1] "    " substr(info[2],1,4) "-" substr(info[2],5,2) "-" substr(info[2],7,2) " " substr(info[2],9,2) ":" substr(info[2],11,2) "    " info[3] "    " info[4] "    " info[5]
        }' | sed 's/.flp//g'
}

# MAIN ------------------------------------------------------------------------
case "$1" in
init)
    #Initialize new project in current directory
    shift; # Shift all arguments such that the first argument will not be parsed
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
*)
    echo "Error: invalid command $1" >&2
    exit 1
    ;;
esac

# COMMENTS MICHIEL ------------------------------------------------------------------------

# MAIN ------------------------------------------------------------------------------------
#this whole block is roughly equivalent to
    #flp_"$@" <-- Geeft alle argumenten door aan de volgende functie.
    #I recommend you check why this works and replace it

# flp_init --------------------------------------------------------------------------------
#PWD is the current working directory, should be the song name
    #It then uses a form of parameter expansion (look it up) on it, to cut off
    #parent directory names, and just return the last.
    #The template is just a path given on the command line. Yes, more ergonomic
    #solutions to this *definitely* exist, but you need to get used to working
    #with files.

# flp_commit ------------------------------------------------------------------------------
#The character > redirects standard output of a command to a file. The file
    #that we redirect it to is /dev/stderr in this case, which is the error
    #output. This is not redirected with pipes, and therefore useful for
    #out-of-band signalling (what errors are most of the time)
        #echo "Not implemented yet" >/dev/stderr
    #exit with status code false/error
        #exit 1
    #What this function *should* do is find out the current commit id from
    #".store/HEAD", increment it in some way, write that back, copy the project
    #file from the working directory to ".store/history" with the new commit id
    #as name.
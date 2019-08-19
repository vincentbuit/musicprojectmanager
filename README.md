mpm - manage music project a bit like git
=========================================

Want to have a bit more control over your workflow when producing?
Have a lot of projects and want to be able to quickly look through
them? Think undo/redo is not reliable enough to be able to experiment
with your tracks? `mpm` is a tool that can help you keep track of
the music you make, and works a bit like `git`.

### Installation

    mkdir -p "${PREFIX:-$HOME/.local}/bin"
    export PATH="$PATH:${PREFIX:-$HOME/.local}/bin"
    PREFIX="${PREFIX:-$HOME/.local}" make install

### Development notes

  - To quickly check out a file and read it's contents in the shell, use:

        cat $file #where $file is the filename

  - To run the command again after editing, first run the last
    installation command (`make`).

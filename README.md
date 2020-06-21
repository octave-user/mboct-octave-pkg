# mboct-octave-pkg<sup>&copy;</sup>
**mboct-octave-pkg** belongs to a suite of packages which can be used for pre- and postprocessing of MBDyn models (https://www.mbdyn.org) with GNU-Octave (http://www.gnu.org/software/octave/). It contains general purpose utility functions used in all mboct-*-pkg packages.

# List of features
  - Start multiple processes using fork/exec on Linux and spawn on Windows systems.
  - Wait for the termination of processes using waitpid on Linux and cwait on Windows systems.
  - Execute processes using the POSIX shell on Linux and MSYS2 systems.
  - Distribute the execution of an Octave function to multiple processes.
  - Utility functions for generating and merging Adobe PDF files from Octave figures.
  - Utility functions to export Octave figures to ASCII CSV files.
  - Utility functions for tests and demos.
  
Copyright<sup>&copy;</sup> 2019-2020

[Reinhard](mailto:octave-user@a1.net)

# Installation

## GNU Octave installation
  - Follow the instructions on (http://www.gnu.org/software/octave/) to install GNU Octave.  
  - Make sure, that `mkoctfile` is installed.  
    `mkoctfile --version` 

## GNU Octave package installation:
  - Install the following packages from github.  
    `for pkg in octave; do`    
        `git clone https://github.com/octave-user/mboct-${pkg}-pkg.git && make -C mboct-${pkg}-pkg install_local`	  
    `done`

## Usage
  - Run Octave.  
    `octave`
  - At the Octave prompt load the package.   
    `pkg load mboct-octave-pkg`
  - At the Octave prompt execute the demos.  
    `demo run_parallel`
	

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
  - See [simple.yml](https://github.com/octave-user/mboct-octave-pkg/blob/master/.github/workflows/simple.yml) as an example on how to install mboct-octave-pkg.

# Function reference
  - The function reference is automatically generated from the source code by means of Octave's [generate_html](https://octave.sourceforge.io/generate_html/index.html) package. See [overview.html](https://octave-user.github.io/mboct-octave-pkg/mboct-octave-pkg/overview.html).

## Usage
  - Run Octave.
    `octave`
  - At the Octave prompt load the package.
    `pkg load mboct-octave-pkg`
  - At the Octave prompt execute the demos.
    `demo run_parallel`

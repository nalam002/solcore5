# Installation instructions (64-bit Ubuntu 16/18/20 or MacOS):

## Key steps:

```
git clone https://github.com/phoebe-p/S4
cd S4
make boost
make S4_pyext
```

`make boost` automatically downloads and compiles the relevant Boost libraries in the local S4 directory. This version of boost will be automatically linked when
compiling during `make S4_pyext`. If you want to use Boost libraries in a different location you will have to edit the Makefile.

## Installing relevant libraries etc.:

**On Ubuntu (with a working version of Python3):**

```
sudo apt-get update
sudo apt install make git gcc g++
sudo apt-get install libopenblas-dev libfftw3-dev libsuitesparse-dev
```

- libopenblas installs OpenBLAS, to satisfy the LAPACK and BLAS requirements
- lib fftw3 install FFTW3, to satisfy the FFTW requirements
- libsuitesparse install libraries to satisdy CHOLMOD & related requirements

**On MacOS using Homebrew:**

```
brew install fftw suite-sparse openblas lapack
```

You can get the make and git commands from homebrew, or through Apple Developer Tools. If the packages are installed/symlinked by Homebrew to the default location (/usr/local/include) you should not have to modify the Makefile, and you should be able to use the same Makefile as Ubuntu/Linux (i.e. no need to use Makefile.osx).

*If you have multiple Python versions, you make need to modify the S4_pyext part of the Makefile:*

````
pip3 install --upgrade ./
````

to e.g.:
```
[path of target python or virtual environment] setup.py install
```

You can install S4 into a vitual environment automatically by just activating that environment in your terminal before running `make S4_pyext`.

See [here](https://rayflare.readthedocs.io/en/latest/Installation/installation.html) for more extensive instructions.

-------------------------------------

S4: Stanford Stratified Structure Solver (http://fan.group.stanford.edu/S4/)

A program for computing electromagnetic fields in periodic, layered
structures, developed by Victor Liu (victorliu@alumni.stanford.edu) of the
Fan group in the Stanford Electrical Engineering Department.

See the S4 manual, in doc/index.html, for a complete
description of the package and its user interface, as well as
installation instructions, the license and copyright, contact
addresses, and other important information.

---------------------------------------

sajidmc: The MakefileHPC is created to compile the S4 in HPC environment without
root access. Also added an example for python extension testing: 

Check Wiki for details: https://github.com/sajidmc/S4/wiki
Example result: https://raw.githubusercontent.com/sajidmc/S4/master/examples/bontempi_et_al_Nanoscale_2017.png


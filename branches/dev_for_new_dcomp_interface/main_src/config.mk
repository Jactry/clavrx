# This file was generated on Fri Jan 31 12:24:49 2014 by awalther with the following command-line arguments: -hdf5root=/Users/awalther/lib/hdf5/ -with-ifort -hdflib=/Users/awalther/lib/hdf4//lib -hdfinc=/Users/awalther/lib/hdf4//include -nlcomp_dir=../../cloud_team_nlcomp/ -dcomp_dir=../../cloud_team_dcomp/ -acha_dir=../cloud_acha/.
# System info: Darwin luna.ssec.wisc.edu 13.0.0 Darwin Kernel Version 13.0.0: Thu Sep 19 22:22:27 PDT 2013; root:xnu-2422.1.72~6/RELEASE_X86_64 x86_64
fc = ifort
fflags = -O2 -assume byterecl
fflags_pfast = -O2 -assume byterecl -fixed
fflags_sasrab_f77 = -O2 -assume byterecl -fixed -save
fflags_sasrab_f90 = -O2 -assume byterecl -save
ldflags = -O2 -assume byterecl
cpp = -cpp
cppflags = 
beconv = -convert big_endian
hdflibs = -L/Users/awalther/lib/hdf4//lib -lmfhdf -ldf -ljpeg -lz
hdfincs = -I/Users/awalther/lib/hdf4//include
hdf5libs = -I/Users/awalther/lib/hdf5/include/ -L/Users/awalther/lib/hdf5/lib/
hdf5links = -lhdf5_fortran -lhdf5 -lz

export CMASK=../cloud_mask/
export CTYPE=../cloud_type/
export ACHA=../cloud_acha/
export DCOMP=../../cloud_team_dcomp/

export DCOMPHDF=../../cloud_team_dcomp/hdf4/lib/
export DCOMPHDFI=../../cloud_team_dcomp/hdf4/include/

dcomplibs=-L$(DCOMP) -I$(DCOMP)  -L$(DCOMPHDF)  -I$(DCOMPHDFI)

dcomplinks= -ldcomp

export NLCOMP=../../cloud_team_nlcomp/
nlcomplibs = -L$(NLCOMP) -I$(NLCOMP)
nlcomplinks= -lnlcomp -licaf90hdf


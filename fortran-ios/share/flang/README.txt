Flang Binary Release 2019-03-29
===============================

Flang is a Fortran compiler targeting LLVM.

The source is at http://github.com/flang-compiler/.
There are 4 repositories:
- llvm: The version of LLVM that we use to build Flang.
- flang-driver: A Clang fork used as the basis of the Flang driver.
- openmp: The version of OpenMP we use to buidl flang.
- flang: The Flang compiler itself.

This binary release was created from the flang_20190329 tag of Flang.
It contains the binaries and libraries suitable for running
Flang (LLVM 7.0) on x86_64 and OpenPOWER distributions.


Community Resources
-------------------

We have mailing lists for announcements and developers.
Here's the link with the sign-up information:

    http://lists.flang-compiler.org/mailman/listinfo

We have a flang-compiler channel on Slack. Slack is invitation
only but anyone can join. Here's the link:

    https://join.slack.com/t/flang-compiler/shared_invite/MjExOTEyMzQ3MjIxLTE0OTk4NzQyNzUtODQzZWEyMjkwYw


Installing
----------

To install the binary release, untar the .tgz file in
a location suitable for you. Add the bin directory to
your PATH and lib directory to your LD_LIBRARY_PATH,
after which you should be able to execute Flang.


Building Your First Program
---------------------------

To test your installation, create a simple "hello world" program, like the
following:

       program hello
         print *, 'hello world'
       end

Next, compile the program in the following manner. We will assume the
program is in a file called hello.f90

    $ flang hello.f90

If the build succeeds, then you can execute the program:

    $ ./a.out


Flang Binary Release Minimum Requirements
-----------------------------------------

Below are the minimum requirements to compile and run Flang:

    Host Processor:
        64-bit OpenPOWER
        64-bit x86 (including AMD64 and Intel 64)

    OpenPOWER Linux:
        Ubuntu 14.04, 16.04
        Red Hat Enterprise Linux 7.3, 7.4 for IBM Power (POWER8)
        Red Hat Enterprise Linux 7.4 for IBM Power LE (POWER9)

    x86-64 Linux:
        CentOS 5 or newer
        OpenSuSE 11 or newer including OpenSuSE Leap 42.2
        SUSE Linux Enterprise Server (SLES) 11 or newer
        Red Hat Enterprise Linux 5 or newer
        Fedora Core 6 or newer
        Ubuntu 12.04 or newer

Flang Binary Release File List
------------------------------

Below is a list of files in the tar archives for x86-64 and OpenPOWER:
    bin/flang
    bin/flang1
    bin/flang2
    include/ieee_arithmetic_la.mod
    include/ieee_arithmetic.mod
    include/ieee_exceptions_la.mod
    include/ieee_exceptions.mod
    include/ieee_features.mod
    include/iso_c_binding.mod
    include/iso_fortran_env.mod
    include/omp_lib.h
    include/omp_lib_kinds.mod
    include/omp_lib.mod
    lib/libflang.a
    lib/libflang.so
    lib/libflangmain.a
    lib/libflangrti.a
    lib/libflangrti.so
    lib/libomp.a
    lib/libomp.so
    lib/libompstub.a
    lib/libompstub.so
    lib/libpgmath.a
    lib/libpgmath.so

Compiler Options
----------------

For a list of compiler options, enter

    $ flang -help

The Flang compiler supports all clang 7.0 compiler options
as well as the following Flang-specific compiler options:

| Option                      | Description |
| :-----                      | :---------- |
| -byteswapio              | Swap byte-order for unformatted input/output
| -cpp                     | Preprocess Fortran files
| -fbackslash              | Treat backslash as C-style escape character
| -fdefault-integer-8      | Treat INTEGER and LOGICAL as INTEGER*8 and LOGICAL*8
| -fdefault-real-8         | Treat REAL as REAL*8
| -ffixed-form             | Enable fixed-form format for Fortran
| -ffixed-line-length-<value> | Set line length in fixed-form format Fortran, current supporting only 72 and 132 characters
| -ffree-form              | Enable free-form format for Fortran
| -fno-backslash           | Treat backslash like any other character in character strings
| -fno-fixed-form          | Disable fixed-form format for Fortran
| -fno-fortran-main        | Don't link in Fortran main
| -fno-free-form           | Disable free-form format for Fortran
| -Mallocatable=<value>    | Select semantics for assignments to allocatables (F03 or F95)
| -Minfo                   | Diagnostic information about all successful optimizations
| -Minform=<value>         | Set error level of messages to display
| -Minfo=<value>           | Diagnostic information about successful optimizations
| -Mneginfo                | Diagnostic information about all missed optimizations
| -Mneginfo=<value>        | Diagnostic information about missed optimizations
| -nocpp                   | Don't preprocess Fortran files
| -no-flang-libs           | Do not link against Flang libraries
| -static-flang-libs       | Link using static Flang libraries


Known Issues
------------

See the GitHub issues list for the known issues with Flang:
    http://github.com/flang-compiler/flang/issues


The following "check-flang" tests fail on OpenPOWER:

    f90_correct/lit/ieee18flushz.sh
    f90_correct/lit/ieee19flushz.sh
    ncar_kernels/CAM5_mg2_pgi/lit/t1.sh
    ncar_kernels/HOMME_vlaplace_sphere_wk/lit/t1.sh
    ncar_kernels/PORT_binterp/lit/t1.sh
    ncar_kernels/PORT_reftra_sw/lit/t1.sh
    ncar_kernels/PORT_rtrnmc/lit/t1.sh
    ncar_kernels/PORT_sw_reftra/lit/t1.sh
    ncar_kernels/PORT_sw_spcvmc/lit/t1.sh


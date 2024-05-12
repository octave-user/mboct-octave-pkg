dnl  Copyright (C) 2018(-2024) Reinhard <octave-user@a1.net>

dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 3 of the License, or
dnl (at your option) any later version.

dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.

dnl You should have received a copy of the GNU General Public License
dnl along with this program; If not, see <http://www.gnu.org/licenses/>.

AC_PREREQ([2.69])
AC_INIT([mboct-octave-pkg], [0.1.0])
AC_CONFIG_HEADERS([config.h])

AC_CONFIG_MACRO_DIRS([m4])

AM_INIT_AUTOMAKE

AC_ARG_VAR([PKG_CONFIG],[Program to return meta information about installed libraries])

AC_CHECK_PROG(MKOCTFILE, mkoctfile, mkoctfile)

if test -z "$MKOCTFILE"; then
  AC_MSG_ERROR([mkoctfile not found], 1);
fi

AC_CHECK_PROG(OCTAVE_CONFIG, octave-config, octave-config)

if test -z "$OCTAVE_CONFIG"; then
  AC_MSG_ERROR([octave-config not found], 1);
fi

PKG_CONFIG="${PKG_CONFIG:-pkg-config}"

OCTINCLUDEDIR="${OCTINCLUDEDIR:-`${MKOCTFILE} -p INCFLAGS`}"
OCTLIBDIR="${OCTLIBDIR:-`${MKOCTFILE} -p OCTLIBDIR`}"
OCTLIBS="${OCTLIBS:-`${MKOCTFILE} -p LIBOCTAVE` `${MKOCTFILE} -p LIBOCTINTERP`}"
OCTLDFLAGS="${OCTLDFLAGS:--L${OCTLIBDIR} -Wl,-rpath=${OCTLIBDIR} -Wl,--no-undefined}"
CXX="${CXX:-`${MKOCTFILE} -p CXX`}"
CXXFLAGS="${CXXFLAGS} `${MKOCTFILE} -p CXXFLAGS`"

GTEST_LIBDIR="${GTEST_LIBDIR:-`${PKG_CONFIG} --libs-only-L gtest`}"
GTEST_LDFLAGS="${GTEST_LDFLAGS:-`echo ${GTEST_LIBDIR} | sed 's/^-L/-Wl,-rpath=/'`}"
GTEST_LIBS="${GTEST_LIBS:-`${PKG_CONFIG} --libs gtest`}"
GTEST_LIBS="${GTEST_LIBS:--lgtest}"
GTEST_CPPFLAGS="${GTEST_CPPFLAGS:-`${PKG_CONFIG} --cflags gtest`}"

AC_PROG_CXX
AC_LANG(C++)

TCPPFLAGS="${CPPFLAGS}"
CPPFLAGS="${CPPFLAGS} ${OCTINCLUDEDIR}"

AC_CHECK_HEADERS(octave/oct.h octave/interpreter.h octave/parse.h, [], AC_MSG_ERROR([octave header files not found], 1))

TLDFLAGS="${LDFLAGS}"
TLIBS="${LIBS}"

dnl Force mkoctfile to link to Octave's libraries in order to avoid unresolved symbols at runtime
LDFLAGS="${LDFLAGS} ${OCTLDFLAGS}"
LIBS="${LIBS} ${OCTLIBS}"

AC_MSG_CHECKING([for octave libraries])
AC_TRY_LINK([
#include <octave/oct.h>
],[
octave_value_list ovl;
ovl.append(octave_value(1.5));
],[use_octlibs=yes],[use_octlibs=no])

AC_MSG_RESULT([${use_octlibs}])

if ! test "${use_octlibs}" = "yes"; then
  LDFLAGS="${TLDFLAGS}"
  LIBS="${TLIBS}"
fi

## Simple symbol alternatives of different Octave versions.
OF_OCTAVE_LIST_ALT_SYMS([
[dnl
  [is_cell],
  [iscell],
  [[octave_value ().iscell ();]],
  [OV_ISCELL],
  [],
  []
],

[dnl
  [is_integer_type],
  [isinteger],
  [[octave_value ().isinteger ();]],
  [OV_ISINTEGER],
  [],
  []
],

[dnl
  [feval],
  [octave::feval],
  [[octave::feval ("date");]],
  [OCTAVE__FEVAL],
  [[#include <octave/parse.h>]],
  [[#include <octave/parse.h>]]
]

],
   [oct-alt-includes.h])

AC_CHECK_HEADERS(vector string sstream stdint.h, [], AC_MSG_ERROR([standard C++ headers not found], 1))
AC_CHECK_HEADERS(process.h)
AC_CHECK_HEADERS(unistd.h)
AC_CHECK_HEADERS(sys/types.h)
AC_CHECK_HEADERS(sys/wait.h)

AC_CHECK_FUNCS(vfork execvp _exit waitpid)
AC_CHECK_FUNCS(spawnvp cwait)
AC_CHECK_FUNCS(_spawnvp _cwait)

if test "${ac_cv_func_fork}" = "no" && test "${ac_cv_func_spawnvp}" = "no" && test "${ac_cv_func__spawnvp}" = "no"; then
  AC_MSG_ERROR([neither fork nor spawn can be used], 1)
fi

TLIBS="${LIBS}"
LIBS="${LIBS} -lkernel32"
AC_MSG_CHECKING([for WIN32])
AC_TRY_LINK([
#if defined(_WIN32) || defined(WIN32)
#include <windows.h>
#endif
],[
#if defined(_WIN32) || defined(WIN32)
SECURITY_ATTRIBUTES oProcAttr = {sizeof(SECURITY_ATTRIBUTES)};
SECURITY_ATTRIBUTES oThreadAttr = {sizeof(SECURITY_ATTRIBUTES)};
STARTUPINFO oStartupInfo = {sizeof(STARTUPINFO)};
PROCESS_INFORMATION oProcessInfo = {0};
char strCommand[] = "ls -lhF";
BOOL bStatus = CreateProcess(NULL, strCommand, &oProcAttr, &oThreadAttr, TRUE, 0, NULL, NULL, &oStartupInfo, &oProcessInfo);
CloseHandle(oProcessInfo.hProcess);
CloseHandle(oProcessInfo.hThread);
#else
#error WIN32 is not defined
#endif
],[have_win32=yes],[have_win32=no])

AC_MSG_RESULT([${have_win32}])

if test "${have_win32}" = "yes"; then
  AC_DEFINE(HAVE_WIN32, [1], [define if WIN32 can be used])
else
  LIBS="${TLIBS}"
fi

TCPPFLAGS="${CPPFLAGS}"
TLIBS="${LIBS}"
TLDFLAGS="${LDFLAGS}"
CPPFLAGS="${CPPFLAGS} ${GTEST_CPPFLAGS}"
LIBS="${LIBS} ${GTEST_LIBS}"
LDFLAGS="${LDFLAGS} ${GTEST_LDFLAGS}"

AC_CHECK_HEADERS(gtest/gtest.h)

have_gtest="no"

if test "$ac_cv_header_gtest_gtest_h" = "yes" ; then
   AC_MSG_CHECKING([for GoogleTest library])
   AC_TRY_LINK([
        #include <gtest/gtest.h>
        TEST(OctaveGoogleTest, OctaveGoogleTest1)
        {
                try {
                } catch (...) {
                  ADD_FAILURE_AT(__FILE__, __LINE__);
                }
        }],[
        int argc;
        char** argv;
        testing::InitGoogleTest(&argc, argv);
        return RUN_ALL_TESTS();
   ],[have_gtest=yes],[have_gtest=no])
   AC_MSG_RESULT([${have_gtest}])
fi

if test "${have_gtest}" = "yes"; then
  AC_DEFINE(HAVE_GTEST, [1], [define if GoogleTest can be used])
else
  CPPFLAGS="${TCPPFLAGS}"
  LDFLAGS="${TLDFLAGS}"
  LIBS="${TLIBS}"
fi

AM_CONDITIONAL([USE_GTEST], [test ${have_gtest} = "yes"])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

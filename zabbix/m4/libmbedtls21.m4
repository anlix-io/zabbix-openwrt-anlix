# mbed TLS 2.1.x (PolarSSL) LIBMBEDTLS21_CHECK_CONFIG ([DEFAULT-ACTION])
# ----------------------------------------------------------
# Derived from libssh2.m4 written by
#    Alexander Vladishev                      Oct-26-2009
#    Dmitry Borovikov                         Feb-13-2010
#
# Checks for mbed TLS 2.1.x (PolarSSL) library libmbedtls.  DEFAULT-ACTION
# is the string yes or no to specify whether to default to --with-mbedtls21 or
# --without-mbedtls21. If not supplied, DEFAULT-ACTION is no.
#
# This macro #defines HAVE_MBEDTLS21 if a required header files are
# found, and sets @MBEDTLS21_LDFLAGS@, @MBEDTLS21_CFLAGS@ and @MBEDTLS21_LIBS@
# to the necessary values.
#
# Users may override the detected values by doing something like:
# MBEDTLS21_LIBS="-lmbedtls -lmbedx509 -lmbedcrypto" MBEDTLS21_CFLAGS="-I/usr/myinclude" ./configure
#
# This macro is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

AC_DEFUN([LIBMBEDTLS21_TRY_LINK],
[
AC_TRY_LINK(
[
#include <mbedtls/ssl.h>
],
[
	mbedtls_ssl_context	ssl;

	mbedtls_ssl_init(&ssl);
],
found_mbedtls21="yes",)
])dnl

AC_DEFUN([LIBMBEDTLS21_ACCEPT_VERSION],
[
	# Zabbix minimal supported version of libmbedtls:
	minimal_mbedtls21_version_major=2
	minimal_mbedtls21_version_minor=1
	minimal_mbedtls21_version_patch=9

	# get version
	found_mbedtls21_version_major=`cat $1 | $EGREP \#define.*MBEDTLS_VERSION_MAJOR | $AWK '{print @S|@3;}'`
	found_mbedtls21_version_minor=`cat $1 | $EGREP \#define.*MBEDTLS_VERSION_MINOR | $AWK '{print @S|@3;}'`
	found_mbedtls21_version_patch=`cat $1 | $EGREP \#define.*MBEDTLS_VERSION_PATCH | $AWK '{print @S|@3;}'`

	if test $((found_mbedtls21_version_major)) -gt $((minimal_mbedtls21_version_major)); then
		accept_mbedtls21_version="yes"
	elif test $((found_mbedtls21_version_major)) -lt $((minimal_mbedtls21_version_major)); then
		accept_mbedtls21_version="no"
	elif test $((found_mbedtls21_version_minor)) -gt $((minimal_mbedtls21_version_minor)); then
		accept_mbedtls21_version="yes"
	elif test $((found_mbedtls21_version_minor)) -lt $((minimal_mbedtls21_version_minor)); then
		accept_mbedtls21_version="no"
	elif test $((found_mbedtls21_version_patch)) -ge $((minimal_mbedtls21_version_patch)); then
		accept_mbedtls21_version="yes"
	else
		accept_mbedtls21_version="no"
	fi;
])dnl

AC_DEFUN([LIBMBEDTLS21_CHECK_CONFIG],
[
  AC_ARG_WITH(mbedtls21,[
If you want to use encryption provided by mbed TLS 2.1.x (PolarSSL) library:
AC_HELP_STRING([--with-mbedtls21@<:@=DIR@:>@],[use mbed TLS 2.1.x (PolarSSL) package @<:@default=no@:>@, DIR is the libmbedtls install directory.])],
    [
	if test "$withval" = "no"; then
	    want_mbedtls21="no"
	    _libmbedtls21_dir="no"
	elif test "$withval" = "yes"; then
	    want_mbedtls21="yes"
	    _libmbedtls21_dir="no"
	else
	    want_mbedtls21="yes"
	    _libmbedtls21_dir=$withval
	fi
	accept_mbedtls21_version="no"
    ],[want_mbedtls21=ifelse([$1],,[no],[$1])]
  )

  if test "x$want_mbedtls21" = "xyes"; then
     AC_MSG_CHECKING(for mbed TLS 2.1.x (PolarSSL) support)

     if test "x$_libmbedtls21_dir" = "xno"; then
       if test -f /usr/local/include/mbedtls/version.h; then
         MBEDTLS21_CFLAGS=-I/usr/local/include
         MBEDTLS21_LDFLAGS=-L/usr/local/lib
         MBEDTLS21_LIBS="-lmbedtls -lmbedx509 -lmbedcrypto"
         found_mbedtls21="yes"
         LIBMBEDTLS21_ACCEPT_VERSION([/usr/local/include/mbedtls/version.h])
       elif test -f /usr/include/mbedtls/version.h; then
         MBEDTLS21_CFLAGS=-I/usr/include
         MBEDTLS21_LDFLAGS=-L/usr/lib
         MBEDTLS21_LIBS="-lmbedtls -lmbedx509 -lmbedcrypto"
         found_mbedtls21="yes"
         LIBMBEDTLS21_ACCEPT_VERSION([/usr/include/mbedtls/version.h])
       else			# libraries are not found in default directories
         found_mbedtls21="no"
         AC_MSG_RESULT(no)
       fi
     else
       if test -f $_libmbedtls21_dir/include/mbedtls/version.h; then
         MBEDTLS21_CFLAGS=-I$_libmbedtls21_dir/include
         MBEDTLS21_LDFLAGS=-L$_libmbedtls21_dir/lib
         MBEDTLS21_LIBS="-lmbedtls -lmbedx509 -lmbedcrypto"
         found_mbedtls21="yes"
         LIBMBEDTLS21_ACCEPT_VERSION([$_libmbedtls21_dir/include/mbedtls/version.h])
       else
         found_mbedtls21="no"
         AC_MSG_RESULT(no)
       fi
     fi
  fi

  if test "x$found_mbedtls21" = "xyes"; then
    am_save_cflags="$CFLAGS"
    am_save_ldflags="$LDFLAGS"
    am_save_libs="$LIBS"

    CFLAGS="$CFLAGS $MBEDTLS21_CFLAGS"
    LDFLAGS="$LDFLAGS $MBEDTLS21_LDFLAGS"
    LIBS="$LIBS $MBEDTLS21_LIBS"

    found_mbedtls21="no"
    LIBMBEDTLS21_TRY_LINK([no])

    CFLAGS="$am_save_cflags"
    LDFLAGS="$am_save_ldflags"
    LIBS="$am_save_libs"

    if test "x$found_mbedtls21" = "xyes"; then
      AC_DEFINE([HAVE_MBEDTLS21], 1, [Define to 1 if you have the 'libmbedtls' 2.1.x library (-lmbedtls -lmbedx509 -lmbedcrypto)])
      AC_MSG_RESULT(yes)
    else
      AC_MSG_RESULT(no)
      MBEDTLS21_CFLAGS=""
      MBEDTLS21_LDFLAGS=""
      MBEDTLS21_LIBS=""
    fi
  fi

  AC_SUBST(MBEDTLS21_CFLAGS)
  AC_SUBST(MBEDTLS21_LDFLAGS)
  AC_SUBST(MBEDTLS21_LIBS)

])dnl

# -*- coding: utf-8; mode: tcl; c-basic-offset: 4; indent-tabs-mode: nil; tab-width: 4; truncate-lines: t -*- vim:fenc=utf-8:et:sw=4:ts=4:sts=4
#
# Usage:
# PortGroup     old_openssl 1.0
#
# This port group is for ports that are incompatible with the latest OpenSSL.
# It's not needed for most ports.
#
# options:
# openssl.branch: the OpenSSL branch to use (e.g. 1.0 for the latest OpenSSL on the 1.0.x branch).
#   Currently 1.0 and 1.1 are available.

options openssl.branch openssl.includedir openssl.libdir openssl.dir
default openssl.branch 1.0
default openssl.includedir      {${prefix}/include/openssl-${openssl.branch}}
default openssl.libdir          {${prefix}/lib/openssl-${openssl.branch}}

# use for ports that expect to find openssl includes and libs in one directory
default openssl.dir             {${prefix}/libexec/openssl-${openssl.branch}}

option_proc openssl.branch openssl_set_branch

proc openssl_set_branch {option action args} {
    if {$action ne "set"} {
        return
    }

    global openssl.branch

    set branch_no_dot [string map {. ""} ${openssl.branch}]

    depends_lib-delete      path:lib/libssl.dylib:openssl
    depends_lib-append      port:openssl${branch_no_dot}
}

proc openssl.configure {method} {
    global prefix openssl.branch openssl.includedir openssl.libdir

    switch ${method} {
        pkgconfig {
            configure.pkg_config_path-prepend ${prefix}/lib/openssl-${openssl.branch}/pkgconfig
            depends_build-delete port:pkgconfig
            depends_build-append port:pkgconfig
        }
        build_flags {
            configure.cppflags-prepend -I${openssl.includedir}
            configure.ldflags-prepend -L${openssl.libdir}
        }

        # this option can be used to allow pkgconfig to spec all the libraries but
        # also prepend the openssl include and lib directories. This option fixes some
        # builds when the other two options individually do not

        pkgconfig_and_build_flags {
            configure.pkg_config_path-prepend ${prefix}/lib/openssl-${openssl.branch}/pkgconfig
            depends_build-delete port:pkgconfig
            depends_build-append port:pkgconfig
            configure.cppflags-prepend -I${openssl.includedir}
            configure.ldflags-prepend  -L${openssl.libdir}
        }
        default {
            return -code error "invalid method \"${method}\" for openssl.configure"
        }
    } 
}

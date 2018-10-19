# zabbix-openwrt

Fork of Zabbix 3.2.7 for use with OpenWRT. Includes patches to allow compiling with libmbedtls 2.1.x and some fixes for OpenWRT systems.

## Build Instructions ##

1. `cd zabbix`
2. `aclocal`
3. `autoconf`
4. `autoheader`
5. `automake`
6. `./configure --host=<architecture> --enable-agent --disable-java --enable-ipv6 --with-mbedtls21=/path/to/toolchain/usr CFLAGS="Os"
7. `make`

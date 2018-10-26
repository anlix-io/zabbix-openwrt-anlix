#
# Copyright (C) 2017-2017 LAND/COPPE/UFRJ
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zabbix-anlix
PKG_VERSION:=3.2.7
PKG_RELEASE:=1

PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=COPYING

# PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/zabbix-anlix/Default
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Zabbix Anlix
  URL:=https://github.com/anlix-io/zabbix-openwrt-anlix
  SUBMENU:=zabbix-anlix
  MAINTAINER:=Guilherme da Silva Senges <guilherme@anlix.io>
  USERID:=zabbix=53:zabbix=53
  DEPENDS += $(ICONV_DEPENDS)
endef

define Package/zabbix-anlix-agentd
  $(call Package/zabbix-anlix/Default)
  TITLE+= agentd
endef

define Package/zabbix-anlix-extra-mac80211
  $(call Package/zabbix-anlix/Default)
  TITLE+= discovery/userparameters for mac80211
  DEPENDS = +zabbix-anlix-agentd @PACKAGE_MAC80211_DEBUGFS @KERNEL_DEBUG_FS
endef

define Package/zabbix-anlix-extra-network
  $(call Package/zabbix-anlix/Default)
  TITLE+= discovery/userparameters for network
  DEPENDS = +zabbix-anlix-agentd +libuci-lua +lua
endef

define Package/zabbix-anlix-extra-wifi
  $(call Package/zabbix-anlix/Default)
  TITLE+= discovery/userparameters for wifi
  DEPENDS = +zabbix-anlix-agentd +libiwinfo-lua +libuci-lua +lua
endef

define Package/zabbix-anlix-extra-mac80211/description
An extra package for zabbix-agentd that adds a discovery rule for mac80211 wifi phy and many userparameters.
It contains an suid helper to allow zabbix-agentd to still run as zabbix user and not as root.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-anlix-extra-network/description
An extra package for zabbix-agentd that adds a discovery rule for openwrt network interfaces.
The idea here is to discover only interfaces listed in /etc/config/network (discover br-lan and not eth0.1 and wlan0)
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-anlix-extra-wifi/description
An extra package for zabbix-agentd that adds a discovery rule for wifi interfaces and many userparameters.
As it uses libiwinfo, it works with all wifi devices supported by openwrt.
See http://wiki.openwrt.org/doc/howto/zabbix for ready to use zabbix templates.
endef

define Package/zabbix-anlix/install/zabbix.conf.d
  $(INSTALL_DIR) \
    $(1)/etc/zabbix_agentd.conf.d

  $(INSTALL_BIN) \
    ./files/$(2) \
    $(1)/etc/zabbix_agentd.conf.d/$(2)
endef

define Package/zabbix-anlix-agentd/conffiles
/etc/zabbix_agentd.conf
endef

define Build/Prepare/zabbix-anlix-agentd
  cd zabbix
  aclocal
  autoconf
  autoheader
  automake --add-missing
  ./configure --enable-agent --disable-java --enable-ipv6 CFLAGS="Os"
  cd ..
endef

ifdef CONFIG_PACKAGE_zabbix-anlix-extra-mac80211
define Build/Prepare/zabbix-anlix-extra-mac80211
  mkdir -p $(PKG_BUILD_DIR)/zabbix-anlix-extra-mac80211
  $(CP) ./files/zabbix_helper_mac80211.c $(PKG_BUILD_DIR)/zabbix-anlix-extra-mac80211/
endef

define Build/Compile/zabbix-anlix-agentd
  cd zabbix
  make
  cd ..
endef

define Build/Compile/zabbix-anlix-extra-mac80211
  $(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/zabbix-anlix-extra-mac80211/zabbix_helper_mac80211.c -o $(PKG_BUILD_DIR)/zabbix-anlix-extra-mac80211/zabbix_helper_mac80211
endef
endif

define Build/Prepare
  $(call Build/Prepare/zabbix-anlix-agentd)
  $(call Build/Prepare/zabbix-anlix-extra-mac80211)
endef

define Build/Compile
  $(call Build/Compile/zabbix-anlix-agentd)
  $(call Build/Compile/zabbix-anlix-extra-mac80211)
endef

define Package/zabbix-anlix-agentd/install
  $(INSTALL_DIR) $(1)/usr/sbin
  $(INSTALL_DIR) $(1)/etc
  $(INSTALL_DIR) $(1)/etc/init.d
  $(INSTALL_DIR) $(1)/etc/zabbix_agentd.conf.d
  $(INSTALL_BIN) ./zabbix/src/zabbix_agent/zabbix_agentd $(1)/usr/sbin/
  $(INSTALL_BIN) ./files/zabbix_agentd.init $(1)/etc/init.d/zabbix_agentd
  $(INSTALL_CONF) ./zabbix/conf/zabbix_agentd.conf $(1)/etc/
endef

define Package/zabbix-anlix-extra-mac80211/install
  $(call Package/zabbix-anlix/install/zabbix.conf.d,$(1),mac80211)
  $(INSTALL_DIR) $(1)/usr/bin
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/zabbix-anlix-extra-mac80211/zabbix_helper_mac80211 $(1)/usr/bin/
  chmod 4755 $(1)/usr/bin/zabbix_helper_mac80211
endef

define Package/zabbix-anlix-extra-network/install
  $(call Package/zabbix-anlix/install/zabbix.conf.d,$(1),network)
endef

define Package/zabbix-anlix-extra-wifi/install
  $(call Package/zabbix-anlix/install/zabbix.conf.d,$(1),wifi)
endef

$(eval $(call BuildPackage,zabbix-anlix-agentd))
$(eval $(call BuildPackage,zabbix-anlix-extra-mac80211))
$(eval $(call BuildPackage,zabbix-anlix-extra-network))
$(eval $(call BuildPackage,zabbix-anlix-extra-wifi))

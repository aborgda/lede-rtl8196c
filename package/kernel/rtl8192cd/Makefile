include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=rtl8192cd
PKG_RELEASE:=1
PKG_LICENSE:=Proprietary
PKG_MAINTAINER:=Realtek legacy driver integration

include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8192cd
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8192ER/RTL8812AR legacy WLAN driver
  DEPENDS:=+kmod-cfg80211
  KCONFIG:=CONFIG_RTL8192CD=m
  FILES:=$(LINUX_DIR)/drivers/net/wireless/rtl8192cd/rtl8192cd.ko
  AUTOLOAD:=$(call AutoLoad,50,rtl8192cd)
endef

define KernelPackage/rtl8192cd/description
 Legacy Realtek rtl8192cd driver with RTL8192ER 2.4 GHz and RTL8812AR 5 GHz support.
endef

$(eval $(call KernelPackage,rtl8192cd))

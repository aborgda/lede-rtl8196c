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

define KernelPackage/rtl8192er
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8192ER 2.4 GHz WLAN (rtl8192cd backend)
  DEPENDS:=+kmod-rtl8192cd
  HIDDEN:=1
endef

define KernelPackage/rtl8192er/description
RTL8192ER board package using the legacy rtl8192cd driver and RTL8192E HAL.
endef

$(eval $(call KernelPackage,rtl8192er))

define KernelPackage/rtl8812er
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8812ER 5 GHz WLAN (rtl8192cd backend)
  DEPENDS:=+kmod-rtl8192cd
  HIDDEN:=1
endef

define KernelPackage/rtl8812er/description
RTL8812ER board package using the legacy rtl8192cd driver and RTL8812/ODM support.
endef

$(eval $(call KernelPackage,rtl8812er))

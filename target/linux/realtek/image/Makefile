#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += CVIMG_LOADER_START_ADDR CVIMG_KERNEL_BURN_ADDR CVIMG_ROOTFS_BURN_ADDR CVIMG_CPU_TYPE CVIMG_CUSTOM_SIGNATURE

define Build/loader-common
	rm -rf $@.src
	$(MAKE) -C lzma-loader \
		PKG_BUILD_DIR="$@.src" \
		TARGET_DIR="$(dir $@)" LOADER_NAME="$(notdir $@)" \
		BOARD="$(BOARDNAME)" \
		LZMA_TEXT_START=$(CVIMG_LOADER_START_ADDR) LOADADDR=0x80000000 \
		$(1) compile loader.$(LOADER_TYPE)
	mv "$@.$(LOADER_TYPE)" "$@"
	rm -rf $@.src
endef

define Build/loader-compile
	$(call Build/loader-common,LOADER_DATA="$@")
endef

define Build/loader-cmdline-compile
	$(call Build/loader-common,LOADER_DATA="$@" KERNEL_CMDLINE="$(CMDLINE)")
endef

define Build/cvimg
	$(STAGING_DIR_HOST)/bin/cvimg \
		-i $@ \
		-o $@.new \
		$(1) && mv $@.new $@ || rm -f $@
endef

define Build/cvimg-kernel
	$(call Build/cvimg, \
		-e $(CVIMG_LOADER_START_ADDR) \
		-b $(CVIMG_KERNEL_BURN_ADDR) \
		-c $(CVIMG_CPU_TYPE) \
		-t kernel \
		$(1))
endef

define Build/cvimg-fw
	$(call Build/cvimg, \
		-e $(CVIMG_LOADER_START_ADDR) \
		-b $(CVIMG_KERNEL_BURN_ADDR) \
		-c $(CVIMG_CPU_TYPE) \
		-t fw \
		$(1))
endef

define Build/cvimg-custom
	$(call Build/cvimg, \
		-e $(CVIMG_LOADER_START_ADDR) \
		-b $(CVIMG_KERNEL_BURN_ADDR) \
		-s $(CVIMG_CUSTOM_SIGNATURE) \
		$(1))
endef

define Build/cvimg-rootfs
	$(call Build/cvimg, \
		-e $(CVIMG_ROOTFS_BURN_ADDR) \
		-b $(CVIMG_ROOTFS_BURN_ADDR) \
		-c $(CVIMG_CPU_TYPE) \
		-t rootfs \
		$(1))
endef

define Build/append-cvimg-rootfs
	cp $(IMAGE_ROOTFS) $(IMAGE_ROOTFS).new && \
	$(STAGING_DIR_HOST)/bin/padjffs2 $(IMAGE_ROOTFS).new \
		$(if $(BLOCKSIZE),$(BLOCKSIZE:%k=%),4 8 16 64 128 256) && \
	$(STAGING_DIR_HOST)/bin/cvimg \
		-i $(IMAGE_ROOTFS).new \
		-o $(IMAGE_ROOTFS).new \
		-e $(CVIMG_ROOTFS_BURN_ADDR) \
		-b $(CVIMG_ROOTFS_BURN_ADDR) \
		-c $(CVIMG_CPU_TYPE) \
		-t rootfs \
		$(1) && (dd if=$(IMAGE_ROOTFS).new >> $@ && \
			rm -f $(IMAGE_ROOTFS).new) || rm -f $@ $(IMAGE_ROOTFS).new
endef

define Build/append-fake-rootfs
	$(call Build/cvimg, \
		-a $(BLOCKSIZE) \
		-f)
endef

define Build/cvimg-pad-rootfs
	$(call Build/cvimg, \
		-b $(CVIMG_KERNEL_BURN_ADDR) \
		-c $(CVIMG_CPU_TYPE) \
		-a $(BLOCKSIZE) \
		-t rootfs \
		-j)
endef

define Device/Default
  BOARDNAME :=
  DEVICE_PROFILE = $$(BOARDNAME)
  PROFILES = Default $$(DEVICE_PROFILE)
  MTDPARTS :=
  BLOCKSIZE := 4k
  CONSOLE = ttyS0,115200
  CMDLINE = $$(if $$(BOARDNAME),machtype=$$(BOARDNAME)) $$(if $$(MTDPARTS),mtdparts=$$(MTDPARTS)) $$(if $$(CONSOLE),console=$$(CONSOLE))
  CVIMG_LOADER_START_ADDR := 0x80500000
  CVIMG_ROOTFS_BURN_ADDR := 0
  CVIMG_CPU_TYPE := new
  LOADER_TYPE := bin
  KERNEL := kernel-bin | lzma | loader-cmdline-compile
  FILESYSTEMS := squashfs
  IMAGES := factory.bin sysupgrade.bin
  IMAGE/factory.bin = append-kernel | append-fake-rootfs | append-rootfs | cvimg-fw | cvimg-pad-rootfs
  IMAGE/sysupgrade.bin = append-kernel | append-fake-rootfs | append-rootfs | cvimg-fw | pad-rootfs
endef

define Device/au-home-spot-cube
  DEVICE_TITLE := AU HOME SPOT CUBE
  BOARDNAME := AU-HOME-SPOT-CUBE
  CVIMG_KERNEL_BURN_ADDR := 0x9e000
  CONSOLE = ttyS0,38400
  MTDPARTS := spi0.0:32k(bootloader)ro,-@0x9e000(firmware)
endef
TARGET_DEVICES += au-home-spot-cube

define Device/RTL8198C_LEGACY
  $(Device/Default)
  CVIMG_LOADER_START_ADDR := 0x80a00000
  CVIMG_CPU_TYPE := new
  # RTL8198C 16 MiB SPI-NOR: 128 KiB boot area + 15872 KiB firmware.
  IMAGE_SIZE := 15872k
  MTDPARTS := spi0.0:128k(bootloader)ro,15872k(firmware)
endef

define Device/GN866_AC
  $(Device/RTL8198C_LEGACY)
  BOARDNAME := GN866-AC
  DEVICE_TITLE := GN866 AC (RTL8198C + RTL8192ER + RTL8192BRH)
  CVIMG_KERNEL_BURN_ADDR := 0x30000
  CVIMG_ROOTFS_BURN_ADDR := 0x260000
  IMAGE_SIZE := 15872k
endef
TARGET_DEVICES += GN866_AC

define Build/sk337
	python3 $(TOPDIR)/target/linux/realtek/image/sk337-pack.py $@ $(IMAGE_ROOTFS) $@.new
	mv $@.new $@
endef

define Device/SK337
  $(Device/RTL8198C_LEGACY)
  BOARDNAME := SK337
  DEVICE_TITLE := SK337 (RTL8198C + RTL8192E + RTL8812AR)
  CVIMG_KERNEL_BURN_ADDR := 0x31000
  CVIMG_ROOTFS_BURN_ADDR := 0x210000
  IMAGE_SIZE := 32256k
  KERNEL := kernel-bin | lzma | loader-cmdline-compile
  IMAGES := factory.bin sysupgrade.bin
  IMAGE/factory.bin := sk337
  IMAGE/sysupgrade.bin := sk337
endef


define Device/KT410
  $(Device/RTL8198C_LEGACY)
  BOARDNAME := KT410
  DEVICE_TITLE := KT410 (RTL8198 + RTL8192E + RTL8812AR)
  CVIMG_KERNEL_BURN_ADDR := 0x11000
  CVIMG_ROOTFS_BURN_ADDR := 0x210000
  IMAGE_SIZE := 15872k
endef
TARGET_DEVICES += KT410

define Device/KT510
  $(Device/RTL8198C_LEGACY)
  BOARDNAME := KT510
  DEVICE_TITLE := KT510 (RTL8198 + RTL8192ER + RTL8812AR)
  CVIMG_KERNEL_BURN_ADDR := 0x11000
  CVIMG_ROOTFS_BURN_ADDR := 0x411000
  IMAGE_SIZE := 15872k
endef
TARGET_DEVICES += KT510

$(eval $(call BuildImage))

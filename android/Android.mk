# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2021, GlobalLogic Ukraine
# Copyright (C) 2021, Roman Stratiienko (r.stratiienko@gmail.com)
# Copyright (C) 2023, KonstaKANG
#
# Android.mk - Android makefile
#

LOCAL_PATH := $(call my-dir)
LIBDAV1D_TOP := $(dir $(LOCAL_PATH))

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libc libdl
MESON_GEN_PKGCONFIGS := dl

ifeq ($(TARGET_IS_64_BIT),true)
LOCAL_MULTILIB := 64
else
LOCAL_MULTILIB := 32
endif
include $(LOCAL_PATH)/meson_cross.mk

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
include $(LOCAL_PATH)/meson_cross.mk
endif

#-------------------------------------------------------------------------------

define libdav1d-lib
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE := $1
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := $2
ifdef TARGET_2ND_ARCH
LOCAL_SRC_FILES_$(TARGET_ARCH) := $(call relative_top_path,$(LOCAL_PATH))$($3)
LOCAL_SRC_FILES_$(TARGET_2ND_ARCH) := $(call relative_top_path,$(LOCAL_PATH))$(2ND_$3)
LOCAL_MULTILIB := both
else
LOCAL_SRC_FILES := $(call relative_top_path,$(LOCAL_PATH))$($3)
endif
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)
include $(CLEAR_VARS)
endef

__MY_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES)
include $(CLEAR_VARS)
LOCAL_SHARED_LIBRARIES := $(__MY_SHARED_LIBRARIES)

# Modules 'libdav1d', produces '/vendor/lib{64}/libdav1d.so'
$(eval $(call libdav1d-lib,libdav1d,,LIBDAV1D_BIN))

#-------------------------------------------------------------------------------

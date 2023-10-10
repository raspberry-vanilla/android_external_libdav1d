# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2021, GlobalLogic Ukraine
# Copyright (C) 2021, Roman Stratiienko (r.stratiienko@gmail.com)
# Copyright (C) 2023, KonstaKANG
#
# meson_cross.mk - Android makefile
#

# Turn "dir1/dir2/dir3/dir4" into "../../../../"
define relative_top_path
$(eval __s:=) \
$(foreach tmp,$(subst /,$(space),$1),$(eval __s:=$(__s)../)) \
$(__s)
endef

MY_PATH := $(call my-dir)

AOSP_ABSOLUTE_PATH := $(realpath .)

libdav1d_m_dummy_$(LOCAL_MULTILIB) := $(TARGET_OUT_INTERMEDIATES)/LIBDAV1D_DUMMY_$(LOCAL_MULTILIB)/dummy.c

$(libdav1d_m_dummy_$(LOCAL_MULTILIB)):
	mkdir -p $(dir $@)
	touch $@

LOCAL_SRC_FILES := $(call relative_top_path,$(MY_PATH))$(libdav1d_m_dummy_$(LOCAL_MULTILIB))
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE := libdav1d.dummy.$(LOCAL_MULTILIB)

# Prepare intermediate variables by AOSP make/core internals
include $(BUILD_SHARED_LIBRARY)

LOCAL_PATH := $(MY_PATH)

link_deps := \
	$(built_static_libraries) \
	$(built_shared_libraries) \
	$(built_whole_libraries) \
	$(strip $(all_objects)) \
	$(my_target_libatomic) \
	$(my_target_libcrt_builtins) \
	$(my_target_crtbegin_so_o) \
	$(my_target_crtend_so_o)

# Build using intermediate variables provided by AOSP make/core internals
M_TARGET_PREFIX := $(my_2nd_arch_prefix)

LIBDAV1D_LIB_DIR := lib$(subst 32,,$(LOCAL_MULTILIB))

MESON_OUT_DIR                            := $($(M_TARGET_PREFIX)TARGET_OUT_INTERMEDIATES)/MESON_LIBDAV1D
MESON_GEN_DIR                            := $(MESON_OUT_DIR)_GEN
MESON_GEN_FILES_TARGET                   := $(MESON_GEN_DIR)/.timestamp

$(M_TARGET_PREFIX)LIBDAV1D_BIN := $(MESON_OUT_DIR)/install/usr/local/lib/libdav1d.so

LIBDAV1D_BINS := \
	$($(M_TARGET_PREFIX)LIBDAV1D_BIN) \

MESON_GEN_NINJA := \
	cd $(MESON_OUT_DIR) && PATH=/usr/bin:/usr/local/bin:$$PATH meson ./build \
	--cross-file $(AOSP_ABSOLUTE_PATH)/$(MESON_GEN_DIR)/aosp_cross           \
	--buildtype=release                                                      \

MESON_BUILD := PATH=/usr/bin:/bin:/sbin:$$PATH ninja -C $(MESON_OUT_DIR)/build

$(MESON_GEN_FILES_TARGET): MESON_CPU_FAMILY := $(subst arm64,aarch64,$(TARGET_$(M_TARGET_PREFIX)ARCH))

define create-pkgconfig
echo -e "Name: $2" \
	"\nDescription: $2" \
	"\nVersion: $3" > $1/$2.pc
endef

# Taken from build/make/core/binary.mk. We need this
# to use definitions from build/make/core/definitions.mk
$(MESON_GEN_FILES_TARGET): PRIVATE_GLOBAL_C_INCLUDES := $(my_target_global_c_includes)
$(MESON_GEN_FILES_TARGET): PRIVATE_GLOBAL_C_SYSTEM_INCLUDES := $(my_target_global_c_system_includes)

$(MESON_GEN_FILES_TARGET): PRIVATE_2ND_ARCH_VAR_PREFIX := $(M_TARGET_PREFIX)
$(MESON_GEN_FILES_TARGET): PRIVATE_CC := $(my_cc)
$(MESON_GEN_FILES_TARGET): PRIVATE_LINKER := $(my_linker)
$(MESON_GEN_FILES_TARGET): PRIVATE_CXX := $(my_cxx)
$(MESON_GEN_FILES_TARGET): PRIVATE_CXX_LINK := $(my_cxx_link)
$(MESON_GEN_FILES_TARGET): PRIVATE_YACCFLAGS := $(LOCAL_YACCFLAGS)
$(MESON_GEN_FILES_TARGET): PRIVATE_ASFLAGS := $(my_asflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_CONLYFLAGS := $(my_conlyflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_CFLAGS := $(my_cflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_CPPFLAGS := $(my_cppflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_CFLAGS_NO_OVERRIDE := $(my_cflags_no_override)
$(MESON_GEN_FILES_TARGET): PRIVATE_CPPFLAGS_NO_OVERRIDE := $(my_cppflags_no_override)
$(MESON_GEN_FILES_TARGET): PRIVATE_RTTI_FLAG := $(LOCAL_RTTI_FLAG)
$(MESON_GEN_FILES_TARGET): PRIVATE_DEBUG_CFLAGS := $(debug_cflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_C_INCLUDES := $(my_c_includes)
$(MESON_GEN_FILES_TARGET): PRIVATE_IMPORTED_INCLUDES := $(imported_includes)
$(MESON_GEN_FILES_TARGET): PRIVATE_LDFLAGS := $(my_ldflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_LDLIBS := $(my_ldlibs)
$(MESON_GEN_FILES_TARGET): PRIVATE_TIDY_CHECKS := $(my_tidy_checks)
$(MESON_GEN_FILES_TARGET): PRIVATE_TIDY_FLAGS := $(my_tidy_flags)
$(MESON_GEN_FILES_TARGET): PRIVATE_ARFLAGS := $(my_arflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_ALL_SHARED_LIBRARIES := $(built_shared_libraries)
$(MESON_GEN_FILES_TARGET): PRIVATE_ALL_STATIC_LIBRARIES := $(built_static_libraries)
$(MESON_GEN_FILES_TARGET): PRIVATE_ALL_WHOLE_STATIC_LIBRARIES := $(built_whole_libraries)
$(MESON_GEN_FILES_TARGET): PRIVATE_ALL_OBJECTS := $(strip $(all_objects))

$(MESON_GEN_FILES_TARGET): PRIVATE_ARM_CFLAGS := $(normal_objects_cflags)

$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_GLOBAL_CFLAGS := $(my_target_global_cflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_GLOBAL_CONLYFLAGS := $(my_target_global_conlyflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_GLOBAL_CPPFLAGS := $(my_target_global_cppflags)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_GLOBAL_LDFLAGS := $(my_target_global_ldflags)

$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_LIBCRT_BUILTINS := $(my_target_libcrt_builtins)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_LIBATOMIC := $(my_target_libatomic)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_CRTBEGIN_SO_O := $(my_target_crtbegin_so_o)
$(MESON_GEN_FILES_TARGET): PRIVATE_TARGET_CRTEND_SO_O := $(my_target_crtend_so_o)
##

define m-lld-flags
  -nostdlib -Wl,--gc-sections \
  $(PRIVATE_TARGET_CRTBEGIN_SO_O) \
  $(PRIVATE_ALL_OBJECTS) \
  -Wl,--whole-archive \
  $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES) \
  -Wl,--no-whole-archive \
  $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
  $(PRIVATE_ALL_STATIC_LIBRARIES) \
  $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
  $(if $(filter true,$(NATIVE_COVERAGE)),$(PRIVATE_TARGET_COVERAGE_LIB)) \
  $(PRIVATE_TARGET_LIBCRT_BUILTINS) \
  $(PRIVATE_TARGET_LIBATOMIC) \
  $(PRIVATE_TARGET_GLOBAL_LDFLAGS) \
  $(PRIVATE_LDFLAGS) \
  $(PRIVATE_ALL_SHARED_LIBRARIES) \
  $(PRIVATE_TARGET_CRTEND_SO_O) \
  $(PRIVATE_LDLIBS)
endef

define m-lld-flags-cleaned
  $(subst prebuilts/,$(AOSP_ABSOLUTE_PATH)/prebuilts/, \
  $(subst out/,$(AOSP_ABSOLUTE_PATH)/out/,             \
  $(subst -Wl$(comma)--fatal-warnings,,                \
  $(subst -Wl$(comma)--no-undefined-version,,          \
  $(subst -Wl$(comma)--gc-sections,,                   \
  $(patsubst %dummy.o,,                                \
    $(m-lld-flags)))))))
endef

define m-cpp-flags
  $(PRIVATE_TARGET_GLOBAL_CFLAGS) \
  $(PRIVATE_TARGET_GLOBAL_CPPFLAGS) \
  $(PRIVATE_ARM_CFLAGS) \
  $(PRIVATE_RTTI_FLAG) \
  $(PRIVATE_CFLAGS) \
  $(PRIVATE_CPPFLAGS) \
  $(PRIVATE_DEBUG_CFLAGS) \
  $(PRIVATE_CFLAGS_NO_OVERRIDE) \
  $(PRIVATE_CPPFLAGS_NO_OVERRIDE)
endef

define m-c-flags
  $(PRIVATE_TARGET_GLOBAL_CFLAGS) \
  $(PRIVATE_TARGET_GLOBAL_CONLYFLAGS) \
  $(PRIVATE_ARM_CFLAGS) \
  $(PRIVATE_CFLAGS) \
  $(PRIVATE_CONLYFLAGS) \
  $(PRIVATE_DEBUG_CFLAGS) \
  $(PRIVATE_CFLAGS_NO_OVERRIDE)
endef

define filter-c-flags
  $(filter-out -std=gnu++17 -fno-rtti -enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang, \
    $(patsubst  -W%,, $1))
endef

define m-c-includes-common
$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),,\
    $(addprefix -I ,\
        $(filter-out $(PRIVATE_C_INCLUDES), \
            $(PRIVATE_GLOBAL_C_INCLUDES))) \
    $(addprefix -isystem ,\
        $(filter-out $(PRIVATE_C_INCLUDES), \
            $(PRIVATE_GLOBAL_C_SYSTEM_INCLUDES))))
endef

define m-c-includes
$(foreach i,$(PRIVATE_IMPORTED_INCLUDES),$(EXPORTS.$(i)))\
$(m-c-includes-common)
endef

define postprocess-includes
endef

define m-c-abs-includes
  $(subst $(space)-isystem,$(space)-isystem$(AOSP_ABSOLUTE_PATH)/, \
  $(subst $(space)-I, -I$(AOSP_ABSOLUTE_PATH)/, \
  $(subst $(space)-I$(space),$(space)-I, \
  $(subst $(space)-isystem$(space),$(space)-isystem, \
    $(strip $(m-c-includes))))))
endef

$(MESON_GEN_FILES_TARGET): MESON_GEN_PKGCONFIGS:=$(MESON_GEN_PKGCONFIGS)
$(MESON_GEN_FILES_TARGET): MESON_GEN_DIR:=$(MESON_GEN_DIR)
$(MESON_GEN_FILES_TARGET): $(sort $(shell find -L $(LIBDAV1D_TOP) -not -path '*/\.*'))
	mkdir -p $(dir $@)
	echo -e "[properties]\n"                                                                                                  \
		"c_args = [$(foreach flag, $(call filter-c-flags,$(m-c-flags) $(m-c-abs-includes)),'$(flag)', )'']\n"             \
		"cpp_args = [$(foreach flag, $(call filter-c-flags,$(m-cpp-flags) $(m-c-abs-includes)),'$(flag)', )'']\n"         \
		"c_link_args = [$(foreach flag, $(m-lld-flags-cleaned),'$(flag)',)'']\n"                                          \
		"cpp_link_args = [$(foreach flag, $(m-lld-flags-cleaned),'$(flag)',)'']\n"                                        \
		"needs_exe_wrapper = true\n"                                                                                      \
		"[binaries]\n"                                                                                                    \
		"ar = '$(AOSP_ABSOLUTE_PATH)/$($($(M_TARGET_PREFIX))TARGET_AR)'\n"                                                \
		"c = [$(foreach arg,$(PRIVATE_CC),'$(subst prebuilts/,$(AOSP_ABSOLUTE_PATH)/prebuilts/,$(arg))',)'']\n"           \
		"cpp = [$(foreach arg,$(PRIVATE_CXX),'$(subst prebuilts/,$(AOSP_ABSOLUTE_PATH)/prebuilts/,$(arg))',)'']\n"        \
		"c_ld = 'lld'\n"                                                                                                  \
		"cpp_ld = 'lld'\n\n"                                                                                              \
		"pkgconfig = ['env', 'PKG_CONFIG_LIBDIR=' + '$(AOSP_ABSOLUTE_PATH)/$(MESON_GEN_DIR)', '/usr/bin/pkg-config']\n\n" \
		"llvm-config = '/dev/null'\n"                                                                                     \
		"[host_machine]\n"                                                                                                \
		"system = 'android'\n"                                                                                            \
		"cpu_family = '$(MESON_CPU_FAMILY)'\n"                                                                            \
		"cpu = '$(MESON_CPU_FAMILY)'\n"                                                                                   \
		"endian = 'little'" > $(dir $@)/aosp_cross

	$(foreach pkg, $(MESON_GEN_PKGCONFIGS), $(call create-pkgconfig,$(dir $@),$(word 1, $(subst :, ,$(pkg))),$(word 2, $(subst :, ,$(pkg)))))
	touch $@

$(MESON_OUT_DIR)/.build.timestamp: MESON_GEN_NINJA:=$(MESON_GEN_NINJA)
$(MESON_OUT_DIR)/.build.timestamp: MESON_BUILD:=$(MESON_BUILD)
$(MESON_OUT_DIR)/.build.timestamp: $(MESON_GEN_FILES_TARGET) $(link_deps)
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	mkdir -p $(dir $@)/build
	# Meson will update timestamps in sources directory, continuously retriggering the build
	# even if nothing changed. Copy sources into intermediate dir to avoid this effect.
	cp -r $(LIBDAV1D_TOP)/* $(dir $@)
	$(MESON_GEN_NINJA)
	$(MESON_BUILD)
	touch $@

$(MESON_OUT_DIR)/install/.install.timestamp: MESON_BUILD:=$(MESON_BUILD)
$(MESON_OUT_DIR)/install/.install.timestamp: $(MESON_OUT_DIR)/.build.timestamp
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	DESTDIR=$(AOSP_ABSOLUTE_PATH)/$(dir $@) $(MESON_BUILD) install
	touch $@

$(LIBDAV1D_BINS): $(MESON_OUT_DIR)/install/.install.timestamp
	echo "Build $@"
	touch $@

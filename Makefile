ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTubeMusic
TARGET = iphone:clang:latest:13.0
PACKAGE_VERSION = 1.0.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate
$(TWEAK_NAME)_FILES = $(wildcard Source/*.x)
$(TWEAK_NAME)_FILES += $(shell find Source -name '*.m')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -DTWEAK_VERSION=$(PACKAGE_VERSION)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AudioToolbox VideoToolbox
$(TWEAK_NAME)_OBJ_FILES = $(shell find Source/Utils/lib -name '*.a')
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z

include $(THEOS_MAKE_PATH)/tweak.mk

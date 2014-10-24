export ARCHS = armv7 armv7s arm64
export GO_EASY_ON_ME=1
export SHARED_CFLAGS = -fobjc-arc
export ADDITIONAL_OBJCFLAGS = -fobjc-arc
export TARGET=iphone:clang:latest:6.0

include theos/makefiles/common.mk

THEOS_BUILD_DIR = Packages

TWEAK_NAME = ToneEnabler
ToneEnabler_FRAMEWORKS = Foundation UIKit
ToneEnabler_PRIVATE_FRAMEWORKS = ToneKit
ToneEnabler_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
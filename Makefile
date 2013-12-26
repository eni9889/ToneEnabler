export ARCHS = armv7 armv7s arm64
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
#export THEOS_DEVICE_IP=192.168.1.20
export GO_EASY_ON_ME=1
export SHARED_CFLAGS = -fobjc-arc
export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = ToneEnabler
ToneEnabler_FRAMEWORKS = Foundation UIKit
ToneEnabler_PRIVATE_FRAMEWORKS = ToneKit
ToneEnabler_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
.PHONY: all clean help

CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(dir $(CURRENT_MAKEFILE_PATH))
BUILD_DIR := $(addprefix $(CURRENT_MAKEFILE_DIR),build)

config ?= Debug
version ?= 1.0.0

all:
	[ -d "$(BUILD_DIR)" ] || mkdir -p "$(BUILD_DIR)"
	cmake -G Xcode \
	-DBUILD_FREETYPE_HARFBUZZ=OFF \
	-DAPP_VERSION=$(version) \
	-B$(BUILD_DIR) \
	-H$(CURRENT_MAKEFILE_DIR)
	cmake --build $(BUILD_DIR) --config $(config)

clean:
	[ -d "$(BUILD_DIR)" ] && rm -rf "$(BUILD_DIR)" || true

help:
	echo "Options: config=Debug|Release, version=<any-version-string>"

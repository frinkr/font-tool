.PHONY: default build debug release clean help

CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(dir $(CURRENT_MAKEFILE_PATH))
BUILD_DIR := $(addprefix $(CURRENT_MAKEFILE_DIR),build)

version ?= 1.0.0

default: debug

build:
	[ -d "$(BUILD_DIR)" ] || mkdir -p "$(BUILD_DIR)"
	cmake -G Xcode \
	-DBUILD_FREETYPE_HARFBUZZ=OFF \
	-DAPP_VERSION=$(version) \
	-B$(BUILD_DIR) \
	-H$(CURRENT_MAKEFILE_DIR)

debug: build
	cmake --build $(BUILD_DIR) --config Debug

release: build
	cmake --build $(BUILD_DIR) --config Release

clean:
	[ -d "$(BUILD_DIR)" ] && rm -rf "$(BUILD_DIR)" || true

help:
	@echo "Options: version=<any-version-string, e.g 1.2.3>"
	@echo "   - make debug : build debug version of application"
	@echo "   - make release version=1.2.3 : build release version of application of version 1.2.3"
	@echo "   - make : alias of 'make debug'"
	@echo "   - make clean : remove build dir"

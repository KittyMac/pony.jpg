build_dir=./build
lib_dir=./lib

native_cc=clang++
native_ar=ar

iphonesdk_ar=$(shell xcrun --sdk iphoneos --find ar)
iphonesdk_clang=$(shell xcrun --sdk iphoneos --find clang)
iphonesdk_clangxx=$(shell xcrun --sdk iphoneos --find clang++)
iphonesdk_isysroot=$(shell xcrun --sdk iphoneos --show-sdk-path)
iphonesdklib="$(iphonesdk_isysroot)/usr/lib"

all: shim pony run
	
check-folders:
	@mkdir -p ./build

shim-native:
	cd build
	$(native_cc) -arch x86_64 -arch i386 -fPIC -Wall -Wextra -O3 -g -c -I shim/libjpeg/macosx-build/include/ -o $(build_dir)/jpeg.o shim/shim_jpeg.cc
	lipo -create -output $(lib_dir)/libponyjpeg-osx.a build/jpeg.o

shim-ios:
	$(iphonesdk_clang) -arch armv7 -arch armv7s -arch arm64 -mios-version-min=10.0 -isysroot $(iphonesdk_isysroot) -I shim/libjpeg/iphone-build/include/ -fPIC -Wall -Wextra -O3 -g -c -o $(build_dir)/jpeg.o shim/shim_jpeg.cc
	lipo -create -output $(lib_dir)/libponyjpeg-ios.a build/jpeg.o


shim: check-folders shim-ios shim-native

pony: check-folders copy-libs
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -p $(lib_dir) -o ./build/ ./jpg

copy-libs:
	@cp ./shim/libjpeg/iphone-build/lib/libjpeg.a ./lib/libjpeg-ios.a
	@cp ./shim/libjpeg/macosx-build/lib/libjpeg.a ./lib/libjpeg-osx.a
	@cp ../pony.bitmap/lib/*.a ./lib/

clean:
	rm ./build/*

run:
	./build/jpg

test: check-folders copy-libs
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -V=0 -p $(lib_dir) -o ./build/ ./jpg
	./build/jpg

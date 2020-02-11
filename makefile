build_dir=./build
lib_dir=./lib

bitmap_lib_dir=../pony.bitmap/lib

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
	corral run -- ponyc -p $(lib_dir) -o ./build/ ./jpg

copy-libs:
	@cp ./shim/libjpeg/iphone-build/lib/libjpeg.a ./lib/libjpeg-ios.a
	@cp ./shim/libjpeg/macosx-build/lib/libjpeg.a ./lib/libjpeg-osx.a
	@cp ${bitmap_lib_dir}/*.a ./lib/

clean:
	rm ./build/*

run:
	./build/jpg

test: check-folders copy-libs
	corral run -- ponyc -V=0 -p $(lib_dir) -o ./build/ ./jpg
	./build/jpg





corral-fetch:
	@corral clean -q
	@corral fetch -q

corral-local:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add /Volumes/Development/Development/pony/pony.fileExt -q
	@corral add /Volumes/Development/Development/pony/pony.flow -q
	@corral add /Volumes/Development/Development/pony/pony.bitmap -q
	@corral add /Volumes/Development/Development/pony/pony.png -q

corral-git:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add github.com/KittyMac/pony.fileExt.git -q
	@corral add github.com/KittyMac/pony.flow.git -q
	@corral add github.com/KittyMac/pony.bitmap.git -q
	@corral add github.com/KittyMac/pony.png.git -q

ci: bitmap_lib_dir = ./_corral/github_com_KittyMac_pony_bitmap/lib/
ci: corral-git corral-fetch all
	
dev: corral-local corral-fetch all


build_dir=./build

native_cc=clang++
native_ar=ar

iphonesdk_ar=$(shell xcrun --sdk iphoneos --find ar)
iphonesdk_clang=$(shell xcrun --sdk iphoneos --find clang)
iphonesdk_clangxx=$(shell xcrun --sdk iphoneos --find clang++)
iphonesdk_isysroot=$(shell xcrun --sdk iphoneos --show-sdk-path)
iphonesdklib="$(iphonesdk_isysroot)/usr/lib"

all: shim pony run

shim-native:
	cd build
	$(native_cc) -fPIC -Wall -Wextra -O3 -g -MM shim/shim_jpeg.cc > $(build_dir)/jpeg.d
	$(native_cc) -arch x86_64 -arch i386 -fPIC -Wall -Wextra -O3 -g -c -I shim/libjpeg/macosx-build/include/ -o $(build_dir)/jpeg.o shim/shim_jpeg.cc
	$(native_cc) -arch x86_64 -arch i386 -shared -o $(build_dir)/libponyjpeg-osx.a $(build_dir)/jpeg.o shim/libjpeg/macosx-build/lib/libjpeg.a

shim-ios:
	$(iphonesdk_clang) -fPIC -Wall -Wextra -O3 -g -MM shim/shim_jpeg.cc > $(build_dir)/jpeg.d
	$(iphonesdk_clang) -arch armv7 -arch armv7s -arch arm64 -mios-version-min=10.0 -isysroot $(iphonesdk_isysroot) -I shim/libjpeg/iphone-build/include/ -fPIC -Wall -Wextra -O3 -g -c -o $(build_dir)/jpeg.o shim/shim_jpeg.cc
	$(iphonesdk_clang) -arch armv7 -arch armv7s -arch arm64 -mios-version-min=10.0 -isysroot $(iphonesdk_isysroot) -shared -stdlib=libc++ -o $(build_dir)/libponyjpeg-ios.a $(build_dir)/jpeg.o shim/libjpeg/iphone-build/lib/libjpeg.a


shim: shim-ios shim-native

pony:
	stable env /Volumes/Development/Development/pony/ponyc/build/release/ponyc -p $(build_dir) -o ./build/ ./jpg

clean:
	rm ./build/*

run:
	./build/jpg

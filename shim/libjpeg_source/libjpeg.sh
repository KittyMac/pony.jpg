# Builds a Libjpeg framework for the iPhone and the iPhone Simulator.
# Creates a set of universal libraries that can be used on an iPhone and in the
# iPhone simulator. Then creates a pseudo-framework to make using libjpeg in Xcode
# less painful.
#
# To configure the script, define:
#    IPHONE_SDKVERSION: iPhone SDK version (e.g. 8.1)
#
# Then go get the source tar.bz of the libjpeg you want to build, shove it in the
# same directory as this script, and run "./libjpeg.sh". Grab a cuppa. And voila.
#===============================================================================

: ${LIB_VERSION:=9c}

# Current iPhone SDK
#: ${IPHONE_SDKVERSION:=`xcodebuild -showsdks | grep iphoneos | egrep "[[:digit:]]+\.[[:digit:]]+" -o | tail -1`}
# Specific iPhone SDK
: ${IPHONE_SDKVERSION:=10}

: ${XCODE_ROOT:=`xcode-select -print-path`}

: ${TARBALLDIR:=`pwd`}
: ${SRCDIR:=`pwd`/src}
: ${IOSBUILDDIR:=`pwd`/ios/build}
: ${OSXBUILDDIR:=`pwd`/osx/build}
: ${PREFIXDIR:=`pwd`/ios/prefix}
: ${IOSFRAMEWORKDIR:=`pwd`/ios/framework}
: ${OSXFRAMEWORKDIR:=`pwd`/osx/framework}

: ${iphonesdk_isysroot:=`xcrun --sdk iphoneos --show-sdk-path`}

LIB_TARBALL=$TARBALLDIR/jpegsrc.v$LIB_VERSION.tar.gz
LIB_SRC=$SRCDIR/jpeg-${LIB_VERSION}

#===============================================================================
ARM_DEV_CMD="xcrun --sdk iphoneos"
SIM_DEV_CMD="xcrun --sdk iphonesimulator"

#===============================================================================
# Functions
#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

doneSection()
{
    echo
    echo "================================================================="
    echo "Done"
    echo
}

#===============================================================================

cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...

    rm -rf iphone-build iphonesim-build
    rm -rf $IOSBUILDDIR
	rm -rf $OSXBUILDDIR
    rm -rf $PREFIXDIR
    rm -rf $IOSFRAMEWORKDIR/$FRAMEWORK_NAME.framework

    doneSection
}

#===============================================================================

downloadLibjpeg()
{
    if [ ! -s $LIB_TARBALL ]; then
        echo "Downloading libjpeg ${LIB_VERSION}"
        curl -L -o $LIB_TARBALL http://www.ijg.org/files/jpegsrc.v${LIB_VERSION}.tar.gz
    fi

    doneSection
}

#===============================================================================

unpackLibjpeg()
{
    [ -f "$LIB_TARBALL" ] || abort "Source tarball missing."

    echo Unpacking libjpeg into $SRCDIR...

    [ -d $SRCDIR ]    || mkdir -p $SRCDIR
    [ -d $LIB_SRC ] || ( cd $SRCDIR; tar xfj $LIB_TARBALL )
    [ -d $LIB_SRC ] && echo "    ...unpacked as $LIB_SRC"

    doneSection
}

#===============================================================================

buildLibjpegForIPhoneOS()
{
    export CC=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
    export CC_BASENAME=clang

    export CXX=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
    export CXX_BASENAME=clang++

    #echo Building Libjpeg for iPhoneSimulator
    #mkdir -p $LIB_SRC/iphonesim-build
    #cd $LIB_SRC/iphonesim-build
    #export CFLAGS="-O3 -arch i386 -arch x86_64 -isysroot ${iphonesdk_isysroot} -mios-simulator-version-min=${IPHONE_SDKVERSION} -Wno-error-implicit-function-declaration"
    #../configure --prefix=$PREFIXDIR/iphonesim-build --disable-dependency-tracking --enable-static=yes --enable-shared=no
    #make
    #make install
    #doneSection

    echo Building Libjpeg for iPhone
    mkdir -p $LIB_SRC/iphone-build
    cd $LIB_SRC/iphone-build
    export CFLAGS="-O3 -arch armv7 -arch armv7s -arch arm64 -isysroot ${iphonesdk_isysroot} -mios-version-min=${IPHONE_SDKVERSION}"
    ../configure --host=arm-apple-darwin --prefix=$PREFIXDIR/iphone-build --disable-dependency-tracking --enable-static=yes --enable-shared=no
    make
    make install
    doneSection
	
    export CC=clang
    export CC_BASENAME=clang

    export CXX=clang++
    export CXX_BASENAME=clang++
	
	
    echo Building Libjpeg for Mac OS X
    mkdir -p $LIB_SRC/macosx-build
    cd $LIB_SRC/macosx-build
    export CFLAGS="-O3 -arch x86_64 -arch i386"
    ../configure --prefix=$PREFIXDIR/macosx-build --disable-dependency-tracking --enable-static=yes --enable-shared=no
    make
    make install
    doneSection
	
	
}

#===============================================================================

scrunchAllLibsTogetherInOneLibPerPlatform()
{
    cd $PREFIXDIR

    # iOS Device
    mkdir -p $IOSBUILDDIR/armv7
    mkdir -p $IOSBUILDDIR/armv7s
    mkdir -p $IOSBUILDDIR/arm64

    # iOS Simulator
    mkdir -p $IOSBUILDDIR/i386
    mkdir -p $IOSBUILDDIR/x86_64
	
	# Mac OS X
    mkdir -p $OSXBUILDDIR/i386
    mkdir -p $OSXBUILDDIR/x86_64

    echo Splitting all existing fat binaries...

    $ARM_DEV_CMD lipo "iphone-build/lib/libjpeg.a" -thin armv7 -o $IOSBUILDDIR/armv7/libjpeg.a
    $ARM_DEV_CMD lipo "iphone-build/lib/libjpeg.a" -thin armv7s -o $IOSBUILDDIR/armv7s/libjpeg.a
    $ARM_DEV_CMD lipo "iphone-build/lib/libjpeg.a" -thin arm64 -o $IOSBUILDDIR/arm64/libjpeg.a

    $SIM_DEV_CMD lipo "iphonesim-build/lib/libjpeg.a" -thin i386 -o $IOSBUILDDIR/i386/libjpeg.a
    $SIM_DEV_CMD lipo "iphonesim-build/lib/libjpeg.a" -thin x86_64 -o $IOSBUILDDIR/x86_64/libjpeg.a
	
    lipo "macosx-build/lib/libjpeg.a" -thin i386 -o $IOSBUILDDIR/i386/libjpeg.a
    lipo "macosx-build/lib/libjpeg.a" -thin x86_64 -o $IOSBUILDDIR/x86_64/libjpeg.a
}

#===============================================================================
# Execution starts here
#===============================================================================

mkdir -p $IOSBUILDDIR
mkdir -p $OSXBUILDDIR

# cleanEverythingReadyToStart #may want to comment if repeatedly running during dev

echo "LIB_VERSION:       $LIB_VERSION"
echo "LIB_SRC:           $LIB_SRC"
echo "IOSBUILDDIR:       $IOSBUILDDIR"
echo "PREFIXDIR:         $PREFIXDIR"
echo "IOSFRAMEWORKDIR:   $IOSFRAMEWORKDIR"
echo "IPHONE_SDKVERSION: $IPHONE_SDKVERSION"
echo "XCODE_ROOT:        $XCODE_ROOT"
echo

downloadLibjpeg
unpackLibjpeg
buildLibjpegForIPhoneOS
scrunchAllLibsTogetherInOneLibPerPlatform

echo "Completed successfully"

#===============================================================================
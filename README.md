# pony.jpg

**WARNING** While this code should work standard Pony, it is designed to take full advantage of the changes I have introduced in [my fork of Pony](https://github.com/KittyMac/ponyc/tree/roc_master). Most of the changes to Pony involve improvements to the Pony runtime. The list of these changes are documented in my [pony.problems](https://github.com/KittyMac/pony.problems) respository.

### Purpose

This repository is just me hacking around with [Pony](https://www.ponylang.io). It should not be used as an example of good Pony programming practices.

### JPG

Wraps libjpg to load Bitmap objects in Pony.  Requires my fork of Pony as it has a high performance implementation of Bitmap built into the core packages.

Note that unlike pony.png, we can't get away with just FFI'ing to libjpeg directory, there's just too much.  Instead we create a shim library which exposes a simpler API for pony.jpg to call to, and the entirety of the libjpeg code is done in that C library.  The downside of this is that it does require additional compilation on your part if you want to use it, but the ability to do this is a good excersize none-the-less.

The repository includes prebuilt jpeglibs for armv7, armv7s, arm64 and i386, x86_64.  The makefile will build the shim code (shim/shim_jpeg.cc) for both OS X and iOS, resulting in a dylib for OS X ( libponyjpeg.dylib ) and a static lib for iOS ( libponyjpeg.a ).


## License

pony.jpg is free software distributed under the terms of the MIT license, reproduced below. pony.jpg may be used for any purpose, including commercial purposes, at absolutely no cost. No paperwork, no royalties, no GNU-like "copyleft" restrictions. Just download and enjoy.

Copyright (c) 2019 Rocco Bowling

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
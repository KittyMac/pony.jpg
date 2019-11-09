use "path:/usr/lib" if osx

use @pony_malloc[Pointer[U8]](bytes: USize)
use @pony_free[None](pointer: Pointer[None] tag)
use @memcpy[Pointer[None]](dst: Pointer[None], src: Pointer[None], n: USize)


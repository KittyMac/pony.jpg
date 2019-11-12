use "fileExt"
use "flow"

use "path:/usr/lib" if osx
use "lib:ponyjpeg-osx" if osx
use "lib:ponyjpeg-ios" if ios

use @decompressJPG[Pointer[U8]](jpgData:Pointer[U8] tag, jpgLength:USize, out_width:Pointer[USize], out_height:Pointer[USize])
use @compressJPG[Pointer[U8]](imgData:Pointer[U8] tag, width:USize, height:USize, quality:USize, out_jpgLength:Pointer[USize])
use @freeJPG[None](imgData:Pointer[U8] tag)

primitive JPGWriter
	fun tag write(filePath:String, bitmap:Bitmap box)? =>
	
		var jpgLength:USize = 0
		let jpgData = @compressJPG(bitmap.cpointer(), bitmap.width, bitmap.height, 85, addressof jpgLength)
		
		let fd = FileExt.open(filePath)
		if fd < 0 then
			@freeJPG(jpgData)
			error
		end
		
		FileExt.write(fd, jpgData, jpgLength)
		FileExt.close(fd)
		
		@freeJPG(jpgData)


actor JPGFlowWriter is Flowable

	let target:Flowable tag
	let filePath:String
	
	fun _tag():USize => 115

	new create(filePath':String, target':Flowable tag) =>
		target = target'
		filePath = filePath'
	
	be flowFinished() =>
		true

	be flowReceived(dataIso:Any iso) =>
		try
			let bitmap = (consume dataIso) as Bitmap
			try
				JPGWriter.write(filePath, bitmap)?
			end
		end

	
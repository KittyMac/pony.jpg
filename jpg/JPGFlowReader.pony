use "fileExt"
use "flow"

use "path:/usr/lib" if osx
use "lib:ponyjpeg-osx" if osx
use "lib:ponyjpeg-ios" if ios


primitive JPGReader
	fun tag read(filePath:String):Bitmap iso^ ? =>
		let pngData = FileExt.fileToArray(filePath)?
		let null = Pointer[None]
		
		var width:USize = 0
		var height:USize = 0
		let imgBytes = @decompressJPG(pngData.cpointer(0), pngData.size(), addressof width, addressof height)
		
		if width == 0 then
			@freeJPG(imgBytes)
			error
		end
		
		let bitmap = recover Bitmap.copy(width.usize(),height.usize(),imgBytes) end
		@freeJPG(imgBytes)
		bitmap
	

actor JPGFlowReader

	let target:Flowable tag
	let filePath:String
	
	fun _tag():USize => 114

	new create(filePath':String, target':Flowable tag) =>
		target = target'
		filePath = filePath'
		_read()
	
	be _read() =>		
		try
			let bitmap = JPGReader.read(filePath)?
			target.flowReceived(consume bitmap)
			target.flowFinished()
		else
			target.flowReceived(recover Bitmap(10,10) end)
			target.flowFinished()
		end
		
		
		
		
		
		
		


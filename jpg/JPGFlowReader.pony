use "fileExt"
use "flow"
use "bitmap"

use "lib:ponyjpeg-osx" if osx
use "lib:ponyjpeg-ios" if ios

use "lib:jpeg-osx" if osx
use "lib:jpeg-ios" if ios

primitive JPGReader
	fun tag read(filePath:String):Bitmap iso^ ? =>
		let jpgData = FileExt.fileToArray(filePath)?
		
		var width:USize = 0
		var height:USize = 0
		let imgBytes = @decompressJPG(jpgData.cpointer(0), jpgData.size(), addressof width, addressof height)
		
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
		
		
		
		
		
		
		


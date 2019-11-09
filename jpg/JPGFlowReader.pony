use "fileExt"
use "flow"

use "path:/usr/lib" if osx
use "lib:ponyjpeg-osx" if osx
use "lib:ponyjpeg-ios" if ios


primitive JPGReader
	fun tag read(filePath:String):Bitmap iso^ ? =>
		let pngData = FileExt.fileToByteBlock(filePath)?
		let null = Pointer[None]
		
		
		@fprintf[I64](@pony_os_stdout[Pointer[U8]](), "test = %d\n".cstring(), @test[I32]())
		
		
		recover Bitmap(10,10) end
	

actor JPGFlowReader

	let target:Flowable tag
	let filePath:String

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
		
		
		
		
		
		
		


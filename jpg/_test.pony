use "fileExt"
use "ponytest"
use "files"
use "flow"

use @sleep[I32](seconds: I32)

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestReadJPG)




actor Sprite is Flowable
	// test actor to read a JPG and save it back to a file
	
	be flowFinished() =>
		true
	
	be flowReceived(dataIso:Any iso) =>
		try
			let bitmap = (consume dataIso) as Bitmap
			try
				FileExt.bitmapToFile(bitmap, "/tmp/png.raw")?
				//JPGWriter.write("/tmp/test_jpg.jpg", bitmap)?
			end
		end
	
	be read(filePath:String) =>
		JPGFlowReader(filePath, this)


class iso _TestReadJPG is UnitTest
	fun name(): String => "read jpg"

	fun apply(h: TestHelper) =>
		Sprite.read("sample.jpg")
	



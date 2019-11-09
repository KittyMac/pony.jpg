#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include "jpeglib.h"

#define UNUSED(x) (void)(x)

extern "C"
{
	void * decompressJPG(unsigned char * jpgData, size_t jpgLength, size_t * out_width, size_t * out_height);
	void * compressJPG(unsigned char * imgData, size_t width, size_t height, size_t quality, size_t * out_jpgLength);
	
	void freeJPG(unsigned char * imgData);
}

void freeJPG(unsigned char * imgData) {
	free(imgData);
}

void * compressJPG(unsigned char * imgData, size_t width, size_t height, size_t quality, size_t * out_jpgLength)
{
	// compress the RGBA image data in imgData.  returns null on failure and out_jpgLength will be 0.
	// quality can be 0...100
		
	unsigned char * mem = NULL;
	unsigned long mem_size = 0;
	
	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;
	
	*out_jpgLength = 0;
	
	cinfo.err = jpeg_std_error(&jerr);
	
	jpeg_create_compress(&cinfo);
	
	jpeg_mem_dest(&cinfo, &mem, &mem_size);
	
	/* Setting the parameters of the output file here */
	cinfo.image_width = width;
	cinfo.image_height = height;
	cinfo.input_components = 3;
	cinfo.in_color_space = JCS_RGB;
	
	jpeg_set_defaults(&cinfo);
	jpeg_set_quality(&cinfo, quality, TRUE);
	
	jpeg_start_compress( &cinfo, TRUE );
	
	JSAMPROW row_pointer[1] = {0};
	
	row_pointer[0] = (JSAMPROW)malloc(width * 3);
	while (cinfo.next_scanline < cinfo.image_height)
	{
		// conver the RGBA bytes to RGB in row_pointer before writing
		int src = cinfo.next_scanline * (width * 4);
		int dst = 0;
		for( size_t i = 0; i < width; i++)
		{
			row_pointer[0][dst++] = imgData[src++];
			row_pointer[0][dst++] = imgData[src++];
			row_pointer[0][dst++] = imgData[src++];
			src++;
		}		
		
		jpeg_write_scanlines(&cinfo, row_pointer, 1);
	}
	
	jpeg_finish_compress( &cinfo );
	jpeg_destroy_compress( &cinfo );
	
	*out_jpgLength = mem_size;
	
	return (char*)mem;
}

void * decompressJPG(unsigned char * jpgData, size_t jpgLength, size_t * out_width, size_t * out_height)
{
	// decompresses the jpg data sent in, converts it to RGBA and return the bytes, width, and height of the image
	// returns null and sets width and height to 0 on failure
	
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	
	/* libjpeg data structure for storing one row, that is, scanline of an image */
	JSAMPROW row_pointer[1] = {0};
	unsigned long location = 0;
	unsigned int i = 0;
	
	*out_width = 0;
	*out_height = 0;
	
	/* here we set up the standard libjpeg error handler */
	cinfo.err = jpeg_std_error( &jerr );

	/* setup decompression process and source, then read JPEG header */
	jpeg_create_decompress( &cinfo );
	
	jpeg_mem_src(&cinfo, jpgData, jpgLength);
	
	/* reading the image header which contains image information */
	jpeg_read_header( &cinfo, (boolean)true );

	// we only support RGB or grayscale
	if (cinfo.jpeg_color_space != JCS_RGB)
	{
		if (cinfo.jpeg_color_space == JCS_GRAYSCALE || cinfo.jpeg_color_space == JCS_YCbCr)
		{
			cinfo.out_color_space = JCS_RGB;
		}
	}
	else
	{
		return NULL;
	}

	/* Start decompression jpeg here */
	jpeg_start_decompress( &cinfo );

	/* init image info */
	short width  = (short)(cinfo.image_width);
	short height = (short)(cinfo.image_height);

	row_pointer[0] = (JSAMPROW)malloc(cinfo.output_width * cinfo.output_components);
	if (row_pointer[0] == NULL) {
		return NULL;
	}

	unsigned char * m_pData = (unsigned char *)malloc(cinfo.output_width * cinfo.output_height * 4);
	if (m_pData == NULL) {
		return NULL;
	}

	// now actually read the jpeg into the raw buffer
	// read one scan line at a time, converting RGB to
	// RGBA along the way
	while( cinfo.output_scanline < cinfo.image_height )
	{
		jpeg_read_scanlines( &cinfo, row_pointer, 1 );
		for( i = 0; i < cinfo.image_width * cinfo.output_components; i += cinfo.output_components)
		{
			m_pData[location++] = row_pointer[0][i+0];
			m_pData[location++] = row_pointer[0][i+1];
			m_pData[location++] = row_pointer[0][i+2];
			m_pData[location++] = 255;
		}
	}

	jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);
	
	*out_width = width;
	*out_height = height;
	
	return m_pData;
}
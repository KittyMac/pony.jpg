#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include "jpeglib.h"

#define UNUSED(x) (void)(x)

extern "C"
{
	void * decompressJPG(unsigned char * jpgData, size_t jpgLength, int * out_width, int * out_height);
	
	void freeJPG(unsigned char * imgData);
}

static void JPEGInitSource(j_decompress_ptr cinfo)
{
	UNUSED(cinfo);
}

static boolean JPEGFillInputBuffer(j_decompress_ptr cinfo)
{
	UNUSED(cinfo);
	return (boolean)false;
}

static void JPEGSkipInputData(j_decompress_ptr cinfo, long num_bytes)
{
	cinfo->src->next_input_byte += num_bytes;
	cinfo->src->bytes_in_buffer -= num_bytes;
}

static void JPEGTermSource(j_decompress_ptr cinfo)
{
	UNUSED(cinfo);
}

void freeJPG(unsigned char * imgData) {
	free(imgData);
}

void * decompressJPG(unsigned char * jpgData, size_t jpgLength, int * out_width, int * out_height)
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
	
    do 
    {
        /* here we set up the standard libjpeg error handler */
        cinfo.err = jpeg_std_error( &jerr );

        /* setup decompression process and source, then read JPEG header */
        jpeg_create_decompress( &cinfo );
		
	    jpeg_source_mgr srcmgr;

		srcmgr.bytes_in_buffer = jpgLength;
		srcmgr.next_input_byte = (JOCTET*) jpgData;
		srcmgr.init_source = JPEGInitSource;
		srcmgr.fill_input_buffer = JPEGFillInputBuffer;
		srcmgr.skip_input_data = JPEGSkipInputData;
		srcmgr.resync_to_restart = jpeg_resync_to_restart;
		srcmgr.term_source = JPEGTermSource;
		cinfo.src = &srcmgr;
		
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
            break;
        }

        /* Start decompression jpeg here */
        jpeg_start_decompress( &cinfo );

        /* init image info */
        short width  = (short)(cinfo.image_width);
        short height = (short)(cinfo.image_height);

        row_pointer[0] = (JSAMPROW)malloc(cinfo.output_width * cinfo.output_components);
		if (row_pointer[0] == NULL) {
			break;
		}

        unsigned char * m_pData = (unsigned char *)malloc(cinfo.output_width * cinfo.output_height * 4);
		if (m_pData == NULL) {
			break;
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
    } while (0);
	
	return NULL;
}
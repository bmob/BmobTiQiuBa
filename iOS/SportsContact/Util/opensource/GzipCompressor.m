//
//  GzipCompressor.m
//  BaiduSearch
//
//  Created by zhuxiaohan on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GzipCompressor.h"
//#import "ASIHTTPRequest.h"

#define DATA_CHUNK_SIZE 262144 // Deal with gzipped data in 256KB chunks
#define COMPRESSION_AMOUNT Z_DEFAULT_COMPRESSION

@implementation GzipCompressor

+ (id)compressor
{
	GzipCompressor *compressor = [[[self alloc] init] autorelease];
	[compressor setupStream];
	return compressor;
}

- (void)dealloc
{
	if (streamReady) {
		[self closeStream];
	}
	[super dealloc];
}

- (NSError *)setupStream
{
	if (streamReady) {
		return nil;
	}
	// Setup the inflate stream
	zStream.zalloc = Z_NULL;
	zStream.zfree = Z_NULL;
	zStream.opaque = Z_NULL;
	zStream.avail_in = 0;
	zStream.next_in = 0;
	int status = deflateInit2(&zStream, COMPRESSION_AMOUNT, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
	if (status != Z_OK) {
		return nil;
	}
	streamReady = YES;
	return nil;
}

- (NSError *)closeStream
{
	if (!streamReady) {
		return nil;
	}
	// Close the deflate stream
	streamReady = NO;
	int status = deflateEnd(&zStream);
	if (status != Z_OK) {
		return nil;
	}
	return nil;
}

- (NSData *)compressBytes:(Bytef *)bytes length:(NSUInteger)length shouldFinish:(BOOL)shouldFinish
{
	if (length == 0) return nil;
	
	NSUInteger halfLength = length/2;
	
	// We'll take a guess that the compressed data will fit in half the size of the original (ie the max to compress at once is half DATA_CHUNK_SIZE), if not, we'll increase it below
	NSMutableData *outputData = [NSMutableData dataWithLength:length/2]; 
	
	int status;
	
	zStream.next_in = bytes;
	zStream.avail_in = (unsigned int)length;
	zStream.avail_out = 0;
	
	NSInteger bytesProcessedAlready = zStream.total_out;
	while (zStream.avail_out == 0) 
	{
		
		if (zStream.total_out-bytesProcessedAlready >= [outputData length]) 
		{
			[outputData increaseLengthBy:halfLength];
		}
		
		zStream.next_out = (Bytef*)[outputData mutableBytes] + zStream.total_out-bytesProcessedAlready;
		zStream.avail_out = (unsigned int)([outputData length] - (zStream.total_out-bytesProcessedAlready));
		status = deflate(&zStream, shouldFinish ? Z_FINISH : Z_NO_FLUSH);
		
		if (status == Z_STREAM_END) 
		{
			break;
		} else if (status != Z_OK) 
		{
			return nil;
		}
	}
	
	// Set real length
	[outputData setLength: zStream.total_out-bytesProcessedAlready];
	return outputData;
}

+ (NSData *)compressData:(NSData*)uncompressedData
{
	NSData *outputData = [[GzipCompressor compressor] compressBytes:(Bytef *)[uncompressedData bytes] length:[uncompressedData length] shouldFinish:YES];
	if (outputData) 
	{
		return outputData;
	}
	return nil;
}

@synthesize streamReady;
@end

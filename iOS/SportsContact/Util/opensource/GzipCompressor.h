//
//  GzipCompressor.h
//  BaiduSearch
//
//  Created by zhuxiaohan on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface GzipCompressor : NSObject {
	BOOL streamReady;
	z_stream zStream;
}

// Convenience constructor will call setupStream for you
+ (id)compressor;

// Compress the passed chunk of data
// Passing YES for shouldFinish will finalize the deflated data - you must pass YES when you are on the last chunk of data
- (NSData *)compressBytes:(Bytef *)bytes length:(NSUInteger)length shouldFinish:(BOOL)shouldFinish;

// Convenience method - pass it some data, and you'll get deflated data back
+ (NSData *)compressData:(NSData*)uncompressedData;

// Sets up zlib to handle the inflating. You only need to call this yourself if you aren't using the convenience constructor 'compressor'
- (NSError *)setupStream;

// Tells zlib to clean up. You need to call this if you need to cancel deflating part way through
// If deflating finishes or fails, this method will be called automatically
- (NSError *)closeStream;

@property (assign, readonly) BOOL streamReady;
@end

//
//  NSObject+MGBlockPerformer.h
//  Ticketing-OEM
//
//  Created by MiNG on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTypes.h"

#ifdef NS_BLOCKS_AVAILABLE

//@class MGFuture;
@interface NSObject (MGBlockPerformer)
/* Runnable */
- (void)performRunnable:(Runnable)runnable;
- (void)performRunnable:(Runnable)runnable afterDelay:(NSTimeInterval)delay;
- (void)performRunnableInBackground:(Runnable)runnable;
- (void)performRunnableOnMainThread:(Runnable)runnable waitUntilDone:(BOOL)wait;
- (void)performRunnableNextRunLoop:(Runnable)runnable;
/* Callable*/
//- (MGFuture *)performCallable:(Runnable)aSelector NS_UNAVAILABLE;
@end

#endif

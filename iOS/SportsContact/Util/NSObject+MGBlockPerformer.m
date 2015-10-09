//
//  NSObject+MGBlockPerformer.m
//  Ticketing-OEM
//
//  Created by MiNG on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSObject+MGBlockPerformer.h"

#ifdef NS_BLOCKS_AVAILABLE

@implementation NSObject (MGBlockPerformer)
- (void)performRunnable:(Runnable)runnable
{
	[self performSelector:@selector(__MGRunnablePerformer__:) withObject:[runnable copy]];
}
- (void)performRunnable:(Runnable)runnable afterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(__MGRunnablePerformer__:) withObject:[runnable copy] afterDelay:delay];
}
- (void)performRunnableInBackground:(Runnable)runnable
{
	[self performSelectorInBackground:@selector(__MGRunnablePerformer__:) withObject:[runnable copy]];
}
- (void)performRunnableOnMainThread:(Runnable)runnable waitUntilDone:(BOOL)wait
{
	[self performSelectorOnMainThread:@selector(__MGRunnablePerformer__:) withObject:[runnable copy] waitUntilDone:wait];
}
- (void)performRunnableNextRunLoop:(Runnable)runnable
{
	[self performRunnableOnMainThread:runnable waitUntilDone:NO];
}

- (void)__MGRunnablePerformer__:(Runnable)runnable
{
	runnable();
}
@end

#endif

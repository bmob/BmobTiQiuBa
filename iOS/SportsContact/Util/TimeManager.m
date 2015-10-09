//
//  TimeManage.m
//  SportsContact
//
//  Created by Bmob on 15-2-6.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "TimeManager.h"

@implementation TimeManager
@synthesize distance        = _distance;
@synthesize askedServerTime = _askedServerTime;


-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

static TimeManager *defaultManager = NULL;

+(instancetype)defaultTimeManger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[TimeManager alloc] init];
    });
    
    return defaultManager;
}

@end

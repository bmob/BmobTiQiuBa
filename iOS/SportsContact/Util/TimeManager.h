//
//  TimeManage.h
//  SportsContact
//
//  Created by Bmob on 15-2-6.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeManager : NSObject


@property (assign) NSTimeInterval  distance;
@property (assign) BOOL            askedServerTime;

+(instancetype)defaultTimeManger;



@end

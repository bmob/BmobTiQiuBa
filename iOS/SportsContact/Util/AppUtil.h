//
//  AppUtil.h
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface AppUtil : NSObject

+ (NSString *)appVersion;
+ (NSString *)appShortVersion;
+ (NSString *)systemName;
+ (NSString *)systemVersion;
+ (NSString *)deviceType;
+ (NSString *)mac;
+ (NSString *)resolution;

+ (NSString *)deviceInfo;   // 设备名称（如iphone5，iphon5s等等）
+ (NSString *)systemInfo;   // ios系统名称（ios6，ios7等等）

@end

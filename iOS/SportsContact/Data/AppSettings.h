//
//  AppSettings.h
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  定义所有的Settings
 *
 */
#define SettingsIsLogin @"SettingsIsLogin"  // 用户是否是登陆状态
#define SettingsDeviceToken @"SettingsDeviceToken"
#define SettingsPushFlag @"flag"
#define SettingsPushFlagvalueNotice @"notice"

//百度推送
#define SettingBPushUserId @"BPushUserId"
#define SettingBPushChannelid @"BPushChannelId"

/**
 *  用户设置操作
 */
@interface AppSettings : NSObject

+ (NSString *)stringOfKey:(NSString *)aKey;
+ (void)setString:(NSString *)aString forKey:(NSString *)aKey;

+ (BOOL)boolOfKey:(NSString *)aKey;
+ (void)setBool:(BOOL)aBool forKey:(NSString *)aKey;

+ (NSNumber *)numberOfKey:(NSString *)aKey;
+ (void)setNumber:(NSNumber *)aNumber forKey:(NSString *)aKey;

+ (NSDictionary *)dictionaryOfKey:(NSString *)aKey;
+ (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey;

+ (NSData *)dataOfKey:(NSString *)aKey;
+ (void)setData:(NSData *)aData forKey:(NSString *)aKey;


+ (NSDictionary *)dictionaryFromPListFile:(NSString *)aPListFile;

+ (void)synchronize;
+ (void)removeObjectForKey:(NSString *)aKey;

@end

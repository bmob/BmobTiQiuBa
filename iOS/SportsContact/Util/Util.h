//
//  Util.h
//  SportsContact
//
//  Created by bobo on 14-7-17.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

@interface Util : NSObject

+ (BOOL)isValidOfPhoneNumber:(NSString*)aPhoneNumber;

+ (NSInteger)calAgeWithBirthDay:(NSDate *)aBirthDay;

+ (NSDictionary *)dictionaryFromPListFile:(NSString *)aPListFile;

//升序
+(NSString*)asckeyAscValue:(NSDictionary *)dic;
//url encode
+ (NSString*)stringByURLEncodingStringParameter:(NSString*)str;
//md5
+(NSString*)md5WithString:(NSString*)string;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+(UIImage *)scaleImage:(UIImage *)image width:(CGFloat)w;

+(UIImage *)resizeImage:(UIImage *)image width:(CGFloat)w height:(CGFloat)h;

+(NSString *)errorStringWithCode:(NSInteger)code;
@end

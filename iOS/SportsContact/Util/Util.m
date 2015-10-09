//
//  Util.m
//  SportsContact
//
//  Created by bobo on 14-7-17.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/xattr.h>

@implementation Util

+ (BOOL)isValidOfPhoneNumber:(NSString*)aPhoneNumber
{
    if (aPhoneNumber.length <= 0)
    {
        return NO;
    }
    
    NSString *phoneRegex = @"\\b(1)[358][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\b";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:aPhoneNumber];
}

+ (NSInteger)calAgeWithBirthDay:(NSDate *)aBirthDay
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:aBirthDay];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}

+ (NSDictionary *)dictionaryFromPListFile:(NSString *)aPListFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:aPListFile ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dictionary;
}

+(NSString*)asckeyAscValue:(NSDictionary *)dic{
    
    NSArray *keyArray = [dic allKeys];
    NSMutableArray *keyMutableArray = [NSMutableArray array];
    for (int i = 0; i < [keyArray count]; i++) {
        
        NSDictionary *tmpDic = [NSDictionary dictionaryWithObject:[keyArray objectAtIndex:i] forKey:@"key"];
        [keyMutableArray addObject:tmpDic];
        
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
    NSArray *sortedKeyArray = [keyMutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    NSString *tmpStr = @"";
    
    for (int i = 0; i < [sortedKeyArray count]; i++) {
        
        tmpStr = [tmpStr stringByAppendingFormat:@"%@=%@",[[sortedKeyArray objectAtIndex:i] objectForKey:@"key"],[dic objectForKey:[[sortedKeyArray objectAtIndex:i] objectForKey:@"key"]]];
        
        
    }
    
    return tmpStr;
    
}

+(NSString*)md5WithString:(NSString*)string
{
    const char *original_str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str,(CC_LONG) strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

+ (NSString*)stringByURLEncodingStringParameter:(NSString*)str
{
    // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
    // some characters that should be escaped in URL parameters, like / and ?;
    // we'll use CFURL to force the encoding of those
    //
    // We'll explicitly leave spaces unescaped now, and replace them with +'s
    //
    // Reference: <a href="\"http://www.ietf.org/rfc/rfc3986.txt\"" target="\"_blank\"" onclick="\"return" checkurl(this)\"="" id="\"url_2\"">http://www.ietf.org/rfc/rfc3986.txt</a>
    
    NSString *resultStr = str;
    
    CFStringRef originalString = (__bridge CFStringRef) str;
    CFStringRef leaveUnescaped = CFSTR(" ");
    CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                         originalString,
                                                         leaveUnescaped,
                                                         forceEscaped,
                                                         kCFStringEncodingUTF8);
    
    if( escapedStr )
    {
        NSMutableString *mutableStr = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
        CFRelease(escapedStr);
        
        // replace spaces with plusses
        [mutableStr replaceOccurrencesOfString:@" "
                                    withString:@"%20"
                                       options:0
                                         range:NSMakeRange(0, [mutableStr length])];
        resultStr = mutableStr;
    }
    return resultStr;
}



+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.1) {
        //        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        
        return success;
    }else  if ([[[UIDevice currentDevice] systemVersion] floatValue] > 5.0){
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }else{
        return NO;
    }
    
}

+(UIImage *)scaleImage:(UIImage *)image width:(CGFloat)w{
    CGFloat resizeH = w;
    CGFloat resizeW = w;

    UIGraphicsBeginImageContext(CGSizeMake(resizeW, resizeH));
    [image drawInRect:CGRectMake(0, 0, resizeW, resizeH)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

+(UIImage *)resizeImage:(UIImage *)image width:(CGFloat)w height:(CGFloat)h{
    
    CGFloat resizeH = 0.0f;
    CGFloat resizeW = 0.0f;
    CGFloat oldH    = image.size.height;
    CGFloat oldW    = image.size.width;
    

    
    CGFloat centerX = 0.0f;
    CGFloat centerY = 0.0f;
    resizeH = h;
    resizeW = w;
    centerX = 0.5*oldW - 0.5*resizeW;
    centerY = 0.5*oldH - 0.5*resizeH;
    

    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(centerX, centerY, resizeW, resizeH));
    CGRect smallBounds     = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context   = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage    = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return smallImage;
    
}

+(NSString *)errorStringWithCode:(NSInteger)code{
   
    NSMutableString *errorString = [NSMutableString string];
    switch (code) {
        case 101:{
            [errorString setString:@"用户名或密码不正确"];
        }
            break;
        case 202:{
            [errorString setString:@"用户名已存在"];
        }
            break;
        case 20002:{
            [errorString setString:@"网络不给力哦"];
        }
            break;
        
        default:{
            [errorString setString:@"未知错误"];
        }
            
            break;
    }
    
    return errorString;
}

@end

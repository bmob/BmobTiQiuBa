//
//  ViewUtil.m
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "ViewUtil.h"

@implementation ViewUtil

#pragma mark - 屏幕操作

+ (CGFloat)screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)statusBarHeight
{
    return 20.0;
}

+ (BOOL)isRetinaScreen
{
    return [UIScreen mainScreen].scale !=1.0;
}

+ (BOOL)is4Inch
{
    return [self screenHeight] > 480;
}

+ (UIInterfaceOrientation)curOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (UIWindow *)mainWindow
{
    return [[UIApplication sharedApplication].delegate window];
}

+ (UIWindow *)keyWindow
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel >= UIWindowLevelAlert)
    {
        window = [[UIApplication sharedApplication].delegate window];
    }
    return window;
}

+ (UITapGestureRecognizer *)addSingleTapGestureForView:(UIView *)aView target:(id)target action:(SEL)action
{
    UITapGestureRecognizer *tap = nil;
    if (aView) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [aView addGestureRecognizer:tap];
        [aView setUserInteractionEnabled:YES];
    }
    return tap;
}


+(UIColor *) hexStringToColor: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



@end

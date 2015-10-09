//
//  UIImage+Util.m
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "UIImage+Util.h"

@implementation UIImage (Util)

+ (UIImage *)imageFromColor:(UIColor *)aColor
{
    UIImage *image;
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, rect);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)defaultAvatarImage
{
    return [UIImage imageNamed:@"head.png"];
}

@end

//
//  ViewUtil.h
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LoadNib(aNibName) [[[NSBundle mainBundle] loadNibNamed:aNibName owner:nil options:nil] objectAtIndex:0]
#define LoadNibOwner(aNibName,aOwner) [[[NSBundle mainBundle] loadNibNamed:aNibName owner:aOwner options:nil] objectAtIndex:0]


@interface ViewUtil : NSObject

#pragma mark - 屏幕操作
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;
+ (CGFloat)statusBarHeight;
+ (BOOL)isRetinaScreen;
+ (BOOL)is4Inch;
+ (UIInterfaceOrientation)curOrientation;
+ (UIWindow *)keyWindow;
+ (UIWindow *)mainWindow;

+ (UITapGestureRecognizer *)addSingleTapGestureForView:(UIView *)aView target:(id)target action:(SEL)action;


//16进制颜色(html颜色值)字符串转为UIColor
+(UIColor *) hexStringToColor: (NSString *) stringToConvert;

@end

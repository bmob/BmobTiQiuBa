//
//  AppDelegate.h
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign)BOOL bmobInitState;

@end

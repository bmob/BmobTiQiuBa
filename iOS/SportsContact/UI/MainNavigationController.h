//
//  MainNavigationController.h
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNavigationController : UINavigationController

+ (instancetype)shareMainNavigationController;
- (void)pushContentViewControllerAnimated:(BOOL)animated;
- (void)popToLoginViewControllerAnimated:(BOOL)animated;

@end

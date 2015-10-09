//
//  MainTabBar.h
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarController.h"


@interface MainTabBar : UITabBar

- (void)selectAtIndex:(NSInteger)aIndex;
@property (nonatomic, weak) IBOutlet MainTabBarController *tabBarController;
@property (strong, nonatomic) IBOutlet UIView *popView;

@property (weak, nonatomic) IBOutlet UIView *popBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *centerPopButton;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *popItemViews;
@end

//
//  BaseViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import <ODRefreshControl.h>
#import "NSObject+MGBinding.h"
#import "NSObject+MGBlockPerformer.h"
#import "AppUtil.h"

@interface BaseViewController : UIViewController

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *huds;
@property (nonatomic, assign) BOOL isNeedRefresh;

//Loading view
- (void)showMessage:(NSString*)message;
- (void)showMessageText:(NSString*)message;
- (void)showLoadingView;
- (void)hideLoadingView;

//UI control
- (void)embeddedClickEvent:(id)event setBindingRunnable:(Runnable)runnable;
- (IBAction)onEmbeddedClick:(id)sender;


//返回按钮隐藏
- (UIButton *)backbutton;
- (void)hideBackButton;
- (void)showBackButton;
- (void)showBackRootButton;
- (void)showBackDefinedButton:(NSInteger)page;



//
- (UIButton *)rightButtonWithImage:(UIImage *)image hightlightedImage:(UIImage *) hightlightedImage;
- (UIButton *)rightButtonWithColor:(UIColor *)color hightlightedColor:(UIColor *) hightlightedColor;




- (void)hideTabBar;
- (void)showTabBar;

- (void)goBack;
- (void)needRefresh;
@end

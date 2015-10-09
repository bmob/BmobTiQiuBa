//
//  MainNavigationController.m
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MainNavigationController.h"
#import "ViewUtil.h"
#import <BmobSDK/Bmob.h>


@interface MainNavigationController ()

@property (assign, nonatomic) BOOL showDefaultPage;


@end

@implementation MainNavigationController


+ (instancetype)shareMainNavigationController
{
    return (MainNavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    BOOL isLogin = [BmobUser getCurrentUser] != nil;
    
    if (isLogin)
    {

        [self setNavigationBarHidden:YES];
        UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"MainTabBarController" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [loginStoryBoard instantiateInitialViewController];
        [self setViewControllers:[NSArray arrayWithObject:viewController]];
       
        
    } else
    {
        UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [loginStoryBoard instantiateViewControllerWithIdentifier:@"LoginDetailViewController"];
        [self setViewControllers:[NSArray arrayWithObject:viewController]];
        
        
        
        //箭头
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back.png"]];
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back.png"]];
        

        [self setNavigationBarHidden:YES];

    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushContentViewControllerAnimated:(BOOL)animated
{
    [self setNavigationBarHidden:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainTabBarController" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyBoard instantiateInitialViewController];
    [self setViewControllers:[NSArray arrayWithObject:viewController] animated:YES];
    
}

- (void)popToLoginViewControllerAnimated:(BOOL)animated
{
    [self setNavigationBarHidden:NO];
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [loginStoryBoard instantiateViewControllerWithIdentifier:@"LoginDetailViewController"];
    [self setViewControllers:[NSArray arrayWithObject:viewController] animated:YES];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

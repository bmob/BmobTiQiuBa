//
//  BaseViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewUtil.h"

MG_DEFINE_BINDING_KEY(kBindingKeyEmbeddedClick);

@interface BaseViewController ()

@property (nonatomic,unsafe_unretained) NSInteger backPage;

@end

@implementation BaseViewController

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
    self.huds = [NSMutableArray arrayWithCapacity:0];
    [self settingTitleView];
    [self settingBackbutton];
    self.title = self.navigationItem.title;
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
    if (!IOS7) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar88.png"] forBarMetrics:UIBarMetricsDefault];
    }else
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.isNeedRefresh = NO;
    //字体大小、颜色
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

//loading view
- (void)showMessage:(NSString*)message
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [view addSubview:hud];
    self.hud = hud;
    
    [_hud show:YES];
    [_hud hide:YES afterDelay:1.5];
}

- (void)showMessageText:(NSString*)message
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 40)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    hud.customView = label;
    [view addSubview:hud];
    self.hud = hud;
    
    [_hud show:YES];
    [_hud hide:YES afterDelay:3.0];
}

- (void)showLoadingView
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    if (![self.view viewWithTag:88888]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.labelText = @"加载中";
        hud.tag = 88888;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:15.0f];
    }else{
        MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:88888];
        hud.labelText = @"加载中";
        hud.mode = MBProgressHUDModeIndeterminate;
//        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:15.0f];
    }
    

//    [self.huds addObject:hud];
}

- (void)hideLoadingView
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:88888];
//    hud.labelText = @"加载中";
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.removeFromSuperViewOnHide = YES;
//    [self.view addSubview:hud];
    [hud hide:YES afterDelay:0.3f];
    
//    MBProgressHUD *hud = [self.huds lastObject];
//    [hud hide:YES];
//    [self.huds removeLastObject];
//    hud = nil;
}

//[btn setBinding:^(id sender)
// {
//     if (paymentType == YKPaymentMethodMBC)
//     {
//         self.memberCardFlag = !self.memberCardFlag;
//     }else
//     {
//         self.select = paymentTypeObj;
//     }
//     [tableView reloadData];
// } forKey:kBindingKeyEmbeddedClick];

- (void)embeddedClickEvent:(id)event setBindingRunnable:(Runnable)runnable
{
    [event setBinding:runnable forKey:kBindingKeyEmbeddedClick];
}

- (IBAction)onEmbeddedClick:(id)sender
{
    UIView *targetView = sender;
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        targetView =  [(UITapGestureRecognizer *)sender view];
    }
    
    void(^f)(id) = [targetView bindingForKey:kBindingKeyEmbeddedClick];
    if (f)
    {
        f(sender);
    }
	
}

- (void)settingBackbutton
{
    if ([self.navigationController.viewControllers count] > 1)
    {
        UIButton *backBtn = [self backbutton];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
}
- (void)settingBackRootbutton
{
    if ([self.navigationController.viewControllers count] > 1)
    {
        UIButton *backBtn = [self backRootbutton];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
}

- (void)settingBackDefinedbutton:(NSInteger)page
{
    self.backPage=page;
    
    if ([self.navigationController.viewControllers count] > 1)
    {
        UIButton *backBtn = [self backDefinedbutton];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
}



- (UIButton *)backbutton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"back"];
    UIImage *backBtnImageHightlighted = [UIImage imageNamed:@"back_hl"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn setImage:backBtnImageHightlighted forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    if (IOS7)
//    {
//        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
//    }else
//    {
//        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//    }
    return backBtn;
}
- (UIButton *)backRootbutton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"back"];
    UIImage *backBtnImageHightlighted = [UIImage imageNamed:@"back_hl"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn setImage:backBtnImageHightlighted forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBackRoot) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    if (IOS7)
    //    {
    //        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //    }else
    //    {
    //        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    //    }
    return backBtn;
}

- (UIButton *)backDefinedbutton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"back"];
    UIImage *backBtnImageHightlighted = [UIImage imageNamed:@"back_hl"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn setImage:backBtnImageHightlighted forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBackDefine) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    if (IOS7)
    //    {
    //        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //    }else
    //    {
    //        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    //    }
    return backBtn;
}





- (UIButton *)rightButtonWithImage:(UIImage *)image hightlightedImage:(UIImage *) hightlightedImage
{
    UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightbutton setImage:image forState:UIControlStateNormal];
    [rightbutton setImage:hightlightedImage forState:UIControlStateHighlighted];
    rightbutton.frame = CGRectMake(0, 0, 44, 44);
    rightbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    if (IOS7) {
//        rightbutton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
//    }
    return rightbutton;
}

- (UIButton *)rightButtonWithColor:(UIColor *)color hightlightedColor:(UIColor *) hightlightedColor
{
    UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightbutton setTitleColor:color  forState:UIControlStateNormal];
    [rightbutton setTitleColor:hightlightedColor  forState:UIControlStateHighlighted];
    rightbutton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    rightbutton.frame = CGRectMake(0, 0, 44, 44);
    rightbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //    if (IOS7) {
    //        rightbutton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    //    }
    return rightbutton;
}




- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
 
}
- (void)goBackRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)goBackDefine
{
    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -self.backPage)] animated:YES];
}


- (void)hideBackButton
{
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:YES];
}

- (void)showBackButton
{
    [self settingBackbutton];
}
- (void)showBackRootButton
{
    [self settingBackRootbutton];
}

- (void)showBackDefinedButton:(NSInteger)page
{
    [self settingBackDefinedbutton:page];
}




- (void)settingTitleView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
    label.text = self.title;
    label.textAlignment  = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [(UILabel *) self.navigationItem.titleView setText:title];
}

- (void)hideTabBar
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds);
                         tabBar.frame = tabFrame;
                         content.frame = window.bounds;
                     }];
    
    // 1
}


- (void)showTabBar
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIView *parent = tabBar.superview; // UILayoutContainerView
    UIView *content = [parent.subviews objectAtIndex:0];  // UITransitionView
    UIView *window = parent.superview;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tabFrame = tabBar.frame;
                         tabFrame.origin.y = CGRectGetMaxY(window.bounds) - CGRectGetHeight(tabBar.frame);
                         tabBar.frame = tabFrame;
                         
                         CGRect contentFrame = content.frame;
                         contentFrame.size.height -= tabFrame.size.height;
                     }];
    
    // 2
}



- (void)needRefresh
{
    self.isNeedRefresh = YES;
}


- (void)dealloc
{
    BDLog(@"dealloc - %@",[self class]);
}

@end

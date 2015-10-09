//
//  MainTabBarController.m
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MainTabBarController.h"
#import "MainTabBar.h"
#import "UserTipView.h"
#import "ViewUtil.h"
#import "PageScrollView.h"

@interface MainTabBarController ()
@property (weak, nonatomic) IBOutlet MainTabBar *mainTabBar;
@property(nonatomic, strong) PageScrollView  *scrollView;
@end

@implementation MainTabBarController
@synthesize scrollView          = _scrollView;


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
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setVCS];
//    [self.mainTabBar selectAtIndex:0];
    // Do any additional setup after loading the view.
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"first_user_in"] boolValue]) {
        UserTipView *tipView =  LoadNibOwner(@"UserTipView", self);
        [self.view addSubview:tipView];
        tipView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    
    //显示
//    BOOL viaLoginVC = [[[NSUserDefaults standardUserDefaults] objectForKey:@"viaLoginVC"] boolValue];
//    if (!viaLoginVC) {
//        [self addPageScrollView];
//    }
    
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)setVCS{
    NSArray *storyboardNames = @[@"Info", @"Teams", @"Match", @"Notice"];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:0];
    for (NSString *name in storyboardNames )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]];
        UINavigationController *viewController = [storyboard instantiateInitialViewController];
        
        //        UIImage *topbarBackgroundImage = [UIImage imageNamed:@"top_bar.png"];  //获取图片
        //        CGSize topbarSize = self.navigationController.navigationBar.bounds.size;  //获取Navigation Bar的位置和大小
        //        topbarBackgroundImage = [self scaleToSize:topbarBackgroundImage size:topbarSize];//设置图片的大小与Navigation Bar相同
        //        [viewController.navigationBar setBackgroundImage:topbarBackgroundImage forBarMetrics:UIBarMetricsDefault];  //设置背景
        //        [viewController.navigationBar setBackgroundColor:[UIColor clearColor]];
        //        [viewController.navigationBar setTintColor:[UIColor clearColor]];
        
        //        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 63)];
        //        imageView.image = topbarBackgroundImage;
        //        [[[[viewController viewControllers ]lastObject] view]addSubview:imageView];
        
        
        [viewControllers addObject:viewController];
    }
    [self setViewControllers:viewControllers];
    [self setSelectedIndex:0];
}

-(void)addPageScrollView{
    self.view.backgroundColor = [UIColor whiteColor];
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight;
    
    _scrollView                                = [[PageScrollView alloc] initWithFrame:CGRectMake(0, 0,width, height)];
    _scrollView.backgroundColor                = [UIColor colorWithWhite:1.0f alpha:0.0f];
    _scrollView.contentSize                    = CGSizeMake(width*4, height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.pagingEnabled                  = YES;
    UIImageView *imageView                     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width*3, height)];
    imageView.userInteractionEnabled           = YES;
    NSString *imageBundlePath                  = [NSBundle mainBundle].bundlePath;
    imageView.image                            = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/default_gugong.png",imageBundlePath]];
    imageView.clipsToBounds                    = YES;
    imageView.contentMode                      = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:imageView];
    _scrollView.autoresizingMask               = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    [self.view addSubview:_scrollView];
    [self.view bringSubviewToFront:_scrollView];
    
    [self performSelector:@selector(showPage) withObject:nil afterDelay:0.1f];
}

-(void)showPage{
    __weak typeof(self)weakSelf = self;
    //    CGFloat width = self.scrollView.contentSize.width;
    CGFloat height = self.scrollView.contentSize.height;
    CGFloat screenWidth = kScreenWidth;
    CGFloat time = 1.0f;
    CGFloat sleepTime = 1.0f;
    [UIView animateWithDuration:time animations:^{
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(0, 0, screenWidth, height) animated:NO];
    } completion:^(BOOL finished) {
        sleep(sleepTime);
        [UIView animateWithDuration:time animations:^{
            [weakSelf.scrollView scrollRectToVisible:CGRectMake(screenWidth, 0, screenWidth, height) animated:NO];
        } completion:^(BOOL finished) {
            sleep(sleepTime);
            [UIView animateWithDuration:time animations:^{
                [weakSelf.scrollView scrollRectToVisible:CGRectMake( screenWidth *2 , 0, screenWidth, height) animated:NO];
            } completion:^(BOOL finished) {
                sleep(sleepTime);
                [UIView animateWithDuration:time animations:^{
                    [weakSelf.scrollView scrollRectToVisible:CGRectMake( screenWidth *3 , 0, screenWidth, height) animated:NO];
                } completion:^(BOOL finished) {
//                    sleep(sleepTime);
                    [weakSelf.scrollView removeFromSuperview];
                }];
            }];
        }];
    }];
}

//-(void)hidePageScrollView{
//    NSLog(@"hidePageScrollView");
//    __weak typeof(self)weakSelf = self;
//    [UIView animateWithDuration:0.7f animations:^{
//        weakSelf.scrollView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [weakSelf.scrollView removeFromSuperview];
//    }];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self.mainTabBar selectAtIndex:selectedIndex];
    
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
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

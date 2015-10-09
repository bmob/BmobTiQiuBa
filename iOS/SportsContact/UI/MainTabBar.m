//
//  MainTabBar.m
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MainTabBar.h"
#import "ViewUtil.h"
#import "UIImage+Util.h"
#import "DataDef.h"
#import "NoticeManager.h"
#import "NSObject+MGBlockPerformer.h"
#import <BmobSDK/Bmob.h>


@interface TabBarItemView : UIView

@property (nonatomic, weak) IBOutlet UIButton *itemButton;
@property (nonatomic, weak) IBOutlet UILabel *itemLabel;

@end

@implementation TabBarItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end


@interface MainTabBar()

@property (strong, nonatomic) IBOutlet UIView *tabView;

@property (strong, nonatomic) IBOutletCollection(TabBarItemView) NSArray *tabBarItems;

@property (nonatomic, weak) IBOutlet UILabel *tipNumView;

@property (nonatomic, strong) NSDate *noticeDataTime;

@end

@implementation MainTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    self.noticeDataTime = [NSDate date];
    [self setBackgroundImage:[UIImage imageFromColor:[UIColor clearColor]]];
    LoadNibOwner(@"MainTabBar", self);
    LoadNibOwner(@"CenterPopView", self);
    [self addSubview:self.tabView];
    CGRect frame = self.tabView.frame;
    frame.origin.y = self.bounds.size.height - frame.size.height;
    [self.tabView setFrame:frame];

    [self.popView setHidden:YES];
    [self.tabBarController.view insertSubview:self.popView belowSubview:self];
    [self.popView setFrame:self.tabBarController.view.bounds];
    self.centerPopButton.selected = NO;
    self.popBackgroundView.alpha = 0.0;
    [ViewUtil addSingleTapGestureForView:self.popBackgroundView target:self action:@selector(onCenter:)];
    for (UIView *popItemView in self.popItemViews) {
        CGRect frame = popItemView.frame;
        frame.origin.y = self.tabBarController.view.frame.size.height;
        popItemView.frame = frame;
    }
    
    self.tipNumView.layer.cornerRadius = self.tipNumView.frame.size.height/2;
//    [self.tipNumView setHidden:YES];
    [self showTipNum:0];
    
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
//    [defaultCenter addObserver:self selector:@selector(readNoticeListFromWebFinished) name:kBmobInitSuccessNotification object:nil];
    [self readNoticeListFromWebFinished];
    
    [defaultCenter addObserver:self selector:@selector(reloadUnreadCount) name:kObserverUnreadNoticeChanged object:nil];
    [defaultCenter addObserver:self selector:@selector(didReceiveNewMessage:) name:kObserverNoticeRecieve object:nil];
  
}

- (void)addSubview:(UIView *)view
{
    if (view == self.tabView)
    {
        [super addSubview:view];
    }
}

-(void)readNoticeListFromWebFinished{
    [[NoticeManager sharedManager] readNoticeListFromWebFinished:NULL];
}

- (void)selectAtIndex:(NSInteger)aIndex
{
    for (int i = 0 ; i < [self.tabBarItems count]; i ++)
    {
        TabBarItemView *tabItem = [self.tabBarItems objectAtIndex:i];
        if (tabItem.itemButton.tag == aIndex) {
            [tabItem.itemLabel setHighlighted:YES];
            [tabItem.itemButton setSelected:YES];
        }else
        {
            [tabItem.itemLabel setHighlighted:NO];
            [tabItem.itemButton setSelected:NO];
        }
        
        
//        if (view.button.tag == aIndex)
//        {
//            [view.button setEnabled:NO];
//            [view.titleLabel setTextColor:LDColor(kLDColorDarkPurple_553285)];
//        }
//        else
//        {
//            [view.button setEnabled:YES];
//            [view.titleLabel setTextColor:[UIColor whiteColor]];
//        }
    }
}

- (void)didReceiveNewMessage:(id)sender
{
    [[NoticeManager sharedManager] readNoticeListFromWebFinished:NULL];
}

- (void)reloadUnreadCount
{
    BDLog(@"******Reload unread count");
//    [self performRunnable:^{
    [[NoticeManager sharedManager] readUnreadCountFinished:^(NSInteger count) {
        [self showTipNum:count];
    }];
//    } afterDelay:1.0];
    
}

- (void)showTipNum:(NSInteger)aNum{
    self.tipNumView.text = aNum > 99 ? @"99" : [NSString stringWithFormat:@"%ld",(long)aNum];
    //    [self sizeToFit];
    
    CGRect rect = self.tipNumView.frame;
    rect.size.height = 20.0;
    rect.size.width = [self.tipNumView.text length] < 2 ? 20.0 : 28;
    rect.origin.x = [self.tipNumView.text length] < 2 ? 293 : 285;
    
    //    if (rect.size.width<rect.size.height) {
    //        rect.size.width = rect.size.height;
    //    }
    self.tipNumView.frame = rect;
    
    self.tipNumView.layer.cornerRadius = self.tipNumView.frame.size.height/2;
    self.tipNumView.hidden = aNum==0;
    
    //    CGRect frame = self.frame;
    //    frame.size.width = MAX(self.numberlabel.frame.size.width+6,_smallWidth);
    //    frame.size.height=_smallWidth;
    //    self.frame = frame;
    //    self.numberlabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    //
    //    self.hidden=aNum==0;
    //    self.layer.cornerRadius = _smallWidth/2;
    //    [self setNumber:aNum];
    //    self.type=SquareTipNumViewTypeNumber;
}


- (IBAction)onSelectItemButton:(UIButton *)sender
{
    if (sender.tag == 3) {
        if (([[NSDate date] timeIntervalSince1970] - [self.noticeDataTime timeIntervalSince1970]) > 12) {
            self.noticeDataTime = [NSDate date];
            [[NoticeManager sharedManager] readNoticeListFromWebFinished:NULL];
        }
    }
   
    BDLog(@"on selectItem button %ld",(long)sender.tag);
    [self.tabBarController setSelectedIndex:sender.tag];
    if (self.centerPopButton.selected) {
        [self onCenter:self.centerPopButton];
    }
}

- (IBAction)onCenter:(id)sender {
//    self.popView.hidden = !self.popView.hidden;
//    if (self.popView.hidden) {
//        self.popView.hidden = NO;
//    }
    [self.centerPopButton setSelected:!self.centerPopButton.selected];
    [UIView animateWithDuration:0.2f animations:^{
        if (!self.centerPopButton.selected)
        {
            [self.centerPopButton setTransform:CGAffineTransformMakeRotation(0.0f)];
        }
        else
        {
            [self.centerPopButton setTransform:CGAffineTransformMakeRotation(M_PI_4 *3)];
        }
    } completion:^(BOOL finished) {
        if (self.centerPopButton.selected) {
            self.popView.hidden = NO;
            [UIView animateWithDuration:0.4 animations:^{
                for (UIView *popItemView in self.popItemViews) {
                    CGRect frame = popItemView.frame;
                    frame.origin.y = [self popItemStartY] + popItemView.tag * [self popItemStartH] - 10;
                    popItemView.frame = frame;
                    self.popBackgroundView.alpha = 0.7;
                }
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    for (UIView *popItemView in self.popItemViews) {
                        CGRect frame = popItemView.frame;
                        frame.origin.y = [self popItemStartY] + popItemView.tag * [self popItemStartH];
                        popItemView.frame = frame;
                    }
                }];
                
            }];
        }else
        {
            [UIView animateWithDuration:0.4 animations:^{
                for (UIView *popItemView in self.popItemViews) {
                    CGRect frame = popItemView.frame;
                    frame.origin.y = self.tabBarController.view.frame.size.height;
                    popItemView.frame = frame;
                    self.popBackgroundView.alpha = 0.0;
                }
            } completion:^(BOOL finished) {
                self.popView.hidden = YES;
            }];
        }
        
//        for (UIView *popItemView in self.popItemViews) {
//            NSTimeInterval duration = 0.38 * (self.popItemViews.count - popItemView.tag);
////            NSTimeInterval delay = 0;
//            [UIView animateKeyframesWithDuration:0.38 * (self.popItemViews.count - popItemView.tag)  delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//                CGRect frame = popItemView.frame;
//                frame.origin.y = 85 + popItemView.tag * 135;
//                popItemView.frame = frame;
//            } completion:nil];
//        
//        }
        
    }];
//    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
//    UIViewController *viewController = [centerStoryboard instantiateInitialViewController];
//    [self.tabBarController.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onCreateMatch:(id)sender {
    //CreateMatchNavi
    [self onCenter:nil];
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"CreateMatchNavi"];
    [self.tabBarController.navigationController presentViewController:viewController animated:YES completion:nil];

}

//ScoreManagerNavi
- (IBAction)onNextMatch:(id)sender {
    [self onCenter:nil];
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
    UINavigationController *viewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerNavi"];
    [[viewController.viewControllers firstObject] setValue:[NSNumber numberWithBool:YES] forKey:@"canEdit"];
    [self.tabBarController.navigationController presentViewController:viewController animated:YES completion:nil];
}
- (IBAction)onCreateLeague:(id)sender {
//    CreateLeagueNavi
    [self onCenter:nil];
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"CreateLeagueNavi"];
    [self.tabBarController.navigationController presentViewController:viewController animated:YES completion:nil];
}


- (float)popItemStartY
{
    return [ViewUtil is4Inch] ? 85 : 70;
}

- (float)popItemStartH
{
    return [ViewUtil is4Inch] ? 135 : 120;
}
@end

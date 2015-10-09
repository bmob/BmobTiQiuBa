//
//  ContactUsViewController.m
//  SportsContact
//
//  Created by Bmob on 15-3-24.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "ContactUsViewController.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hidesBottomBarWhenPushed{
    return YES;
}
- (IBAction)callSB:(id)sender {
    NSString *phoneNum = @"13560362140";// 电话号码
    
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    UIWebView * phoneCallWebView = (UIWebView *)[self.view viewWithTag:100];
    if ( !phoneCallWebView ) {
        
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];// 这个webView只是一个后台的容易 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
        
        [self.view addSubview:phoneCallWebView];
        phoneCallWebView.tag = 100;
    }
    
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

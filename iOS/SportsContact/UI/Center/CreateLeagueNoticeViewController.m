//
//  CreateLeagueNoticeViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-10.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "CreateLeagueNoticeViewController.h"
#import "Util.h"
#import "DataDef.h"

@interface CreateLeagueNoticeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CreateLeagueNoticeViewController

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
    self.title = self.name;
    UIButton *backBtn = [self backbutton];
    [backBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    self.textView.text = [NSString stringWithFormat:@"%@联赛已成功创建，由于所需输入数据较多，剩余步骤建议您用个人电脑访问%@网址完成。\n您也可以通过手机浏览器来完成（不推荐）", self.name, UrlLeageManage];
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationItem.leftBarButtonItem = nil;
    
//    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
//    [rButton setTitle:@"关闭" forState:UIControlStateNormal];
//    rButton.frame = CGRectMake(0, 0, 66, 44);
//    [rButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"to_webview"]) {
        NSString *url = [NSString stringWithFormat:@"%@?username=%@&password=%@", UrlLeageManage, [[NSUserDefaults standardUserDefaults]  objectForKey:@"loginUserName"],[[NSUserDefaults standardUserDefaults]  objectForKey:@"loginPassWord"]];
        [segue.destinationViewController setValue:url forKeyPath:@"urlString"];
    }
}

#pragma mark - Event handler
- (void)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onNext:(id)sender {
    [self performSegueWithIdentifier:@"to_webview" sender:nil];
}

@end

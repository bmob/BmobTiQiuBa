//
//  WebViewViewController.m
//  SportsContact
//
//  Created by bobo on 14/11/13.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "WebViewViewController.h"

#define kWebViewRequestTimeoutInterval 20.0    //webview请求超时时间

@interface WebViewViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation WebViewViewController

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
    if (self.webView == nil)
    {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.view addSubview:webView];
        [self setWebView:webView];
    }
    [self.webView setDelegate:self];
    
    if( [AppUtil systemVersion].floatValue >= 7.0f)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    else
    {
        CGRect frame = self.webView.frame;
        frame.origin.y = self.navigationController.navigationBar.bounds.size.height;
        frame.size.height -= self.navigationController.navigationBar.bounds.size.height;
        [self.webView setFrame:frame];
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startRefresh];
}

- (void)startRefresh
{
    if (self.urlString.length)
    {
        [self showLoadingView];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kWebViewRequestTimeoutInterval]];
    }
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorCancelled)//未完成加载时立即加载另一个请求发生该错误，忽略
    {
        return;
    }
    [self hideLoadingView];
    [self showMessage:@"网络不给力啊，请连接网络后重试"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


@end

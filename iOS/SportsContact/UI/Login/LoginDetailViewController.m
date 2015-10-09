//
//  LoginDetailViewController.m
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "LoginDetailViewController.h"
#import "ViewUtil.h"
#import "Util.h"
#import "NoticeManager.h"
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "MainNavigationController.h"
#import "TeamEngine.h"
#import "BPush.h"
#import "BPushUtil.h"
@interface LoginDetailViewController ()

@end

@implementation LoginDetailViewController

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
    
    
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.userNameText.delegate=self;
    self.passwordText.delegate=self;
    
    
    
    
    
    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];
    self.loginButton.backgroundColor=[ViewUtil hexStringToColor:@"f47900"];
    self.registerButton.backgroundColor=[ViewUtil hexStringToColor:@"555c64"];
    self.forgetpasswordButton.titleLabel.textColor=[ViewUtil hexStringToColor:@"f47900"];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[NSUserDefaults standardUserDefaults]  objectForKey:@"loginUserName"]!=0)
    {
        self.userNameText.text=[[NSUserDefaults standardUserDefaults]  objectForKey:@"loginUserName"];
        self.passwordText.text=[[NSUserDefaults standardUserDefaults]  objectForKey:@"loginPassWord"];

    }
    

    
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"FindPassword"])
	{
//        BDLog(@"**********FindPassword");
	}
    else if ([segue.identifier isEqualToString:@"NormalRegister"])
    {
//        BDLog(@"**********NormalRegister");

    }
    else
    {
        
    }

    
}



- (IBAction)loginButtonClick:(id)sender
{
    
    [self showLoadingView];

    
    if ([self.userNameText.text length]==0 || [self.passwordText.text length]==0)
    {
        
        [self hideLoadingView];

        [self showMessage:@"账号、密码不能为空！"];
    }
    else
    {
        
        
        
        
        if ([Util isValidOfPhoneNumber:self.userNameText.text])//判断手机号合法
        {
            
            
//            [self showLoadingView];
            
            
            //判断账号有没注册
            id userName=[NSString stringWithFormat:@"%@",self.userNameText.text];
            
            BmobQuery *query = [BmobQuery queryForUser];
            
            [query whereKey:@"username" equalTo:userName];
            __weak typeof(BmobQuery *)weakQuery = query;
            //查看username有无相关数据
            [weakQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                
                
                if ([array count]==1)
                {
                    
                    [BmobUser loginWithUsernameInBackground:self.userNameText.text
                                                   password:self.passwordText.text
                                                      block:^(BmobUser *user, NSError *error)
                    {
                        
                        [self hideLoadingView];
                                                          
                        if (!error)
                        {
                            BDLog(@"登陆成功！");
                                                              
                            [[NSUserDefaults standardUserDefaults] setObject:self.userNameText.text forKey:@"loginUserName"];
                            [[NSUserDefaults standardUserDefaults] setObject:self.passwordText.text forKey:@"loginPassWord"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"viaLoginVC"];
                            [(MainNavigationController *)self.navigationController pushContentViewControllerAnimated:NO];
                            
                            
                            if ([BmobUser getCurrentUser])
                            {
                                    [NoticeManager updatePushProfile];
                                    [[NoticeManager sharedManager] bindDB];
                            }
                            
                            [self setPushTag];
                        }
                        else
                        {
                                [self showMessage:@"账号或密码错误,请核对！"];
                                                              
                                BDLog(@"登陆失败失败：%@",[error description]);
                            
                        }
                                                          
                                                          
                    }];
                    
                    
                    
                }
                else if ([array count]==0)
                {
                    
                    [self hideLoadingView];
                    
                    [self showMessage:@"该账户还没注册，请先注册！"];
                    
                }
                else
                {
                    
                }
                
                
            }];

            
            
            
            
        }
        else
        {   [self hideLoadingView];
            [self showMessage:@"请输入正确的手机号码！"];
        }
    
        
    }
    
    
    
}



-(void)setPushTag{
    BmobUser *user = [BmobUser getCurrentUser];
    
    if (!user) {
        return;
    }else{
//        BDLog(@"listTags ")
//        [BPush listTags];
        [TeamEngine getTeamsObjectIdWith:user
                                   block:^(id result, NSError *error) {
                                       NSArray *array = result;
                                       if (array && array.count > 0) {
//                                           for (NSString *tmpString in array) {
                                               [BPushUtil setTags:array];
//                                           }
                                           
                                       }
//                                       BDLog(@"array %@",array);
                                   }];
    }
    
    
}










- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.userNameText resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    
    [self.passwordText resignFirstResponder];
    return YES;
}





@end

//
//  UpdatePasswordsViewController.m
//  SportsContact
//
//  Created by Nero on 11/20/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "UpdatePasswordsViewController.h"
#import <BmobSDK/BmobQuery.h>
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>


@interface UpdatePasswordsViewController ()


@property (weak, nonatomic) IBOutlet UITextField *theOldPassWord;
@property (weak, nonatomic) IBOutlet UITextField *theNewPassWord;
@property (weak, nonatomic) IBOutlet UITextField *definePassWord;





@end

@implementation UpdatePasswordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)defineButtonClick:(id)sender
{
    [self showLoadingView];
    
    if ([self.theOldPassWord.text length]==0 && [self.theNewPassWord.text length]==0 && [self.definePassWord.text length]==0 )
    {
        [self hideLoadingView];
        [self showMessage:@"输入框不能为空！"];
        
    }
    else
    {
        //判断旧密码
        
        NSString *originalPW=[[NSUserDefaults standardUserDefaults]  objectForKey:@"loginPassWord"];
        if ([self.theOldPassWord.text isEqualToString:originalPW])
        {
            if ([self.theNewPassWord.text isEqualToString:self.definePassWord.text])
            {
                BDLog(@"********%@***********%@************%@",self.theOldPassWord.text,self.theNewPassWord.text,self.definePassWord.text);
                
                BmobUser *user=[BmobUser getCurrentUser];
                [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    [user setObject:self.definePassWord.text  forKey:@"password"];
                    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                     {
                         
                         [self hideLoadingView];
                         
                         
                         if (isSuccessful)
                         {
                             [self showMessage:@"密码更新成功！"];
                             
                             [self.navigationController popViewControllerAnimated:YES];
                             
                             
                             [[NSUserDefaults standardUserDefaults] setObject:self.definePassWord.text forKey:@"loginPassWord"];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                         }else
                         {
                             [self showMessage:@"密码更新失败！"];
                             
                         }
                     }];
                }];
            }
            else
            {
                [self hideLoadingView];
                [self showMessage:@"两次输入的密码不同，请核对后提交！"];
                
            }
        }
        else
        {
            [self hideLoadingView];
            [self showMessage:@"输入旧密码不正确！"];
        }
    }
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

//
//  FindPasswordViewController.m
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "ViewUtil.h"
#import "Util.h"
#import "LoginEngine.h"


#import <BmobSDK/BmobQuery.h>
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>





@interface FindPasswordViewController ()

@end

@implementation FindPasswordViewController
@synthesize timerFinishBlock;

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
    
    
    textField1.delegate = self;
    textField2.delegate = self;
    
    submitButton.tag=1;
    
    self.lineImageView.hidden=YES;
    textField2.hidden=YES;
    self.textLabel2.hidden=YES;
    
    [textField1 becomeFirstResponder];
    
    
    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];
    submitButton.backgroundColor=[ViewUtil hexStringToColor:@"f47900"];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)viewDidDisappear:(BOOL)animated
{
//    [super viewDidDisappear:animated];
    
    if (submitButton.tag!=1)
    {
        self.timerFinishBlock(YES);

    }
    
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







-(void)timeCounting
{
    __block int timeout=60; //倒计时时间
    
    __block BOOL isEnterBackGpBool=NO;

    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout<=0)
        {
            //倒计时结束（  收到验证码，没收到验证码  ）
            dispatch_source_cancel(_timer);//结束计时
//            dispatch_release(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
 
                    
                    if (submitButton.tag==2 || submitButton.tag==4)
                    {
                        self.testLabel1.text=@"验证码";
                        submitButton.tag=4;//倒计时结束，重新获取手机验证码
                        [submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];

                    }
                    else
                    {
                        
                    }
                
                
            });
            
            
            
        }else{
            
            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"验证码 (%d分%.2d秒)",minutes,seconds];

            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                
                isEnterBackGpBool=[[[NSUserDefaults standardUserDefaults] valueForKey:@"isEnterBackGrounpBool"] boolValue];
                
                if (isEnterBackGpBool)
                {
                    
                    NSInteger backGroundTime=[[[NSUserDefaults standardUserDefaults] valueForKey:@"backGroundSecond"] integerValue];
                    
                    timeout=(int)(timeout-backGroundTime);
                    
                    if (timeout>0)
                    {
                        
                    }
                    else if(timeout<=0)
                    {
                        timeout=0;
                    }
                    
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isEnterBackGrounpBool"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                }

                
                
                
                BDLog(@"计时中  submitButton.tag=====%ld",(long)submitButton.tag);

                
                if (submitButton.tag==3)
                {
                    self.testLabel1.text=@"新密码";

                }
                else
                {
                    self.testLabel1.text=strTime;
                }
                
                
                
                
                self.timerFinishBlock = ^(BOOL isFinish){
                    
                    
                    if (isFinish)
                    {
                        dispatch_source_cancel(_timer);//结束计时
                        
                    }
                    
                };
                
                
                
            });
            
            timeout--;
            
        }
        
        
        
    });
    
    
    dispatch_resume(_timer);
    
}




-(void)timeFireMethod
{
    secondsCountDown--;
    if(secondsCountDown==0)
    {
        [countDownTimer invalidate];
        
        [submitButton setTitle:@"提交" forState:UIControlStateNormal];
        
        submitButton.tag=2;//2秒后，变回提交功能

    }

}


-(void)getTheAudoKey
{
    
    //向手机发送验证码。
#warning 调用短信接口
    [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:findUserName
                                           andTemplate:@""
                                           resultBlock:^(int number, NSError *error) {
                                               [self hideLoadingView];
                                               
                                               
                                               if (error)
                                               {
                                                   BDLog(@"error %@",[error description]);
                                                   
                                                   [self showMessage:@"获取验证码失败，请重试！"];
                                                   
                                                   self.testLabel1.text=@"验证码(获取失败)";
                                                   submitButton.tag=4;//倒计时结束，重新获取手机验证码
                                                   [submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
                                                   
                                                   
                                                   
                                                   
                                                   
                                               }
                                               else
                                               {
                                                   
                                                   
                                                   //计时
                                                   [self timeCounting];
                                                   
                                                   if (submitButton.tag==4)
                                                   {
                                                       
                                                       secondsCountDown = 2;
                                                       countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                                                   }
                                                   
                                                   
                                                   
                                               }
                                           }];
    
}


-(void)firstButtonAction
{
    

        findUserName=textField1.text;

        textField1.text=nil;
        textField1.placeholder=@"请输入验证码";
        textField1.secureTextEntry=NO;
        
        
    
//        [self.testLabel1 setFrame:CGRectMake(15.0, 40.0, 100.0, 20.0)];
//        [textField1 setFrame:CGRectMake(130.0, 35.0, 170.0, 30.0)];
    
    [self.testLabel1 setFrame:CGRectMake(15.0, 40.0, 140.0, 20.0)];
    [textField1 setFrame:CGRectMake(160.0, 35.0, 130.0, 30.0)];

    
        submitButton.tag=2;
        
    
//        //计时
//        [self timeCounting];

    
       [self getTheAudoKey];
        
        
}


-(void)secondButtonAction
{
    
    self.timerFinishBlock(YES);//停止计时

    
    textField1.text=nil;
    textField1.placeholder=@"请输入新密码";
    
    textField1.secureTextEntry=YES;//IOS7有效，IOS6无效？
    
    submitButton.tag=3;
    
    self.textLabel2.hidden=NO;
    textField2.hidden=NO;
    self.lineImageView.hidden=NO;
    
    
    
    self.testLabel1.text=@"新密码";
    self.textLabel2.text=@"确认新密码";
    
    
    [self.testLabel1 setFrame:CGRectMake(15.0, 40.0, 100.0, 20.0)];
    [self.textLabel2 setFrame:CGRectMake(15.0, 80.0, 100.0, 20.0)];
    
    [textField1 setFrame:CGRectMake(130.0, 35.0, 120.0, 30.0)];
    [textField2 setFrame:CGRectMake(130.0, 75.0, 120.0, 30.0)];
    
    [self.textBackground setFrame:CGRectMake(0.0, 25.0, 320.0, 84.0)];
    
    [submitButton setFrame:CGRectMake(20.0, 145.0, 280.0, 44.0)];

    
}



-(void)updatePassword
{
    
    
    BDLog(@"********%@***********%@************%@",findUserName,findAudoNumber,findPassword);
    
        
    [self showLoadingView];
    
    [BmobUser resetPasswordInbackgroundWithSMSCode:findAudoNumber andNewPassword:findPassword block:^(BOOL isSuccessful, NSError *error) {
        [self hideLoadingView];
        
        if (isSuccessful) {
            
            [self showMessage:@"更新成功！"];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:findUserName forKey:@"loginUserName"];
            [[NSUserDefaults standardUserDefaults] setObject:findPassword forKey:@"loginPassWord"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            
        }
        else{
            
            [self showMessage:@"更新失败！"];
            
            [[NSUserDefaults standardUserDefaults] setObject:findUserName forKey:@"loginUserName"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginPassWord"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}




- (IBAction)submitPhonenumber:(id)sender
{
    
    BDLog(@"submitButton.tag=====%ld",(long)submitButton.tag);
    
    
    switch (submitButton.tag)
    {
        case 1:
        {
            
            //点解按钮，首先判断改手机号码有没被注册，无注册才进入获取验证码界面
            
            
            if ([textField1.text length]!=0)
            {

                
                if ([Util isValidOfPhoneNumber:textField1.text])//判断手机号合法
                {
                    
                    
                    [self showLoadingView];
                    
                    
                    [LoginEngine getUserinfoWithPhoenumber:textField1.text block:^(id result, NSError *error) {
                       
                        NSMutableArray *array=[[NSMutableArray alloc]init];
                        array=result;
                        
                        if ([array count]==1)
                        {
                            
                            //手机获取验证码
                            [self firstButtonAction];
                            
                            
                        }
                        else if ([array count]==0)
                        {
                            
                            [self hideLoadingView];
                            
                            [self showMessage:@"该账号还没有注册！"];
                            
                        }
                        else
                        {
                            [self hideLoadingView];
                        }
                        
                        
                    }];
 
                }
                else
                {
                    [self showMessage:@"请输入正确的手机号码！"];
                }
 
            }
            else
            {
                [self showMessage:@"账号不能为空！"];
                
            }

        }
            break;
            
        case 2:
        {
            
            //点解按钮，验证码成功之后，进入确认密码界面


            if ([textField1.text length]!=0)
            {
                
                findAudoNumber=textField1.text;
                
//                if ([findAudoNumber isEqualToString:textField1.text])
//                {

                    [self secondButtonAction];
                    
//                }
//                else
//                {
//                    [self showMessage:@"验证码错误！"];
//                }

                
                
            }
            else
            {
                [self showMessage:@"验证码不能为空!"];
            }


            
        }
            break;
            
        case 3:
        {
            
            //提交新密码，提交更新请求
            
            if ([textField1.text isEqualToString:textField2.text])
            {
                
                findPassword=textField1.text;
                [self updatePassword];
                

            }
            else
            {
                [self showMessage:@"2次输入的密码不一致!"];
            }
            
            


            
        }
            break;

        case 4:
        {

            
            //重新获取验证码
            
            [self showLoadingView];

            textField1.text=nil;
            
//            [self timeCounting];
            
            [self getTheAudoKey];

            
//            secondsCountDown = 2;
//            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
            
            
            

            
        }
            break;

            
        default:
            break;
    }

    
    
    
    
    
    
    


}












#pragma mark UITextDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField1 resignFirstResponder];
    
    [textField2 resignFirstResponder];
    
    return YES;
}













@end

//
//  NormalRegisterViewController.m
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "NormalRegisterViewController.h"
#import "ViewUtil.h"
#import "Util.h"
#import "CodeViewController.h"

#import "LoginEngine.h"



#import <BmobSDK/BmobQuery.h>
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>


#import "NoticeManager.h"
#import "MainNavigationController.h"








@interface NormalRegisterViewController ()

@end

@implementation NormalRegisterViewController

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
    
    

    self.textField1.delegate=self;
    self.textField2.delegate=self;
    self.textField3.delegate=self;
    
    self.submitButton.tag=1;
    
    
    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];
    self.submitButton.backgroundColor=[ViewUtil hexStringToColor:@"f47900"];
    self.submitButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableSubmitButton) name:UITextFieldTextDidChangeNotification object:nil];

}

-(void)viewDidDisappear:(BOOL)animated
{
//    [super viewDidDisappear:animated];

    if (self.submitButton.tag!=1)
    {
        self.timerFinishBlock(YES);
        
    }  
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

    
    [self.textField1 becomeFirstResponder];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
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

-(void)enableSubmitButton{
    if (self.textField1.text.length > 0 && self.textField2.text.length > 0) {
        self.submitButton.enabled = YES;
    }else{
        self.submitButton.enabled = NO;
    }
}

-(void)registerTimeCounting
{
    __block int timeout=60; //倒计时时间
    
    __block BOOL isEnterBackGpBool=NO;
    
    
    
    dispatch_queue_t queue = dispatch_get_main_queue();//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
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
                
                
                if (self.submitButton.tag==2 || self.submitButton.tag==3)
                {
                    self.label1.text=@"验证码";
                    self.submitButton.tag=3;//倒计时结束，重新获取手机验证码
                    [self.submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
                    
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
                
                BDLog(@"计时中  submitButton.tag=====%ld",(long)self.submitButton.tag);
                

                    self.label1.text=strTime;
                
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
        
        [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
        
        self.submitButton.tag=2;//2秒后，变回提交功能
        
    }
    
    
    
}


-(void)getTheAudoKey
{
    
    //向手机发送验证码。
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:registerUserName,@"mobile", nil];
    
    [BmobCloud callFunctionInBackground:@"getMsgCode" withParameters:dictionary block:^(id object, NSError *error) {
        
        [self hideLoadingView];
        
        
        if (error)
        {
            
            [self showMessage:@"获取验证码失败，请重试！"];

            self.label1.text=@"验证码(获取失败)";
            
            self.submitButton.tag=3;//倒计时结束，重新获取手机验证码
            [self.submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];


            
        }
        else
        {
            BDLog(@"code=====%@",[NSString stringWithFormat:@"%@",object]);
            
            registerAudoNumber=[NSString stringWithFormat:@"%@",object];
            
            
            if (self.submitButton.tag==3)
            {
                secondsCountDown = 2;
                countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
            }
            
            [self registerTimeCounting];
            
        }
        
        
    }] ;

    
}

/*
-(void)firstButtonAction
{
    
    
        self.textField1.text=nil;
        self.textField1.placeholder=@"请输入验证码...";
        
        self.iconImage1.hidden=YES;
        self.iconImage2.hidden=YES;
        self.iconImage3.hidden=YES;
        
        self.lineImage1.hidden=YES;
        self.lineImage2.hidden=YES;
        
        self.textField2.hidden=YES;
        self.textField3.hidden=YES;
        
        self.label2.hidden=YES;
        self.label3.hidden=YES;
        
        self.submitButton.tag=2;
        
        
        [self.label1 setFrame:CGRectMake(15.0, 35.0, 140.0, 20.0)];
        [self.textField1 setFrame:CGRectMake(160.0, 30.0, 130.0, 30.0)];
        [self.backGroundImage setFrame:CGRectMake(0.0, 25.0, 320.0, 44.0)];
        [self.submitButton setFrame:CGRectMake(20.0, 105.0, 280.0, 44.0)];
        
    

    
        [self getTheAudoKey];

    

    
}
*/
-(void)firstButtonAction{
    
//    CodeViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CodeVC"];
//    cvc.registerUserName = self.textField1.text;
//    cvc.registerPassword = self.textField2.text;
//    [cvc getTheAudoKey];
//    
//    [self.navigationController pushViewController:cvc animated:YES];
    
}




- (IBAction)submitButtonClick:(id)sender
{
    
    BDLog(@"submitButton.tag=====%ld",(long)self.submitButton.tag);
    
    [self.view endEditing:YES];
    
    switch (self.submitButton.tag)
    {
        case 1:
        {
            
            
            //点击按钮，不为空，提交账号、密码，如果账号之前没注册的，进入获取验证码
            if ([self.textField1.text length]!=0 && [self.textField2.text length]!=0)
            {
                
                
                
                if ([Util isValidOfPhoneNumber:self.textField1.text])//判断手机号合法
                {
                    
                    
                    [self showLoadingView];
                    
                    [LoginEngine getUserinfoWithPhoenumber:self.textField1.text block:^(id result, NSError *error) {
                        
                        
                        if (!error)
                        {
                            
                            NSMutableArray *array=[[NSMutableArray alloc]init];
                            array=result;
                            
                            if ([array count]==1)
                            {
                                [self hideLoadingView];
                                
                                [self showMessage:@"该账户已经注册！"];
                                
                            }else if ([array count]==0){
                                
                                registerUserName=self.textField1.text;
                                registerPassword=self.textField2.text;
//                                registerInvitationNumber=[self.textField3.text intValue];
                                
//                                [self firstButtonAction];
                                [self performSegueWithIdentifier:@"toCodeVC" sender:nil];
                                
                            }else{
                                
                            }
                        }else{
                            [self showMessage:@"网络错误！"];
                            
                        }
                    }];
                }else{
                    [self showMessage:@"请输入正确的手机号码！"];
                }
            }else{
                [self showMessage:@"账号、密码不能为空！"];
                
            }
        }
            break;
            
        case 2:
        {
            
            
            
            //点解按钮，验证码成功之后，插入用户数据表，直接进入个人中心主界面，如果是填了『球队邀请码』的，验证正确之后，直接加入改球队
            
            if ([self.textField1.text length]!=0)
            {
                
                
                
                if ([registerAudoNumber isEqualToString:self.textField1.text])
                {
                    //验证成功，插入数据表
                    
                    [self showLoadingView];
                    
                    [LoginEngine getAddUserWithPhoenumber:registerUserName password:registerPassword registerInvitationStr:self.textField3.text block:^(id result, NSError *error) {
                        
                        [self hideLoadingView];

                        
                        if (!error)
                        {
                            
                            BDLog(@"************注册成功！");
                            
                            [self showMessage:@"注册成功！"];
                            
                            self.timerFinishBlock(YES);
                            
                            [[NSUserDefaults standardUserDefaults] setObject:registerUserName forKey:@"loginUserName"];
                            [[NSUserDefaults standardUserDefaults] setObject:registerPassword forKey:@"loginPassWord"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                            
                            [(MainNavigationController *)self.navigationController pushContentViewControllerAnimated:YES];
                            
                            if ([BmobUser getCurrentUser])
                            {
                                [NoticeManager updatePushProfile];
                                [[NoticeManager sharedManager] bindDB];
                            }

                            
                            
                            //球队邀请码，将用户加入相应的球队
                            
                            if ([self.textField3.text length]!=0)
                            {
                                
                                BmobQuery *query = [BmobQuery queryWithClassName:kTableTeam];
                                query.limit = 1;
                                [query whereKey:@"reg_code" equalTo:self.textField3.text];
                                [query selectKeys:@[@"objectId"]];
                                __weak typeof(self) weakSelf = self;
                                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                                    if (array.count >= 1) {
                                        BmobObject *tmpObj = [array firstObject];
                                        [weakSelf joinIntoTeam:tmpObj.objectId];
                                    }else{
                                        [weakSelf showMessageText:@"球队邀请码错误，请手动搜索加入球队！"];
                                    }
                                    
                                }];
                                
                                

                            }
                        }
                        else
                        {
                            
                            [self showMessage:@"注册失败，请重新注册"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginUserName"];
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginPassWord"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                        }
                        
                        
                        [self.navigationController popViewControllerAnimated:YES];

                        
                    }];
                }
                else
                {
                    [self showMessage:@"验证码错误！"];

                }
            }
            else
            {
                [self showMessage:@"验证码不能为空！"];

            }

        }
            break;

        case 3:
        {
            
            //重新获取验证码
            [self showLoadingView];
            
            self.textField1.text=nil;
            
//            [self registerTimeCounting];
            
            [self getTheAudoKey];
            
//            secondsCountDown = 2;
//            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
            
            
            
            
            
        }
            break;
        default:
            break;
    }
}


-(void)joinIntoTeam:(NSString *)teamObjectId{
    BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamObjectId];
    //新建relation对象
    BmobRelation *relation = [BmobRelation relation];
    //relation添加id为25fb9b4a61的用户
    [relation addObject:[BmobUser getCurrentUser]];   //obj 添加关联关系到footballer列中
    [team addRelation:relation forKey:@"footballer"];
    //异步更新team的数据
    __weak typeof(self) weakSelf = self;
    [team updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         BDLog(@"error %@",[error description]);
         
         if (isSuccessful)
         {
             [weakSelf showMessage:@"加入球队成功！"];
         }
         else
         {
             [weakSelf showMessage:@"球队邀请码错误，请手动搜索加入球队！"];
         }
         
         
         
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField1 resignFirstResponder];
    
    [self.textField2 resignFirstResponder];
    
    [self.textField3 resignFirstResponder];

    
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toCodeVC"]) {
        CodeViewController *cvc = segue.destinationViewController;
        cvc.registerUserName = self.textField1.text;
        cvc.registerPassword = self.textField2.text;
        cvc.reg_code = self.textField3.text;
    }
}


@end

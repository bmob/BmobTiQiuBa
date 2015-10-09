//
//  CodeViewController.m
//  SportsContact
//
//  Created by Bmob on 15-3-23.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "CodeViewController.h"
#import <BmobSDK/Bmob.h>
#import "ViewUtil.h"

#import "LoginEngine.h"
#import "NoticeManager.h"
#import "MainNavigationController.h"


@interface CodeViewController (){
    
}
@property (strong, nonatomic) IBOutlet UILabel *codeAndTimeLabel;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *regetCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *sumbitButton;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (assign) NSInteger secondsCountDown;
@end

@implementation CodeViewController
@synthesize codeAndTimeLabel   = _codeAndTimeLabel;
@synthesize codeTextField      = _codeTextField;
@synthesize regetCodeButton    = _regetCodeButton;
@synthesize sumbitButton       = _sumbitButton;
@synthesize registerPassword   = _registerPassword;
@synthesize registerUserName   = _registerUserName;
@synthesize registerAudoNumber = _registerAudoNumber;
@synthesize reg_code           = _reg_code;
@synthesize countdownTimer     = _countDownTimer;
@synthesize secondsCountDown   = _secondsCountDown;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];
    self.sumbitButton.backgroundColor=[ViewUtil hexStringToColor:@"f47900"];
    self.regetCodeButton.enabled = NO;
    self.codeAndTimeLabel.text = @"验证码(1分00秒)";
    [self getTheAudoKey];
    _secondsCountDown = 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack{
    [super goBack];
    [self hideLoadingView];
}

-(void)dealloc{
    
    if (self.countdownTimer && [self.countdownTimer isValid]) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
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
                
                
//                if (self.submitButton.tag==2 || self.submitButton.tag==3)
//                {
//                    self.label1.text=@"验证码";
//                    self.submitButton.tag=3;//倒计时结束，重新获取手机验证码
//                    [self.submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
//                    
//                }
//                else
//                {
//                    
//                }
                 _regetCodeButton.enabled = YES;
                self.codeAndTimeLabel.text = @"验证码";
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
                    
                    int backGroundTime=[[[NSUserDefaults standardUserDefaults] valueForKey:@"backGroundSecond"] intValue];
                    
                    timeout=timeout-backGroundTime;
                    
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
                
//                BDLog(@"计时中  submitButton.tag=====%ld",(long)self.submitButton.tag);
                
                
                self.codeAndTimeLabel.text=strTime;
                
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
    _secondsCountDown--;
        
    if(_secondsCountDown==0)
    {
        [_countDownTimer invalidate];
        _regetCodeButton.enabled = YES;
       
    }

    
    
}

- (IBAction)regetCode:(id)sender {
    self.secondsCountDown = 60;
    self.codeAndTimeLabel.text = @"验证码(1分00秒)";
    [self getTheAudoKey];
}

-(void)getTheAudoKey
{
    
    //向手机发送验证码。
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_registerUserName,@"mobile", nil];
    
    [BmobCloud callFunctionInBackground:@"getMsgCode" withParameters:dictionary block:^(id object, NSError *error) {
        
        [self hideLoadingView];
        
        
        if (error)
        {
            
//            [self showMessage:@"获取验证码失败，请重试！"];
//            
//            self.label1.text=@"验证码(获取失败)";
//            
//            self.submitButton.tag=3;//倒计时结束，重新获取手机验证码
//            [self.submitButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
            
            
            
        }
        else
        {
            BDLog(@"code=====%@",[NSString stringWithFormat:@"%@",object]);
            
            _registerAudoNumber=[NSString stringWithFormat:@"%@",object];
            
            
//            if (self.submitButton.tag==3)
            {
//                secondsCountDown = 2;
//                _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
            }
            
//            [self registerTimeCounting];
            
            if ([self.countdownTimer isValid]) {
                [self.countdownTimer invalidate];
                self.countdownTimer = nil;
            }
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                                 selector:@selector(timeCounting)
                                                                 userInfo:nil
                                                                  repeats:YES];
            [[NSRunLoop  currentRunLoop] addTimer:self.countdownTimer forMode:NSDefaultRunLoopMode];
        }
        
        
    }] ;
    
    
}

-(void)timeCounting{
    -- self.secondsCountDown ;
    if (self.secondsCountDown == 0) {
        if ([self.countdownTimer isValid]) {
            [self.countdownTimer invalidate];
            self.countdownTimer = nil;
        }
        
        _regetCodeButton.enabled = YES;
        self.codeAndTimeLabel.text = @"验证码";
    }else{
        int timeout =(int) self.secondsCountDown;
        int minutes = timeout / 60;
        int seconds = timeout % 60;
        NSString *strTime = [NSString stringWithFormat:@"验证码 (%d分%.2d秒)",minutes,seconds];
        
        self.codeAndTimeLabel.text=strTime;
    }
}

- (IBAction)registerToBeMember:(id)sender {
    
    if ([self.registerAudoNumber length]!=0)
    {
        
        
        
        if ([_registerAudoNumber isEqualToString:self.codeTextField.text])
        {
            //验证成功，插入数据表
            
            [self showLoadingView];
            
            [LoginEngine getAddUserWithPhoenumber:self.registerUserName password:self.registerPassword registerInvitationStr:self.codeTextField.text block:^(id result, NSError *error) {
                
                [self hideLoadingView];
                
                
                if (!error)
                {
                    
                    BDLog(@"************注册成功！");
                    
                    [self showMessage:@"注册成功！"];
                    
//                    self.timerFinishBlock(YES);
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.registerUserName forKey:@"loginUserName"];
                    [[NSUserDefaults standardUserDefaults] setObject:self.registerPassword forKey:@"loginPassWord"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    [(MainNavigationController *)self.navigationController pushContentViewControllerAnimated:YES];
                    
                    if ([BmobUser getCurrentUser])
                    {
                        [NoticeManager updatePushProfile];
                        [[NoticeManager sharedManager] bindDB];
                    }

                    //球队邀请码，将用户加入相应的球队
                    
                    if ([self.reg_code length]!=0)
                    {
                        
                        BmobQuery *query = [BmobQuery queryWithClassName:kTableTeam];
                        query.limit = 1;
                        [query whereKey:@"reg_code" equalTo:self.reg_code];
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
//                [self.navigationController popToRootViewControllerAnimated:YES];
                
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

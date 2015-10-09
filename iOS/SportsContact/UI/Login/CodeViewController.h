//
//  CodeViewController.h
//  SportsContact
//
//  Created by Bmob on 15-3-23.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^TimerFinishBlock)(BOOL isFinish);

@interface CodeViewController : BaseViewController{
//    int _secondsCountDown;
//    NSTimer *_countDownTimer;
    
//    NSString *_registerUserName;
//    NSString *_registerPassword;
//    NSString *_registerAudoNumber;
    
    //    int registerInvitationNumber;
    
}

@property (nonatomic, copy) TimerFinishBlock timerFinishBlock;

@property (copy, nonatomic) NSString *registerUserName;
@property (copy, nonatomic) NSString *registerPassword;
@property (copy, nonatomic) NSString *registerAudoNumber;
@property (copy, nonatomic) NSString *reg_code;

-(void)getTheAudoKey;
@end

//
//  NormalRegisterViewController.h
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


typedef void (^TimerFinishBlock)(BOOL isFinish);


@interface NormalRegisterViewController : BaseViewController<UITextFieldDelegate>
{
    int secondsCountDown;
    NSTimer *countDownTimer;
    
    NSString *registerUserName;
    NSString *registerPassword;
    NSString *registerAudoNumber;

//    int registerInvitationNumber;
    
}

@property (nonatomic, copy) TimerFinishBlock timerFinishBlock;



@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;


@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;


@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage2;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage1;


@property (weak, nonatomic) IBOutlet UIImageView *iconImage1;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage2;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage3;



@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

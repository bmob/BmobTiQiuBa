//
//  FindPasswordViewController.h
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


typedef void (^TimerFinishBlock)(BOOL isFinish);

@interface FindPasswordViewController : BaseViewController<UITextFieldDelegate>
{
    
    int secondsCountDown;
    NSTimer *countDownTimer;

    
    NSString *findAudoNumber;
    NSString *findUserName;
    NSString *findPassword;

    


    
    
    __weak IBOutlet UITextField *textField1;
    __weak IBOutlet UITextField *textField2;
    __weak IBOutlet UIButton *submitButton;
    
    
}

@property (nonatomic, copy) TimerFinishBlock timerFinishBlock;


@property (weak, nonatomic) IBOutlet UILabel *testLabel1;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *textBackground;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;



@end

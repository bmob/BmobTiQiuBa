//
//  LoginDetailViewController.h
//  SportsContact
//
//  Created by Nero on 7/15/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface LoginDetailViewController : BaseViewController<UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetpasswordButton;


@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;


@end

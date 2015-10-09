//
//  CreateLeagueViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-10.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "CreateLeagueViewController.h"
#import "Util.h"
#import "DataDef.h"
#import "NSObject+MGBlockPerformer.h"
#import "TeamEngine.h"

@interface CreateLeagueViewController () <UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *peopleTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupNumTextField;

@end

@implementation CreateLeagueViewController

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
    self.title = @"创建联赛";
    UIButton *backBtn = [self backbutton];
    [backBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"下一步" forState:UIControlStateNormal];
    rButton.frame = CGRectMake(0, 0, 66, 44);
    [rButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
    
    [self performSelector:@selector(getLeagueNumber) withObject:nil afterDelay:0.7f];
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
    if ([segue.identifier isEqualToString:@"push_next"]) {
        [segue.destinationViewController setValue:self.nameTextField.text forKey:@"name"];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.nameTextField)
    {
        [self.peopleTextField becomeFirstResponder];
    }else if (textField == self.peopleTextField)
    {
        [self.groupNumTextField becomeFirstResponder];
    }
    return YES;
}

#pragma mark  - Event handler

- (void)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



-(void)createLeague{
    BOOL isVerify = YES;
    NSMutableString *mssage = [[NSMutableString alloc] init];
    if (!self.nameTextField.text || [self.nameTextField.text isEqualToString:@""]) {
        isVerify = NO;
        [mssage appendString:@"联赛名称不能为空 "];
    }
    if (!self.peopleTextField.text || [self.nameTextField.text isEqualToString:@""]) {
        isVerify = NO;
        [mssage appendString:@"上场人数不能为空 "];
    }
    
    if (!self.groupNumTextField.text || [self.groupNumTextField.text isEqualToString:@""]) {
        isVerify = NO;
        [mssage appendString:@"小组数量不能为空 "];
    }
    
    if (isVerify) {
        BmobObject *league = [BmobObject objectWithClassName:kTableLeague];
        [league setObject:self.nameTextField.text forKey:@"name"];
        [league setObject:[NSNumber numberWithInteger:self.peopleTextField.text.integerValue]  forKey:@"people"];
        [league setObject:[NSNumber numberWithInteger:self.groupNumTextField.text.integerValue] forKey:@"group_count"];
        
        [league setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:[BmobUser getCurrentUser].objectId] forKey:@"master"];
        [league saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
         {
             if (isSuccessful) {
                 [self showMessage:@"成功创建联赛"];
                 [self performRunnable:^{
                     [self performSegueWithIdentifier:@"push_next" sender:nil];
                 } afterDelay:1.5f];
                 //生成联赛邀请码
                 [BmobCloud callFunctionInBackground:@"leagueInviteCode" withParameters:@{@"leagueId":league.objectId} block:nil];
             }else
             {
                 [self showMessage:[Util errorStringWithCode:error.code]];
             }
         }];
    }else{
        [self showMessageText:mssage];
    }
    
}

-(void)getLeagueNumber{
    [TeamEngine getLeagueGamesNumberWithUserID:[BmobUser getCurrentUser].objectId
                                         block:^(NSInteger count, NSError *error) {
                                             if (error) {
                                                 
                                             }else{
                                                 if (count >= 1) {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                         message:@"您已创建过联赛，再次创建联赛将失去上一个联赛管理权限，是否继续？"
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"取消"
                                                                                               otherButtonTitles:@"确定", nil];
                                                     [alertView show];
                                                 }
                                             }
                                             
                                         }];
}

- (void)onNext:(id)sender
{
    [self createLeague];
}

#pragma mark - alertview

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == [alertView cancelButtonIndex]) {
//        return;
//    }
    switch (buttonIndex) {
        case 0:{
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
            
            break;
        case 1:
            break;
        default:
            break;
    }
}

@end

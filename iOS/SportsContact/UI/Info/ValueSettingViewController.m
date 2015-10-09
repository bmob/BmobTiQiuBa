//
//  ValueSettingViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-20.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "ValueSettingViewController.h"
#import "Util.h"

@interface ValueSettingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSString *value;
@property (weak, nonatomic) IBOutlet UITextField *textField;




@end

@implementation ValueSettingViewController
//@synthesize wordLimit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.textField];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.text = self.value;
    self.title = self.title;
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"保存" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
    
    
    if ([self.title isEqualToString:@"昵称"]) {
        self.wordLimit = 8;
    }
    
    
    //监听文字输入,限制字符串输入
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)textFiledEditChanged:(NSNotification *)obj
{
//    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = self.textField.text;
    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"])
    {
        // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self.textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        
        if (!position)
        {
            if (toBeString.length > self.wordLimit)
            {
                self.textField.text = [toBeString substringToIndex:self.wordLimit];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > self.wordLimit)
        {
            self.textField.text = [toBeString substringToIndex:self.wordLimit];
        }
    }
}




- (void)onSave:(id)sender
{
    BDLog(@"***********%@",self.textField.text);
    
    
    //球队，队名不能为空，注册码，简介可以为空
    
    if ([self.title isEqualToString:@"联赛注册码"] || [self.title isEqualToString:@"简介"])
    {
        
        
        if ([self.delegate respondsToSelector:@selector(valueSetting:didSaveValue:)])
        {
            [self.delegate valueSetting:self didSaveValue:self.textField.text];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        

        
    }
    else
    {
        
        if ([self.textField.text length]==0)
        {
            [self showMessage:[NSString stringWithFormat:@"%@不能为空", self.title]];
            return ;
        }
        else
        {
            
            if ([self.delegate respondsToSelector:@selector(valueSetting:didSaveValue:)])
            {
                [self.delegate valueSetting:self didSaveValue:self.textField.text];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }

        
    }
    
    
    
    
    
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.textField.text length]==0)
    {
        [self showMessage:[NSString stringWithFormat:@"%@不能为空", self.title]];
        return YES;
    }
    else
    {
        
        if ([self.delegate respondsToSelector:@selector(valueSetting:didSaveValue:)]) {
            [self.delegate valueSetting:self didSaveValue:self.textField.text];
        }
        [self.navigationController popViewControllerAnimated:YES];
        return YES;

        
    }
}






@end

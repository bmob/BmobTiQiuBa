//
//  CreateMatchViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "CreateMatchViewController.h"
#import "DataDef.h"
#import "LocationInfoManager.h"
#import "DateUtil.h"
#import "Util.h"
#import "ViewUtil.h"

@interface CreateMatchViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *popToolView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;

@property (nonatomic, weak) IBOutlet UITextField *dateTextField;
@property (nonatomic, weak) IBOutlet UITextField *timeTextField;
@property (nonatomic, weak) IBOutlet UITextField *cityTextField;
@property (nonatomic, weak) IBOutlet UITextField *addressTextField;
@property (nonatomic, weak) UITextField *settingTextField;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) LocationInfo *locInfo;
@property (nonatomic, strong) LocationInfo *tempLocInfo;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;

@property (nonatomic, strong) Tournament *match;

@end

@implementation CreateMatchViewController

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
    self.title = @"添加比赛记录";
    UIButton *backBtn = [self backbutton];
    [backBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    self.provinces = [[LocationInfoManager sharedManager] provinceArray];
    
    self.tempLocInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[[[BmobUser getCurrentUser] objectForKey:@"city"] integerValue]]];
    if (self.tempLocInfo)
    {
        self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:self.tempLocInfo.provinceName];
    }else
    {
        self.tempLocInfo = [[LocationInfo alloc] init];
        self.tempLocInfo.provinceName = [self.provinces firstObject];
        self.tempLocInfo.cityName = [self.cities firstObject];
        self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:[self.provinces firstObject]];
    }
    
   
    // Do any additional setup after loading the view.
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"下一步" forState:UIControlStateNormal];
    rButton.frame = CGRectMake(0, 0, 66, 44);
    [rButton addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    
    UIView *toolBgView = [self.popToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolBgView target:self action:@selector(hidePopToolView)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard
{
    [self.addressTextField resignFirstResponder];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    self.dateTextField.text = [DateUtil formatedValidityDate:date];
}

- (void)setTime:(NSDate *)time
{
    _time= time;
    self.timeTextField.text = [DateUtil formatedDate:time byDateFormat:@"HH:mm"];
}


- (void)setLocInfo:(LocationInfo *)locInfo
{
    _locInfo = locInfo;
    self.cityTextField.text = locInfo.cityName;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"push_home_team"]) {
        [segue.destinationViewController setValue:self.match forKey:@"match"];
    }
}


#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return YES;
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.provinces count];
            break;
        case 1:
            return [self.cities count];
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.provinces objectAtIndex:row];
            break;
        case 1:
            return [self.cities objectAtIndex:row];
            break;
            
        default:
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
        {
            self.tempLocInfo.provinceName = [_provinces objectAtIndex:row];
            _cities = [[LocationInfoManager sharedManager] cityArrayInProvince:self.tempLocInfo.provinceName];
            [pickerView reloadComponent:1];
            if (_cities && _cities.count>0) {
                self.tempLocInfo.cityName = [_cities objectAtIndex:0];
                [pickerView selectRow:0 inComponent:1 animated:NO];
            }else{
                self.tempLocInfo.cityName = nil;
            }
            
        }
            break;
        case 1:
        {
            if (_cities && _cities.count > row)
            {
                self.tempLocInfo.cityName = [_cities objectAtIndex:row];
                
            }else{
                self.tempLocInfo.cityName = nil;
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Event handler

- (void)onNext:(id)sender
{
    BOOL isVerify = YES;
    NSMutableString *mssage = [[NSMutableString alloc] init];
    if (!self.date) {
        isVerify = NO;
        [mssage appendString:@"比赛日期不能为空 "];
    }
    if (!self.time) {
        isVerify = NO;
        [mssage appendString:@"开始时间不能为空 "];
    }
    
    if (!self.addressTextField.text || [self.addressTextField.text isEqualToString:@""] ) {
        isVerify = NO;
        [mssage appendString:@"比赛地点不能为空 "];
    }
    
    if (!self.locInfo) {
        isVerify = NO;
        [mssage appendString:@"比赛城市不能为空 "];
    }
    if (!isVerify) {
        [self showMessage:mssage];
        return ;
    }
    
    Tournament *match = [[Tournament alloc] init];
    NSString *dateString = [NSString stringWithFormat:@"%@-%@:00", [DateUtil formatedDate:self.date byDateFormat:@"yyyy-MM-dd"], [DateUtil formatedDate:self.time byDateFormat:@"HH:mm"]];
    match.event_date = self.date;
    match.start_time = [DateUtil formatedString:dateString byDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    match.end_time = [match.start_time dateByAddingHours:2];
    match.site = self.addressTextField.text;
    match.city  = [NSString stringWithFormat:@"%@", self.locInfo.cityCode];
    self.match = match;
    [self performSegueWithIdentifier:@"push_home_team" sender:nil];
}

- (void)onClose:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onEditDate:(id)sender {
    self.datePicker.hidden  = NO;
    self.valuePicker.hidden  = YES;
    self.settingTextField = self.dateTextField;
    [self hideKeyboard];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    if(self.date)
    {
        self.datePicker.date = self.date;
    }
    [self showPopToolView];
}

- (IBAction)onEditTime:(id)sender {
    self.datePicker.hidden  = NO;
    self.valuePicker.hidden  = YES;
    self.settingTextField = self.timeTextField;
    [self hideKeyboard];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    if(self.time)
    {
        self.datePicker.date = self.time;
    }
    [self showPopToolView];
}

- (IBAction)onEditCity:(id)sender {
    self.datePicker.hidden  = YES;
    self.valuePicker.hidden  = NO;
    self.settingTextField = self.cityTextField;
    [self.valuePicker reloadAllComponents];
    
    if (self.tempLocInfo) {
        if ( self.tempLocInfo.provinceName && [self.provinces indexOfObject:self.tempLocInfo.provinceName] != NSNotFound)
        {
            [self.valuePicker  selectRow:[self.provinces indexOfObject:self.tempLocInfo.provinceName] inComponent:0 animated:NO];
            self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:self.tempLocInfo.provinceName];
            [self.valuePicker reloadComponent:1];
            if (self.tempLocInfo.cityName && [self.cities indexOfObject:self.tempLocInfo.cityName] != NSNotFound)
            {
                [self.valuePicker  selectRow:[self.cities indexOfObject:self.tempLocInfo.cityName] inComponent:1 animated:NO];
            }
        }
    }
    
    [self hideKeyboard];
    [self showPopToolView];
}

- (IBAction)onPickerSure:(id)sender {
    [self hidePopToolView];
    if (self.settingTextField == self.dateTextField)
    {
        self.date = self.datePicker.date;
    }else if (self.settingTextField == self.timeTextField)
    {
        self.time = self.datePicker.date;
    }else if (self.settingTextField == self.cityTextField)
    {
        self.locInfo = [[LocationInfoManager sharedManager] locationInfoOfProvinceName:self.tempLocInfo.provinceName cityName:self.tempLocInfo.cityName districtName:nil];
    }
}
- (IBAction)onPickerCancel:(id)sender {
    [self hidePopToolView];
}

- (void)showPopToolView
{
    self.popToolView.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.popToolView];
    self.popToolView.hidden = NO;
    UIView *bgView = [self.popToolView viewWithTag:0xF0];
    UIView *toolView = [self.popToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popToolView.frame.size.height - frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0.3;
    } completion:nil];
}

- (void)hidePopToolView
{
    UIView *bgView = [self.popToolView viewWithTag:0xF0];
    UIView *toolView = [self.popToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popToolView.frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.popToolView.hidden = YES;
        [self.popToolView removeFromSuperview];
    }];
}

@end

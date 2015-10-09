//
//  UserSettingViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-18.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "UserSettingViewController.h"
#import <BmobSDK/Bmob.h>
#import <UIImageView+WebCache.h>
#import "DataDef.h"
#import "DateUtil.h"
#import "ViewUtil.h"
#import "LocationInfoManager.h"
#import "Util.h"
#import "InfoEngine.h"
#import "DateUtil.h"

@interface UserSettingViewController ()

@property (nonatomic,strong) UserInfo *userInfo;

@property (nonatomic, strong) NSArray *uiitems;
@property (nonatomic, strong) NSArray *itemKeys;
@property (strong, nonatomic) IBOutlet UIView *popToolView;
@property (strong, nonatomic) IBOutlet UIView *popImageToolView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;
@property (nonatomic, strong) NSMutableDictionary *changes;

@property (nonatomic, strong) NSString *settingKey;

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSArray *districts;
@property (nonatomic, strong) LocationInfo *locationInfo;
@property (nonatomic) NSInteger pickerRow;

@property (nonatomic, strong) NSArray *selectionDataSource;
@property (nonatomic, strong) NSArray *selectionDataValue;

@property (nonatomic, strong) UIImage *avatarImage;

//@property (nonatomic) BOOL isPickerSetting;

@end

@implementation UserSettingViewController

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
    
    self.title = [[BmobUser getCurrentUser] objectForKey:@"nickname"];
    
    self.uiitems = [NSArray arrayWithObjects:@"1",@"账号",@"昵称",@"修改密码",@"0",@"生日",@"场上位置",@"擅长脚",@"0",@"身高",@"体重",@"城市",@"0", nil];
    self.itemKeys = [NSArray arrayWithObjects:@"avatar",@"username",@"nickname", @"password", @"0", @"birthday",@"midfielder" ,@"be_good",@"0", @"stature", @"weight", @"city", @"0", nil];
//    UITabBarController *vc;
    
    self.provinces = [[LocationInfoManager sharedManager] provinceArray];
    self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:[self.provinces firstObject]];
     self.districts = [[LocationInfoManager sharedManager] districtArrayInProvince:[self.provinces firstObject] city:[self.cities firstObject]];
    self.locationInfo = [[LocationInfo alloc] init];
//    self.isPickerSetting = NO;
    
    UIView *toolBgView = [self.popToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolBgView target:self action:@selector(hidePopToolView)];
    
    
    UIView *imageToolBgView = [self.popImageToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:imageToolBgView target:self action:@selector(hidePopImageToolView)];
    UIView *imageToolContentView = [self.popImageToolView viewWithTag:0xF1];
    for (UIView *view in imageToolContentView.subviews)
    {
        view.layer.cornerRadius = 4.0f;
    }
    
    self.changes = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!self.userInfo.stature) {
        [self.changes setObject:[NSNumber numberWithInteger:170] forKey:@"stature"];
    }
    if (!self.userInfo.birthday) {
        NSDate *date = [DateUtil formatedString:@"1990-01-01" byDateFormat:@"yyyy-MM-dd"];
        [self.changes setObject:date forKey:@"birthday"];
    }
    if (!([self.userInfo.city integerValue] > 0)) {
        [self.changes setObject:@"440103" forKey:@"city"];
    }
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"保存" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    
//    LocationInfo *info = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:341621]];
//    BDLog(@"Info %@", info);
//    341,621
//    [self hideTabBar];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hidePopToolView];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)saveChangesToBackground
{
    [self showLoadingView];
    [InfoEngine updateUserInfoWithUser:[BmobUser getCurrentUser] avatarImage:self.avatarImage changes:self.changes block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             [self showMessage:@"成功保存"];
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverUserInfoChanged object:nil];
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *itemKey = self.settingKey;
    
    if ([segue.identifier isEqualToString:@"push_selection"]) {
        [segue.destinationViewController setValue:self.selectionDataSource forKey:@"dataSource"];
        [segue.destinationViewController setValue:self  forKey:@"delegate"];
        
        if ([itemKey isEqualToString:@"midfielder"])
        {
            NSNumber *midfielder = self.userInfo.midfielder;
            if ([self.changes objectForKey:@"midfielder"]) {
                midfielder = [self.changes objectForKey:@"midfielder"];
            }
            NSInteger index = NSNotFound;
            if (midfielder)
            {
                index = [self.selectionDataValue indexOfObject:[NSNumber numberWithInteger:midfielder.integerValue]];
            }
            
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:index]  forKey:@"selectIndex"];
            [segue.destinationViewController setTitle:@"场上位置"];
        }else if ([itemKey isEqualToString:@"be_good"])
        {
            NSNumber *be_good = self.userInfo.be_good;
            if ([self.changes objectForKey:@"be_good"]) {
                be_good = [self.changes objectForKey:@"be_good"];
            }
            NSInteger index = NSNotFound;
            if (be_good)
            {
                index = [self.selectionDataValue indexOfObject:[NSNumber numberWithInteger:be_good.integerValue]];
            }
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:index]  forKey:@"selectIndex"];
            [segue.destinationViewController setTitle:@"擅长脚"];
            
        }
    }
    else if ([segue.identifier isEqualToString:@"push_value"])
    {
        [segue.destinationViewController setValue:self  forKey:@"delegate"];
        NSString *value = [self.userInfo valueForKey:itemKey];
        
        if ([itemKey isEqualToString:@"nickname"]) {
            [segue.destinationViewController setValue:@"昵称" forKey:@"title"];
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:20] forKey:@"wordLimit"];
        }
        if ([self.changes objectForKey:itemKey]) {
            value = [self.changes objectForKey:itemKey];
            
        }
        if (value) {
            [segue.destinationViewController setValue:value forKey:@"value"];
        }
        
        
    }
    else if ([segue.identifier isEqualToString:@"push_updatePassWord"])
    {
        
        
    }
    else
    {
        
    }
    
    
    
    
    
    
    
    
}


#pragma mark - Private method

- (void)showPopToolView
{
    self.popToolView.frame = self.tabBarController.view.bounds;
     [self.tabBarController.view addSubview:self.popToolView];
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


- (void)showPopImageToolView
{
    self.popImageToolView.frame = self.tabBarController.view.bounds;
    [self.tabBarController.view addSubview:self.popImageToolView];
    self.popImageToolView.hidden = NO;
    UIView *bgView = [self.popImageToolView viewWithTag:0xF0];
    UIView *toolView = [self.popImageToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popImageToolView.frame.size.height - frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0.3;
    } completion:nil];
}

- (void)hidePopImageToolView
{
    UIView *bgView = [self.popImageToolView viewWithTag:0xF0];
    UIView *toolView = [self.popImageToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popImageToolView.frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.popImageToolView.hidden = YES;
        [self.popImageToolView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *itemKey = [self.itemKeys objectAtIndex:indexPath.row];
    self.settingKey = itemKey;
    
    
//    push_value
    if ([itemKey isEqualToString:@"nickname"]) {
        [self performSegueWithIdentifier:@"push_value" sender:nil];
    }
    else if ([itemKey isEqualToString:@"password"])
    {
        [self performSegueWithIdentifier:@"push_updatePassWord" sender:nil];
    }
    else if ([itemKey isEqualToString:@"birthday"])
    {
        self.datePicker.hidden = NO;
        self.valuePicker.hidden = YES;
        NSDate *birthday = self.userInfo.birthday;
        if ([self.changes objectForKey:@"birthday"]) {
            birthday = [self.changes objectForKey:@"birthday"];
        }
        if (birthday) {
            self.datePicker.date = birthday;
        }
        [self showPopToolView];
    }else if ([itemKey isEqualToString:@"midfielder"])
    {
        self.selectionDataSource = [NSArray arrayWithObjects:
                                    positioningTypeStringFromEnum(PositioningTypeGoalkeeper), positioningTypeStringFromEnum(PositioningTypeBack) , positioningTypeStringFromEnum(PositioningTypeMidfielder) ,positioningTypeStringFromEnum(PositioningTypeForward ) ,nil];
        self.selectionDataValue =[NSArray arrayWithObjects:
                                  [NSNumber numberWithInteger:PositioningTypeGoalkeeper], [NSNumber numberWithInteger:PositioningTypeBack] , [NSNumber numberWithInteger:PositioningTypeMidfielder ] ,[NSNumber numberWithInteger:PositioningTypeForward] ,nil];
        [self performSegueWithIdentifier:@"push_selection" sender:nil];
        
    }else if ([itemKey isEqualToString:@"be_good"])
    {
        self.selectionDataSource = [NSArray arrayWithObjects:
                                    begoodTypeStringFromEnum(BegoodTypeAll), begoodTypeStringFromEnum(BegoodTypeLeft) , begoodTypeStringFromEnum(BegoodTypeRight),nil];
        self.selectionDataValue =[NSArray arrayWithObjects:
                                  [NSNumber numberWithInteger:BegoodTypeAll], [NSNumber numberWithInteger:BegoodTypeLeft] , [NSNumber numberWithInteger:BegoodTypeRight] ,nil];
        [self performSegueWithIdentifier:@"push_selection" sender:nil];
    }else if ([itemKey isEqualToString:@"stature"])
    {
        self.datePicker.hidden = YES;
        self.valuePicker.hidden = NO;
        [self.valuePicker reloadAllComponents];
        self.pickerRow = 0;
        NSNumber *stature = self.userInfo.stature;
        if ([self.changes objectForKey:@"stature"]) {
            stature = [self.changes objectForKey:@"stature"];
        }
        if (stature)
        {
            if (stature.integerValue - 100 > 0 && stature.integerValue - 100 < [self.valuePicker numberOfRowsInComponent:0]) {
                self.pickerRow = stature.integerValue - 100;
            }
        }
        else
        {
            //默认身高170cm
            self.pickerRow = 170 - 100;
        }
        
        [self.valuePicker selectRow:self.pickerRow inComponent:0 animated:NO];
        [self showPopToolView];
        
    }else if ([itemKey isEqualToString:@"weight"])
    {
        self.datePicker.hidden = YES;
        self.valuePicker.hidden = NO;
        [self.valuePicker reloadAllComponents];
        self.pickerRow  = 0;
        NSNumber *weight = self.userInfo.weight;
        if ([self.changes objectForKey:@"weight"]) {
            weight = [self.changes objectForKey:@"weight"];
        }
        if (weight)
        {
            if (weight.integerValue - 35 > 0 && weight.integerValue - 35 < [self.valuePicker numberOfRowsInComponent:0]) {
                self.pickerRow = weight.integerValue - 35;
            }
        }
        else
        {
            //默认60KG体重
            self.pickerRow = 60 - 35;
        }
        
        [self.valuePicker selectRow:self.pickerRow inComponent:0 animated:NO];
        [self showPopToolView];
    }else if ([itemKey isEqualToString:@"city"])
    {
        self.datePicker.hidden = YES;
        self.valuePicker.hidden = NO;
        [self.valuePicker reloadAllComponents];
        NSString *cityCode = self.userInfo.city;
        
        if ([self.changes objectForKey:@"city"]) {
            cityCode = [self.changes objectForKey:@"city"];
        }
        
        if (cityCode) {
            
            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
            self.locationInfo = locInfo;
            if ( locInfo.provinceName && [self.provinces indexOfObject:locInfo.provinceName] != NSNotFound) {
                [self.valuePicker  selectRow:[self.provinces indexOfObject:locInfo.provinceName] inComponent:0 animated:NO];
                self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:locInfo.provinceName];
                [self.valuePicker reloadComponent:1];
                if (locInfo.cityName && [self.cities indexOfObject:locInfo.cityName] != NSNotFound)
                {
                     [self.valuePicker  selectRow:[self.cities indexOfObject:locInfo.cityName] inComponent:1 animated:NO];
                    self.districts = [[LocationInfoManager sharedManager] districtArrayInProvince:locInfo.provinceName city:locInfo.cityName];
                    [self.valuePicker reloadComponent:2];
                    if (locInfo.districtName && [self.districts indexOfObject:locInfo.districtName] != NSNotFound)
                    {
                        [self.valuePicker  selectRow:[self.districts indexOfObject:locInfo.districtName] inComponent:2 animated:NO];
                    }
                }
               
            }
        }
        else
        {
            
            
            //默认广东省、广州市、越秀区
            NSString *cityCode = @"440103";

            
            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
            self.locationInfo = locInfo;
            if ( locInfo.provinceName && [self.provinces indexOfObject:locInfo.provinceName] != NSNotFound) {
                [self.valuePicker  selectRow:[self.provinces indexOfObject:locInfo.provinceName] inComponent:0 animated:NO];
                self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:locInfo.provinceName];
                [self.valuePicker reloadComponent:1];
                if (locInfo.cityName && [self.cities indexOfObject:locInfo.cityName] != NSNotFound)
                {
                    [self.valuePicker  selectRow:[self.cities indexOfObject:locInfo.cityName] inComponent:1 animated:NO];
                    self.districts = [[LocationInfoManager sharedManager] districtArrayInProvince:locInfo.provinceName city:locInfo.cityName];
                    [self.valuePicker reloadComponent:2];
                    if (locInfo.districtName && [self.districts indexOfObject:locInfo.districtName] != NSNotFound)
                    {
                        [self.valuePicker  selectRow:[self.districts indexOfObject:locInfo.districtName] inComponent:2 animated:NO];
                    }
                }
                
            }
        }
        
        
        
        
        [self showPopToolView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.uiitems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString *uiitem = [self.uiitems objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
       return 166;
    }else if([uiitem isEqualToString:@"0"])
    {
        return 32;
    }else
    {
        return 43;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    NSString *uiitem = [self.uiitems objectAtIndex:indexPath.row];
    NSString *itemKey = [self.itemKeys objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"head_cell"];
        UIImageView *avatarView = (id)[cell.contentView viewWithTag:0xF0];
        
        if (self.avatarImage)
        {
            avatarView.image = self.avatarImage;
        }else
        {
            [avatarView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avator.url] completed:nil];
        }
        
        if ([avatarView.gestureRecognizers count] == 0)
        {
            [ViewUtil addSingleTapGestureForView:avatarView target:self action:@selector(onEditAvatar:)];
        }
        [avatarView.layer setCornerRadius:avatarView.bounds.size.width/2.0f];
        
        
    }else if([uiitem isEqualToString:@"0"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"space_cell"];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"content_cell"];
        if(indexPath.row > 0 && indexPath.row < self.uiitems.count)
        {
             UIImageView *line = (id)[cell.contentView viewWithTag:0xF0];
    
            line.hidden =  [[self.uiitems objectAtIndex:indexPath.row + 1] isEqualToString:@"0"];
        }
        
        UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
        itemLabel.text = uiitem;
        
        UILabel *itemValueLabel = (id)[cell.contentView viewWithTag:0xF2];
        if ([itemKey isEqualToString:@"password"])
        {
            itemValueLabel.text = @"*****";
            
        }else if ([itemKey isEqualToString:@"birthday"])
        {
            NSDate *birthday = self.userInfo.birthday;
            if ([self.changes objectForKey:@"birthday"]) {
                birthday = [self.changes objectForKey:@"birthday"];
            }
            if (birthday)
            {
                 itemValueLabel.text = [DateUtil formatedDate:birthday bySeparate:@"/"];
            }else
            {
                itemValueLabel.text = @"暂无";
            }
          
        }else if ([itemKey isEqualToString:@"midfielder"])
        {
            NSNumber *midfielder = self.userInfo.midfielder;
            if ([self.changes objectForKey:@"midfielder"]) {
                midfielder = [self.changes objectForKey:@"midfielder"];
            }
            if (midfielder)
            {
                itemValueLabel.text = positioningTypeStringFromEnum(midfielder.integerValue);
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }else if ([itemKey isEqualToString:@"be_good"])
        {
            NSNumber *be_good = self.userInfo.be_good;
            if ([self.changes objectForKey:@"be_good"]) {
                be_good = [self.changes objectForKey:@"be_good"];
            }
            if (be_good)
            {
                itemValueLabel.text = begoodTypeStringFromEnum(be_good.integerValue);
            }else
            {
                itemValueLabel.text = @"暂无";
            }
           
        }else if ([itemKey isEqualToString:@"stature"])
        {
            
            NSNumber *stature = self.userInfo.stature;
            if ([self.changes objectForKey:@"stature"]) {
                stature = [self.changes objectForKey:@"stature"];
            }
            if (stature)
            {
                itemValueLabel.text = [NSString stringWithFormat:@"%@cm", stature];
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }else if ([itemKey isEqualToString:@"weight"])
        {
            NSNumber *weight = self.userInfo.weight;
            if ([self.changes objectForKey:@"weight"]) {
                weight = [self.changes objectForKey:@"weight"];
            }
            if (weight)
            {
                itemValueLabel.text = [NSString stringWithFormat:@"%@kg", weight];
                
            }else
            {
                itemValueLabel.text = @"暂无";
            }
        }else if ([itemKey isEqualToString:@"city"])
        {
            NSString *cityCode = self.userInfo.city;
            if ([self.changes objectForKey:@"city"]) {
                cityCode = [self.changes objectForKey:@"city"];
            }
            if (cityCode) {
                LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
                itemValueLabel.text = [NSString stringWithFormat:@"%@ %@", locInfo.cityName, locInfo.districtName];
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }else
        {
            NSString *value = [self.userInfo valueForKey:itemKey];
            if ([self.changes objectForKey:itemKey]) {
                value = [self.changes objectForKey:itemKey];
            }
            if (value)
            {
                 itemValueLabel.text = value;
            }else
            {
                itemValueLabel.text = @"暂无";
            }
           
        }
    }
    
//    cell.
    return cell;
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"stature"])
    {
        return 1;
        
    }else if ([itemKey isEqualToString:@"weight"])
    {
        return 1;
    }else if ([itemKey isEqualToString:@"city"])
    {
        return 3;
    }else
    {
        return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"stature"])
    {
        return 131;
        
    }else if ([itemKey isEqualToString:@"weight"])
    {
        return 166;
    }else if ([itemKey isEqualToString:@"city"])
    {
        switch (component) {
            case 0:
                return [self.provinces count];
                break;
            case 1:
                return  [self.cities count];
                break;
            case 2:
                return [self.districts count];
                break;
                
            default:
                 return 0;
                break;
        }
       
    }else
    {
        return 0;
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"stature"])
    {
        return [NSString stringWithFormat:@"%dcm",(int) (100 + row)];
        
    }else if ([itemKey isEqualToString:@"weight"])
    {
        return [NSString stringWithFormat:@"%dkg", (int)(35 + row)];
    }else if ([itemKey isEqualToString:@"city"])
    {
        switch (component) {
            case 0:
                return [self.provinces objectAtIndex:row];
                break;
            case 1:
                return  [self.cities objectAtIndex:row];
                break;
            case 2:
                return [self.districts objectAtIndex:row];
                break;
                
            default:
                return @"";
                break;
        }
    }else
    {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"city"])
    {
        switch (component) {
            case 0:
            {
                self.locationInfo.provinceName = [_provinces objectAtIndex:row];
                _cities = [[LocationInfoManager sharedManager] cityArrayInProvince:self.locationInfo.provinceName];
                [pickerView reloadComponent:1];
                if (_cities && _cities.count>0) {
                    self.locationInfo.cityName = [_cities objectAtIndex:0];
                    [pickerView selectRow:0 inComponent:1 animated:NO];
                }else{
                    self.locationInfo.cityName = nil;
                }
                
                _districts = [[LocationInfoManager sharedManager] districtArrayInProvince:self.locationInfo.provinceName city:self.locationInfo.cityName];
                [pickerView reloadComponent:2];
                if (_districts && _districts.count>0) {
                    self.locationInfo.districtName = [_districts objectAtIndex:0];
                    [pickerView selectRow:0 inComponent:2 animated:NO];
                }else{
                    self.locationInfo.districtName = nil;
                }
            }
                break;
            case 1:
            {
                if (_cities && _cities.count>row) {
                    self.locationInfo.cityName = [_cities objectAtIndex:row];
                    _districts = [[LocationInfoManager sharedManager] districtArrayInProvince:self.locationInfo.provinceName city:self.locationInfo.cityName];
                    [pickerView reloadComponent:2];
                    if (_districts && _districts.count>0) {
                        self.locationInfo.districtName = [_districts objectAtIndex:0];
                        [pickerView selectRow:0 inComponent:2 animated:NO];
                    }
                }else{
                    self.locationInfo.cityName = nil;
                    _districts = nil;
                    [pickerView selectRow:0 inComponent:2 animated:NO];
                }
            }
                break;
            case 2:
            {
                if (_districts && _districts.count>row) {
                    self.locationInfo.districtName = [_districts objectAtIndex:row];
                }else{
                    self.locationInfo.districtName = nil;
                }
            }
                break;
                
            default:
                ;
                break;
        }
    }
    else
    {
        self.pickerRow = row;
    }
}

#pragma mark - ValueSelectionDelegate

- (void)valueSelection:(id)valueSelection didSaveAtIndex:(NSInteger)index
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"midfielder"])
    {
        if (self.userInfo.midfielder)
        {
            if (self.userInfo.midfielder.integerValue == [[self.selectionDataValue objectAtIndex:index] integerValue])
            {
                [self.changes removeObjectForKey:@"midfielder"];
            }else
            {
                [self.changes setObject:[self.selectionDataValue objectAtIndex:index] forKey:@"midfielder"];
            }
        }else
        {
            [self.changes setObject:[self.selectionDataValue objectAtIndex:index] forKey:@"midfielder"];
        }
    }else if ([itemKey isEqualToString:@"be_good"])
    {
        if (self.userInfo.be_good)
        {
            if (self.userInfo.be_good.integerValue == [[self.selectionDataValue objectAtIndex:index] integerValue])
            {
                [self.changes removeObjectForKey:@"be_good"];
            }else
            {
                [self.changes setObject:[self.selectionDataValue objectAtIndex:index] forKey:@"be_good"];
            }
        }else
        {
            [self.changes setObject:[self.selectionDataValue objectAtIndex:index] forKey:@"be_good"];
        }
        
    }
    NSInteger reloadIndex = [self.itemKeys indexOfObject:itemKey];
    if (reloadIndex != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - ValueSettingDelegate
- (void)valueSetting:(id)valueSelection didSaveValue:(NSString *)value
{
    NSString *itemKey = self.settingKey;
    if ([itemKey isEqualToString:@"nickname"])
    {
        if (self.userInfo.nickname)
        {
            if ([self.userInfo.nickname  isEqualToString:value])
            {
                [self.changes removeObjectForKey:@"nickname"];
            }else
            {
                [self.changes setObject:value forKey:@"nickname"];
            }
        }else
        {
            [self.changes setObject:value forKey:@"nickname"];
        }
    }
    else if ([itemKey isEqualToString:@"password"])
    {
        //修改密码
        
        
    }
    else
    {
        
    }

    
    
    NSInteger reloadIndex = [self.itemKeys indexOfObject:itemKey];
    if (reloadIndex != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.avatarImage  = image;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Event handler

- (void)onEditAvatar:(id)sender
{
    [self showPopImageToolView];
}
- (IBAction)onEditAvatarCancel:(id)sender
{
    [self hidePopImageToolView];
}
- (IBAction)onEditAvatarCamera:(id)sender
{
    [self hidePopImageToolView];
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        BDLog(@"没有摄像头");
        return ;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    // 编辑模式
    imagePicker.allowsEditing = YES;
    [self  presentViewController:imagePicker animated:YES completion:nil];
}
- (IBAction)onEditAvatarAlbum:(id)sender
{
    [self hidePopImageToolView];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    // 编辑模式
    imagePicker.allowsEditing = YES;
    [self  presentViewController:imagePicker animated:YES completion:nil];
}

- (void)onSave:(id)sender
{
    [self showLoadingView];
    NSString *changeNickname = [self.changes objectForKey:@"nickname"];
    if (changeNickname) {
        [InfoEngine getInfoWithNickname:changeNickname block:^(id result, NSError *error) {
            [self hideLoadingView];
            if(error)
            {
                [self showMessage:[NSString stringWithFormat:@"错误码:%ld", (long)error.code]];
                return ;
            }
            if (result) {
                [self showMessage:@"保存失败，昵称已经存在"];
            }else
            {
                [self saveChangesToBackground];
            }
        }];
    }else
    {
        [self saveChangesToBackground];
    }
   
   
}

- (IBAction)onPickerSure:(id)sender {
    NSString *itemKey = self.settingKey;
    [self hidePopToolView];
    if ([itemKey isEqualToString:@"birthday"])
    {
        if (self.datePicker.date)
        {
            [self.changes setObject:self.datePicker.date forKey:itemKey];
        }
        
    }else if ([itemKey isEqualToString:@"stature"])
    {
        if (self.userInfo.stature) {
            if (self.pickerRow + 100 ==  [self.userInfo.stature integerValue])
            {
                [self.changes removeObjectForKey:itemKey];
            }else
            {
                [self.changes setObject:[NSNumber numberWithInteger:self.pickerRow + 100] forKey:itemKey];
            }
        }else
        {
             [self.changes setObject:[NSNumber numberWithInteger:self.pickerRow + 100] forKey:itemKey];
        }
        
    }else if ([itemKey isEqualToString:@"weight"])
    {
        if (self.userInfo.weight)
        {
            if (self.pickerRow + 35 ==  [self.userInfo.weight integerValue])
            {
                [self.changes removeObjectForKey:itemKey];
            }else
            {
                 [self.changes setObject:[NSNumber numberWithInteger:self.pickerRow + 35] forKey:itemKey];
            }
        }else
        {
            [self.changes setObject:[NSNumber numberWithInteger:self.pickerRow + 35] forKey:itemKey];
        }
        
        
    }else if ([itemKey isEqualToString:@"city"])
    {
        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfProvinceName:self.locationInfo.provinceName cityName:self.locationInfo.cityName districtName:self.locationInfo.districtName];
        if (locInfo && locInfo.districtCode.integerValue > 0)
        {
            if ([self.userInfo.city integerValue] == locInfo.districtCode.integerValue)
            {
                [self.changes removeObjectForKey:itemKey];
            }else
            {
                [self.changes setObject:[NSString stringWithFormat:@"%@", locInfo.districtCode] forKey:itemKey];
                
                
//                if ([locInfo.provinceName isEqualToString:locInfo.cityName])
//                {
//                    
//                    [self.changes setObject:locInfo.cityName forKey:@"cityname"];
//                    
//                }
//                else
//                {
//                    NSString *cityName = [NSString stringWithFormat:@"%@%@", locInfo.provinceName, locInfo.cityName];
//                    
//                    [self.changes setObject:cityName forKey:@"cityname"];
//                    
//                }

            }
        }
//        NSInteger index = [self.itemKeys indexOfObject:itemKey];
//        if (index != NSNotFound) {
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
    }else
    {
        
        
    }
    NSInteger index = [self.itemKeys indexOfObject:itemKey];
    if (index != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)onPickerCancel:(id)sender {
    [self hidePopToolView];
}

@end

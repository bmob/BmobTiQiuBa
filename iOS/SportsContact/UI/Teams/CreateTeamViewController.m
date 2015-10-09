//
//  CreateTeamViewController.m
//  SportsContact
//
//  Created by Nero on 7/19/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "CreateTeamViewController.h"
#import <BmobSDK/Bmob.h>
#import <UIImageView+WebCache.h>
#import "DataDef.h"
#import "DateUtil.h"
#import "ViewUtil.h"
#import "LocationInfoManager.h"
#import "Util.h"

#import "TeamEngine.h"



#import "ValueSettingViewController.h"
#import "ManageTeamViewController.h"



@interface CreateTeamViewController ()


//@property (nonatomic, assign) BOOL isTheRegisterSetting;


//@property (nonatomic,strong) Team *teamInfo;


//@property (nonatomic,strong) NSString *isCreateteamBoolStr;


@property (nonatomic, strong) NSArray *uiitems;
@property (nonatomic, strong) NSArray *itemKeys;
@property (nonatomic, strong) NSString *settingKey;

@property (strong, nonatomic) IBOutlet UIView *popToolView;
@property (strong, nonatomic) IBOutlet UIView *popImageToolView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;


@property (nonatomic, strong) NSMutableDictionary *changes;
@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;
//@property (nonatomic, strong) NSArray *districts;
@property (nonatomic, strong) LocationInfo *locationInfo;
@property (nonatomic) NSInteger pickerRow;


@property (nonatomic, strong) UIButton *rButton;




@end

@implementation CreateTeamViewController

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
    
//    self.isTheRegisterSetting=YES;//判断注册的，还是队长编辑球队资料
    
    
    if ([self.isCreateteamBoolStr isEqualToString:@"1"])
    {
        
        //创建球队
        self.uiitems = [NSArray arrayWithObjects:@"1",@"队名",@"城市",@"成立时间",@"0",@"联赛注册码",@"球队简介",@"0", nil];
        
        self.itemKeys = [NSArray arrayWithObjects:@"avator",@"name",@"city", @"found_time", @"0", @"gsl_code" ,@"about",@"0", nil];

    }
    else if ([self.isCreateteamBoolStr isEqualToString:@"0"])
    {
        //修改球队资料
        self.uiitems = [NSArray arrayWithObjects:@"1",@"队名",@"城市",@"成立时间",@"0",@"更换队长",@"球队简介",@"0", nil];
        
        self.itemKeys = [NSArray arrayWithObjects:@"avator",@"name",@"city", @"found_time", @"0",@"captain" ,@"about",@"0", nil];

        
    }
    else
    {
        
    }


    
    //Locationpicker
    self.provinces = [[LocationInfoManager sharedManager] provinceArray];
    self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:[self.provinces firstObject]];
//    self.districts = [[LocationInfoManager sharedManager] districtArrayInProvince:[self.provinces firstObject] city:[self.cities firstObject]];
    self.locationInfo = [[LocationInfo alloc] init];
    
    
    //topBarList
    UIView *toolView = [self.popToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolView target:self action:@selector(hidePopToolView)];
    

    
    //bottomList
    UIView *imageToolBgView = [self.popImageToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:imageToolBgView target:self action:@selector(hidePopImageToolView)];
    UIView *imageToolContentView = [self.popImageToolView viewWithTag:0xF1];
    for (UIView *view in imageToolContentView.subviews)
    {
        view.layer.cornerRadius = 4.0f;
    }
    
    

    
    self.changes = [NSMutableDictionary dictionaryWithCapacity:0];

    
    
    
    self.rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [self.rButton  setTitle:@"保存" forState:UIControlStateNormal];
    [self.rButton  addTarget:self action:@selector(onSaveTeamSetting:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rButton ];
    
    
    self.rButton.userInteractionEnabled=YES;
    
    
    
    

    

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hidePopToolView];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed
{
    return NO;
}


- (void)showPopToolView
{
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

- (void)addToLeagueWithTeamId:(NSString *)teamId
{
    NSString *registernumber = self.teamInfo.gsl_code;
    
    if ([self.changes objectForKey:@"gsl_code"]) {
        registernumber = [self.changes objectForKey:@"gsl_code"];
    }
    if (registernumber)
    {
        BmobQuery *query = [BmobQuery queryWithClassName:kTableLeague];
        [query whereKey:@"inviteCode" equalTo:registernumber];
        query.limit = 0;
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            @try {
                BmobObject *obj = [array firstObject];
                BmobObject *league = [BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:obj.objectId];
                BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teamId];
                BmobRelation *relationLeague = [BmobRelation relation];
                [relationLeague addObject:team];
                [league addRelation:relationLeague forKey:@"teams"];
                [self showLoadingView];
                [league updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                 {
                     [self hideLoadingView];
                     if (isSuccessful)
                     {
                         [self showMessage:@"成功加入联赛！"];
                     }else
                     {
                         [self showMessage:@"加入联赛失败！"];
                     }
                 }];
            }
            @catch (NSException *exception) {
                [self showMessage:@"加入联赛失败！"];
            }
            @finally {
                
            }
        }];
        ;
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.uiitems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *uiitem = [self.uiitems objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        return 176;
    }else if([uiitem isEqualToString:@"0"])
    {
        return 32;
    }else
    {
        return 44;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell;
    
    NSString *uiitem = [self.uiitems objectAtIndex:indexPath.row];
    
    NSString *itemKey = [self.itemKeys objectAtIndex:indexPath.row];
    BDLog(@"item key :%@", itemKey);
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CreateTeamHeaderCell"];
        
        UIImageView *avatarView = (id)[cell.contentView viewWithTag:0xF0];
        
        if (self.avatarImage)
        {
            avatarView.image = self.avatarImage;
        }else
        {
            avatarView.clipsToBounds = NO;
//            avatarView.contentMode = UIViewContentModeCenter;
            [avatarView sd_setImageWithURL:[NSURL URLWithString:self.teamInfo.avator.url] completed:nil];
        }
        
        if ([avatarView.gestureRecognizers count] == 0)
        {
            [ViewUtil addSingleTapGestureForView:avatarView target:self action:@selector(onEditTeamAvatar:)];
        }
        
    }
    else if([uiitem isEqualToString:@"0"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CreateTeamSpaceCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CreateTeamSettingCell"];
        
        if(indexPath.row > 0 && indexPath.row < self.uiitems.count)
        {
            UIImageView *line = (id)[cell.contentView viewWithTag:0xF0];
            
            line.hidden =  [[self.uiitems objectAtIndex:indexPath.row + 1] isEqualToString:@"0"];
        }
        
        UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
        itemLabel.text = uiitem;
        
        UILabel *itemValueLabel = (id)[cell.contentView viewWithTag:0xF2];
        
        

        if ([itemKey isEqualToString:@"name"])
        {
            NSString *teamName = self.teamInfo.name;
            if ([self.changes objectForKey:@"name"]) {
                teamName = [self.changes objectForKey:@"name"];
            }
            if (teamName)
            {
                itemValueLabel.text = teamName;
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }
        else if ([itemKey isEqualToString:@"city"])
        {
            NSString *cityCode = self.teamInfo.city;
            
            if ([self.changes objectForKey:@"city"])
            {
                cityCode = [self.changes objectForKey:@"city"];
            }
            
            
//            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfProvinceName:self.locationInfo.provinceName cityName:self.locationInfo.cityName districtName:nil];
//            if (locInfo && locInfo.cityCode.integerValue > 0)
//            {
//                
//            }
//            else
//            {
//                
//            }

            
            
            if (cityCode)
            {
                LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
//                itemValueLabel.text = [NSString stringWithFormat:@"%@ %@", locInfo.cityName, locInfo.districtName];
                itemValueLabel.text = [NSString stringWithFormat:@"%@ %@", locInfo.provinceName, locInfo.cityName];

            }else
            {
//                itemValueLabel.text = @"暂无";
                
                //默认广东广州
                LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:440100]];
                itemValueLabel.text = [NSString stringWithFormat:@"%@ %@", locInfo.provinceName, locInfo.cityName];
                
            
                
                
            }
            
        }
        else if ([itemKey isEqualToString:@"found_time"])
        {
            NSDate *birthday = self.teamInfo.found_time;
            if ([self.changes objectForKey:@"found_time"]) {
                birthday = [self.changes objectForKey:@"found_time"];
            }
            if (birthday)
            {
                itemValueLabel.text = [DateUtil formatedDate:birthday bySeparate:@"/"];
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }
        else if ([itemKey isEqualToString:@"gsl_code"])
        {
            NSString *registernumber = self.teamInfo.gsl_code;
            
            if ([self.changes objectForKey:@"gsl_code"]) {
                registernumber = [self.changes objectForKey:@"gsl_code"];
            }
            if (registernumber)
            {
                itemValueLabel.text = [NSString stringWithFormat:@"%@", registernumber];
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }
        else if ([itemKey isEqualToString:@"captain"])
        {
            
            NSString *captain;
            
            if (self.teamInfo.captain.nickname)
            {
                  captain = self.teamInfo.captain.nickname;
            }
            else
            {
                captain = self.teamInfo.captain.username;
            }
                
            
            if ([self.changes objectForKey:@"captain"]) {
                captain = [self.changes objectForKey:@"captain"];
            }
            if (captain)
            {
//                UserInfo *user = [[UserInfo alloc] initWithDictionary:[BmobUser objectWithoutDatatWithClassName:nil objectId:captain]];
//                
//                if ([user.nickname length]!=0)
//                {
//                    itemValueLabel.text = user.nickname;
//
//                }
//                else
//                {
//                    itemValueLabel.text = user.username;
//                }
                
                
                itemValueLabel.text = captain;

                
            }else
            {
                itemValueLabel.text = @"暂无";
            }
            
        }
        else if ([itemKey isEqualToString:@"about"])
        {
                        NSString *aboutString = self.teamInfo.about;
                        if ([self.changes objectForKey:@"about"]) {
                            aboutString = [self.changes objectForKey:@"about"];
                        }
                        if (aboutString)
                        {
                            itemValueLabel.text = @"***";
                        }else
                        {
                            itemValueLabel.text = @"暂无";
                        }
            
        }
        else
        {
            NSString *value = [self.teamInfo valueForKey:itemKey];
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
        
        
    
    
    return cell;

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *itemKey = [self.itemKeys objectAtIndex:indexPath.row];
    self.settingKey = itemKey;

    

    if ([itemKey isEqualToString:@"name"])
    {
        [self performSegueWithIdentifier:@"Team_valueSetting" sender:nil];
    }
    else if ([itemKey isEqualToString:@"city"])
    {
        self.datePicker.hidden = YES;
        self.valuePicker.hidden = NO;
        [self.valuePicker reloadAllComponents];
        NSString *cityCode = self.teamInfo.city;
        
        if ([self.changes objectForKey:@"city"]) {
            cityCode = [self.changes objectForKey:@"city"];
        }
        
        if (cityCode)
        {
            
            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
            
            self.locationInfo = locInfo;
            
            if ( locInfo.provinceName && [self.provinces indexOfObject:locInfo.provinceName] != NSNotFound)
            {
                [self.valuePicker  selectRow:[self.provinces indexOfObject:locInfo.provinceName] inComponent:0 animated:NO];
                
                self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:locInfo.provinceName];
                
                [self.valuePicker reloadComponent:1];
                
                if (locInfo.cityName && [self.cities indexOfObject:locInfo.cityName] != NSNotFound)
                {
                    [self.valuePicker  selectRow:[self.cities indexOfObject:locInfo.cityName] inComponent:1 animated:NO];
                    
//                    self.districts = [[LocationInfoManager sharedManager] districtArrayInProvince:locInfo.provinceName city:locInfo.cityName];
//                    
//                    [self.valuePicker reloadComponent:2];
//                    if (locInfo.districtName && [self.districts indexOfObject:locInfo.districtName] != NSNotFound)
//                    {
//                        [self.valuePicker  selectRow:[self.districts indexOfObject:locInfo.districtName] inComponent:2 animated:NO];
//                    }
                    
                }
                
            }
        }
        else
        {
            
            NSString *cityCode = @"440103";

            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[cityCode integerValue]]];
            
            self.locationInfo = locInfo;
            
            if ( locInfo.provinceName && [self.provinces indexOfObject:locInfo.provinceName] != NSNotFound)
            {
                [self.valuePicker  selectRow:[self.provinces indexOfObject:locInfo.provinceName] inComponent:0 animated:NO];
                
                self.cities = [[LocationInfoManager sharedManager] cityArrayInProvince:locInfo.provinceName];
                
                [self.valuePicker reloadComponent:1];
                
                if (locInfo.cityName && [self.cities indexOfObject:locInfo.cityName] != NSNotFound)
                {
                    [self.valuePicker  selectRow:[self.cities indexOfObject:locInfo.cityName] inComponent:1 animated:NO];
                    
                    
                }
                
            }
        }
        
        
        
        [self showPopToolView];
        
    }
    else if ([itemKey isEqualToString:@"found_time"])
    {
        self.datePicker.hidden = NO;
        self.valuePicker.hidden = YES;
        NSDate *birthday = self.teamInfo.found_time;
        if ([self.changes objectForKey:@"found_time"]) {
            birthday = [self.changes objectForKey:@"found_time"];
        }
        if (birthday) {
            self.datePicker.date = birthday;
        }
        [self showPopToolView];
    }
    else if ([itemKey isEqualToString:@"gsl_code"])
    {
        [self performSegueWithIdentifier:@"Team_valueSetting" sender:nil];
    }
    else if ([itemKey isEqualToString:@"captain"])
    {
        [self performSegueWithIdentifier:@"Team_changeCaptain" sender:nil];
    }
    else if ([itemKey isEqualToString:@"about"])
    {
        [self performSegueWithIdentifier:@"Team_valueSetting" sender:nil];
    }
    else
    {
        
    }

    
    
    
    
    
}






#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSString *itemKey = self.settingKey;
    
    if ([itemKey isEqualToString:@"city"])
    {
        return 2;
    }else
    {
        return 0;
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString *itemKey = self.settingKey;
    
    if ([itemKey isEqualToString:@"city"])
    {
        switch (component) {
            case 0:
                return [self.provinces count];
                break;
            case 1:
                return  [self.cities count];
                break;
//            case 2:
//                return [self.districts count];
//                break;
                
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
    
    if ([itemKey isEqualToString:@"city"])
    {
        switch (component) {
            case 0:
                return [self.provinces objectAtIndex:row];
                break;
            case 1:
                return  [self.cities objectAtIndex:row];
                break;
//            case 2:
//                return [self.districts objectAtIndex:row];
//                break;
                
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
                
                
//                _districts = [[LocationInfoManager sharedManager] districtArrayInProvince:self.locationInfo.provinceName city:self.locationInfo.cityName];
//                [pickerView reloadComponent:2];
//                if (_districts && _districts.count>0) {
//                    self.locationInfo.districtName = [_districts objectAtIndex:0];
//                    [pickerView selectRow:0 inComponent:2 animated:NO];
//                }else{
//                    self.locationInfo.districtName = nil;
//                }
                
            }
                break;
            case 1:
            {
                if (_cities && _cities.count>row) {
                    self.locationInfo.cityName = [_cities objectAtIndex:row];
                    
//                    _districts = [[LocationInfoManager sharedManager] districtArrayInProvince:self.locationInfo.provinceName city:self.locationInfo.cityName];
//                    [pickerView reloadComponent:2];
//                    if (_districts && _districts.count>0) {
//                        self.locationInfo.districtName = [_districts objectAtIndex:0];
//                        [pickerView selectRow:0 inComponent:2 animated:NO];
//                    }
                    
                }else{
                    self.locationInfo.cityName = nil;
//                    _districts = nil;
                    [pickerView selectRow:0 inComponent:2 animated:NO];
                }
            }
                break;
//            case 2:
//            {
//                if (_districts && _districts.count>row) {
//                    self.locationInfo.districtName = [_districts objectAtIndex:row];
//                }else{
//                    self.locationInfo.districtName = nil;
//                }
//            }
//                break;
                
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

- (void)valueSelection:(id)valueSelection changeCaptainId:(NSString *)userId
{
    
    NSString *itemKey = self.settingKey;
   
    if ([itemKey isEqualToString:@"captain"])
    {
            [self.changes setObject:userId forKey:@"captain"];
    }
    
    NSInteger reloadIndex = [self.itemKeys indexOfObject:itemKey];
    
    if (reloadIndex != NSNotFound)
    {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:reloadIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    
}




#pragma mark - ValueSettingDelegate

- (void)valueSetting:(id)valueSelection didSaveValue:(NSString *)value
{
    NSString *itemKey = self.settingKey;
    
    if ([itemKey isEqualToString:@"name"])
    {
        

        if (self.teamInfo.name)
        {
                [self.changes setObject:value forKey:@"name"];

        }else
        {
            [self.changes setObject:value forKey:@"name"];
        }
        
    }
    else if ([itemKey isEqualToString:@"gsl_code"])
    {
        
        if ([value length]!=0)
        {
            [self.changes setObject:value forKey:@"gsl_code"];
        }
        
        
        
    }
    else if ([itemKey isEqualToString:@"about"])
    {
        
        if ([value length]!=0)
        {
            [self.changes setObject:value forKey:@"about"];
        }

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
    
    UIImage *scaleImage = [Util scaleImage:image width:160];
    self.avatarImage  = [Util resizeImage:scaleImage width:160 height:134];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Event handler

- (void)onEditTeamAvatar:(id)sender
{
    BDLog(@"11111111");
    
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





#pragma mark - Event handler


- (void)onSaveTeamSetting:(id)sender {
    
    
    [self showLoadingView];
    self.rButton.userInteractionEnabled=NO;
    //修改还是创建
    
    BDLog(@"**********%@***********%@",[self.changes objectForKey:@"name"],self.teamInfo.name);
    
    NSString *teamname;
    
    
    if ([[self.changes objectForKey:@"name"] length]!=0)
    {
        teamname=[self.changes objectForKey:@"name"];
        
    }
    else
    {
        teamname=self.teamInfo.name;
    }
    
    
    
    if ([teamname length]==0)
    {
        [self showMessage:@"队名不能为空！"];
        
        self.rButton.userInteractionEnabled=YES;
        
        [self hideLoadingView];
        
    }
    else
    {
        
        
        
        
        [TeamEngine getSearchTeamWithTeamname:teamname block:^(id result, NSError *error) {
            
            NSArray *array=[[NSArray alloc]init];
            array=result;
            
            
            if ([array count]==1)
            {
                
                
                Team *team=[array objectAtIndex:0];
                
                if ([self.teamInfo.objectId isEqualToString:team.objectId])
                {
                    
                    
                    [self onSaveTeamModified:nil];
                    
                }
                else
                {
                    [self showMessage:@"队名有重复，请重新设置！"];
                    
                    self.rButton.userInteractionEnabled=YES;
                    
                    [self hideLoadingView];
                    
                }
                
                
                
            }
            else if ([array count]==0)
            {
                
                
                
                if ([self.isCreateteamBoolStr isEqualToString:@"1"])
                {
                    
                    [self onSettingSubmit:nil];
                    
                }
                else
                {
                    [self onSaveTeamModified:nil];
                    
                }
                
                
                
                
            }
            else
            {
                
            }
            
            
            
            
            
        }];
        
    }
    
}






-(void)onSaveTeamModified:(id)sender
{
    

//    [self showLoadingView];
    
    
    BmobObject *teamMessage = [BmobObject objectWithClassName:@"Team"];
    [teamMessage incrementKey:@"name"];
    
    
    [self.changes setObject:@"" forKey:@"gsl_code"];

    

        [TeamEngine updateTeamInfoWithteamId:self.teamInfo.objectId avatarImage:self.avatarImage changes:self.changes block:^(id result, NSError *error)
         {
             
             [self hideLoadingView];
             
             if (error)
             {
                 [self showMessage:[Util errorStringWithCode:error.code]];
             }else
             {
                 [self showMessage:@"成功保存"];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kObserverTeamInfoChanged object:nil];
                 
                 [self.navigationController popViewControllerAnimated:YES];
                 
                 
//                 //直接加入联赛
//                 [self addToLeagueWithTeamId:self.teamInfo.objectId];

             }

             self.rButton.userInteractionEnabled=YES;

             
         }];
        
        
    
    
    
    
    
    
    
    
}



-(void)onSettingSubmit:(id)sender
{
    
//    [self showLoadingView];
    
    BmobObject *teamMessage = [BmobObject objectWithClassName:@"Team"];
    [teamMessage incrementKey:@"name"];
    
    [teamMessage setObject:[self.changes objectForKey:@"name"] forKey:@"name"];
    [teamMessage setObject:[BmobUser getCurrentUser] forKey:@"captain"];
    [teamMessage setObject:[self.changes objectForKey:@"avator"] forKey:@"avator"];
    
//    [teamMessage setObject:[self.changes objectForKey:@"city"] forKey:@"city"];
    
    [teamMessage setObject:[self.changes objectForKey:@"found_time"] forKey:@"found_time"];
    [teamMessage setObject:[self.changes objectForKey:@"gsl_code"] forKey:@"gsl_code"];
    [teamMessage setObject:[self.changes objectForKey:@"about"] forKey:@"about"];
    
    
    
    
    //城市
    if ([self.changes objectForKey:@"city"])
    {
        
        [teamMessage setObject:[self.changes objectForKey:@"city"] forKey:@"city"];

        
        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[[self.changes objectForKey:@"city"] integerValue]]];
        
        if ([locInfo.provinceName isEqualToString:locInfo.cityName])
        {
            [teamMessage setObject:locInfo.cityName forKey:@"cityname"];

        }
        else
        {
            NSString *cityName = [NSString stringWithFormat:@"%@%@", locInfo.provinceName, locInfo.cityName];
            
            [teamMessage setObject:cityName forKey:@"cityname"];

        }
    }
    else
    {
        //默认广东广州
        
        [self.changes setObject:@"440100" forKey:@"city"];
        [teamMessage setObject:[self.changes objectForKey:@"city"] forKey:@"city"];

        
        
        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[[self.changes objectForKey:@"city"] integerValue]]];
        
        if ([locInfo.provinceName isEqualToString:locInfo.cityName])
        {
            [teamMessage setObject:locInfo.cityName forKey:@"cityname"];
            
        }
        else
        {
            NSString *cityName = [NSString stringWithFormat:@"%@%@", locInfo.provinceName, locInfo.cityName];
            
            [teamMessage setObject:cityName forKey:@"cityname"];
            
        }

        
        
    }
    
    
    
    
    [teamMessage saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        
        [self hideLoadingView];
        
       
        
        BDLog(@"error %@",[error description]);
        
        if (isSuccessful)
        {
            
            
            [self loadTeamInfo:[self.changes objectForKey:@"name"]];

            
            //此处异步执行，如果用户添加了『联赛邀请码』，该创建成功的球队，直接加入到某联赛,『联赛邀请码』为联赛的object id，如果不成功，则用户再自己手动申请加入
            
            [self addToLeagueWithTeamId:teamMessage.objectId];
            
            //生成球队邀请码
            [BmobCloud callFunctionInBackground:@"genTeamRegCode" withParameters:@{@"teamId":teamMessage.objectId} block:nil];
            
            
            
            
            
            
        }
        else{
            
            [self showMessage:@"队伍创建失败！"];
            
        }
        
        
        
        self.rButton.userInteractionEnabled=YES;

        
    }];
    
    
    
    
    
    
    
    
}




-(void)loadTeamInfo:(NSString *)teamName
{
    
    
    //新创建的队伍
    [self showLoadingView];
    
    [TeamEngine getInfoWithTeamname:teamName block:^(id result, NSError *error)
     {
         
         
         [self hideLoadingView];
         
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             
             
             
             //创建完球队，要将该用户添加到球队,作为队长

                 Team *teaminfornation=result;

                 BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teaminfornation.objectId];
             
                 BmobRelation *relation = [BmobRelation relation];
             
                 [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:teaminfornation.captain.objectId]];   //obj 添加关联关系到footballer列中
             
                 [team addRelation:relation forKey:@"footballer"];
             
                 [team updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                  {
                      
                      BDLog(@"error %@",[error description]);
                      
                      
                      if (isSuccessful)
                      {
                          
                          ManageTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageTeamViewController"];
                          
                          teamInfoVC.title=@"球队管理";
                          
                          teamInfoVC.teamInfo=result;
                          
                          teamInfoVC.isCreateteamBool=YES;
                          
                          [self.navigationController pushViewController:teamInfoVC animated:YES];

                          
                          [self showMessage:@"队伍创建成功！"];
                          
                          
                          
                          //User team 插入所属球队数据
                          BmobObject *obj = [BmobUser getCurrentUser];
                          BmobRelation *relation = [[BmobRelation alloc] init];
                          [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.teamInfo.objectId]];
                          [obj addRelation:relation forKey:@"team"];
                          [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                          {
                               BDLog(@"error %@",[error description]);
                           }];
                          
                          
                          
                          
                          //创建球队时候，同时创建阵容
                          [self showLoadingView];
                          [TeamEngine createLineupWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error)
                          {
                              
                              [self hideLoadingView];
                              
                              
                          }];


                          
                          
                      }
                      else
                      {
                          
                          [self deleteTheTeam:teaminfornation];
                          
                          
                      }
                      
                      
                      
                      
                      
                      
                  }];

             
             
             

             
             
         }
         
     }];

    
    
}



-(void)deleteTheTeam:(Team *)teaminfornation
{
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:teaminfornation.objectId];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:teaminfornation.captain.objectId]];
    [obj addRelation:relation forKey:@"footballer"];
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        
        BDLog(@"error %@",[error description]);
        
        [self showMessage:@"队伍创建失败！"];

        
    }];

    
}




#pragma mark pickerDelegate

- (IBAction)onPickerSure:(id)sender {
    
    NSString *itemKey = self.settingKey;
    [self hidePopToolView];
    
    if ([itemKey isEqualToString:@"found_time"])
    {
        if (self.datePicker.date)
        {
            [self.changes setObject:self.datePicker.date forKey:itemKey];
        }
        
    }else if ([itemKey isEqualToString:@"city"])
    {
//        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfProvinceName:self.locationInfo.provinceName cityName:self.locationInfo.cityName districtName:self.locationInfo.districtName];
        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfProvinceName:self.locationInfo.provinceName cityName:self.locationInfo.cityName districtName:nil];


        if (locInfo && locInfo.cityCode.integerValue > 0)
//        if (locInfo)
        {
            if ([self.teamInfo.city integerValue] == locInfo.cityCode.integerValue)
            {
                [self.changes removeObjectForKey:itemKey];
            }
            else
            {
                
//                [self.changes setObject:[NSString stringWithFormat:@"%@", locInfo.districtCode] forKey:itemKey];
                [self.changes setObject:[NSString stringWithFormat:@"%@",locInfo.cityCode] forKey:itemKey];
                
                
                    if ([locInfo.provinceName isEqualToString:locInfo.cityName])
                    {
                        
                        [self.changes setObject:locInfo.cityName forKey:@"cityname"];

                    }
                    else
                    {
                        NSString *cityName = [NSString stringWithFormat:@"%@%@", locInfo.provinceName, locInfo.cityName];
                        
                        [self.changes setObject:cityName forKey:@"cityname"];
                        
                    }

                
                
                
                

            }
        }
        
        
        
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






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    NSString *itemKey = self.settingKey;

//    BDLog(@"*********%@",self.teamInfo);
    
    if ([segue.identifier isEqualToString:@"Team_valueSetting"])
    {
        
        
        if ([itemKey isEqualToString:@"name"])
        {

            [segue.destinationViewController setValue:@"队名" forKey:@"title"];
            
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:8] forKey:@"wordLimit"];
            

        }
        else if ([itemKey isEqualToString:@"gsl_code"])
        {
            [segue.destinationViewController setValue:@"联赛注册码" forKey:@"title"];
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:40] forKey:@"wordLimit"];
            

        }
        else if ([itemKey isEqualToString:@"about"])
        {
            [segue.destinationViewController setValue:@"简介" forKey:@"title"];
            
            [segue.destinationViewController setValue:[NSNumber numberWithInteger:80] forKey:@"wordLimit"];
            


        }
        else
        {
            
        }
        
        
        
        //传值到输入界面
        [segue.destinationViewController setValue:self  forKey:@"delegate"];
        
        NSString *value = [self.teamInfo valueForKey:itemKey];
        
        if ([self.changes objectForKey:itemKey]) {
            
            value = [self.changes objectForKey:itemKey];
            
        }
        if (value) {
            
            [segue.destinationViewController setValue:value forKey:@"value"];
        }

        
        
        
        
    }
    else if ([segue.identifier isEqualToString:@"Team_manage"])
    {
        

        
        
    }
    else if ([segue.identifier isEqualToString:@"Team_changeCaptain"])
    {
        
        [segue.destinationViewController setValue:@"更换队长" forKey:@"title"];
        [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];

        [segue.destinationViewController setValue:self  forKey:@"delegate"];

        
    }
    else
    {
        
    }

    
    
    
    
    
    
    
}


@end

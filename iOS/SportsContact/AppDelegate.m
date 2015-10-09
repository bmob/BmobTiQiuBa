//
//  AppDelegate.m
//  SportsContact
//
//  Created by bobo on 14-7-7.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>
#import "LoginEngine.h"
#import "LocationInfoManager.h"
#import "NoticeManager.h"
#import "AppSettings.h"
#import "BPush.h"

#import "JSONKit.h"

#import <ShareSDK/ShareSDK.h>

#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <BmobSDK/BmobGPSSwitch.h>

#import "MobClick.h"
#import "NoticeManager.h"

@interface AppDelegate ()<UIAlertViewDelegate>

@property(assign)BOOL forceUpdated;
@property(copy ,nonatomic) NSString *appUrl;
@property(copy ,nonatomic) NSString *serverVersionString;

@end


@implementation AppDelegate
@synthesize forceUpdated        = _forceUpdated;
@synthesize appUrl              = _appUrl;
@synthesize serverVersionString = _serverVersionString;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    

    
    [BmobGPSSwitch gpsSwitch:NO];

#warning 输入自己的BmobAppID
    [Bmob registerWithAppKey:@""];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    if (iOS8) {
        //iOS8推送
        UIMutableUserNotificationCategory*categorys = [[UIMutableUserNotificationCategory alloc]init];
        categorys.identifier=@"cn.bomb.football";
        UIUserNotificationSettings*userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound)
                                                                                         categories:[NSSet setWithObjects:categorys,nil]];
        [[UIApplication sharedApplication]registerUserNotificationSettings:userNotifiSetting];
        [[UIApplication sharedApplication]registerForRemoteNotifications];
    }else{
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
    
    
    [NoticeManager updatePushProfile];
    if ([BmobUser getCurrentUser])
    {
        [[NoticeManager sharedManager] bindDB];
    }else
    {
        [[NoticeManager sharedManager] unbindDB];
    }
    
    // 启动选项
    if (launchOptions != nil) {
        // push消息
        NSDictionary *remoteNotificationDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotificationDictionary){
            BDLog(@"Get remote notification :%@", remoteNotificationDictionary);
            [self handleReceiveRemoteNotification:remoteNotificationDictionary];
        }
    }
    //百度推送代理
#warning 输入自己的百度推送的key
    [BPush setDelegate:self];
    [self setDefaultSetting];
    [self initializePlat];
    [self initUmengSDK];
    [self performSelector:@selector(versionCheck) withObject:nil afterDelay:1.0f];
    
    
    return YES;
}



-(void)setDefaultSetting{
    //默认不由登录界面进入
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"viaLoginVC"];
    //如果没有进入个人中心，则设置第一次进入个人中心
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"first_user_in"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"first_user_in"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //如果没有进入比赛结果，则设置第一次进入比赛结果
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"first_score_in"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"first_score_in"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)initUmengSDK{
#warning 输入自己的友盟的key
    NSString *key = @"";
    [MobClick startWithAppkey:key reportPolicy:BATCH channelId:nil];
}

-(void)initializePlat
{
    
#warning 对应平台的相应信息
    [ShareSDK registerApp:@""];     //参数为ShareSDK官网中添加应用后得到的AppKey

    [ShareSDK connectQZoneWithAppKey:@""
                           appSecret:@""
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];

    
    //添加QQ应用
    [ShareSDK connectQQWithQZoneAppKey:@""                 //该参数填入申请的QQ AppId
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    
    [ShareSDK connectWeChatWithAppId:@"" wechatCls:[WXApi class]];
    //wx4f49df1c2cfc15eb
    

    [ShareSDK connectSinaWeiboWithAppKey:@""
                               appSecret:@""
                             redirectUri:@"http://www.bmob.cn"];

    
    
    
    //跳转APP
    [ShareSDK ssoEnabled:YES];
}

- (NSString *)hexStringFromData:(NSData *)data{
    NSData *myD = data;//[string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    //TODO: 3. 实现handleOpenUrl相关的两个方法，用来处理微信的回调信息
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    //记录进入后台的时间

    NSDate * startData = [NSDate date];//获取当前的时间
    
    [[NSUserDefaults standardUserDefaults] setObject:startData forKey:@"startData"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //记录返回APP的时间，等出时间差
    
    NSDate *startData=[[NSUserDefaults standardUserDefaults] valueForKey:@"startData"];
    
    NSDate *endData=[NSDate date];

    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *d = [cal components:unitFlags fromDate:startData toDate:endData options:0];
    
    long sec = [d hour]*3600+[d minute]*60+[d second];
    
//    BDLog(@"second = %d",[d hour]*3600+[d minute]*60+[d second]);


    BOOL isEnterBackGrounpBool=YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:sec] forKey:@"backGroundSecond"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isEnterBackGrounpBool] forKey:@"isEnterBackGrounpBool"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [Bmob activateSDK];
    
//    if (self.serverVersionString && self.serverVersionString.length > 0) {
//        NSDictionary *infoDic         = [NSBundle mainBundle].infoDictionary;
//        NSString *localVersionString  = [infoDic objectForKey:@"CFBundleShortVersionString"];
//        
//        NSString *message = @"发现新版本，是否前去升级?";
//        if (![self.serverVersionString isEqualToString:localVersionString]) {
//            UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"版本更新"
//                                                          message:message
//                                                         delegate:self
//                                                cancelButtonTitle:@"取消"
//                                                otherButtonTitles:@"前去升级", nil];
//            [uav show];
//        }
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark remote notification

//#if [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
    
}
//#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [AppSettings setData:deviceToken forKey:SettingsDeviceToken];
//    [NoticeManager updatePushProfile];
    
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannel];
    
}

- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    
    
    
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];

        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        
        [AppSettings setString:userid forKey:SettingBPushUserId];
        [AppSettings setString:channelid forKey:SettingBPushChannelid];
        
        [NoticeManager updatePushProfile];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    BDLog(@"userInfo:%@",[userInfo description]);

    
    [self handleReceiveRemoteNotification:userInfo];
}

- (void)handleReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
//    if ([[userInfo objectForKey:SettingsPushFlag] isEqualToString:SettingsPushFlagvalueNotice])
//    {
//
//        Notice *msg = [[Notice alloc] initWithDictionary:userInfo];
//        msg.status = NoticeStatusReceived;
//        [[NoticeManager sharedManager] saveNotice:msg];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kObserverNoticeRecieve object:userInfo];
//    }
    
    if ([[userInfo objectForKey:SettingsPushFlag] isEqualToString:SettingsPushFlagvalueNotice]){
        [[NoticeManager sharedManager] readNoticeListFromWebFinished:nil];
    }
    
}



//检查版本信息
-(void)versionCheck{
    BmobQuery *query = [BmobQuery queryWithClassName:@"AppVersion"];
    [query whereKey:@"platform" equalTo:@"ios"];
    query.limit = 1;
    [query orderByDescending:@"updatedAt"];
    __weak typeof(BmobQuery *)weakQuery = query;
    [weakQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array && array.count >= 1) {
            BmobObject *obj               = (BmobObject *)[array firstObject];
            self.serverVersionString      = [[obj objectForKey:@"version"] description];
            NSDictionary *infoDic         = [NSBundle mainBundle].infoDictionary;
            NSString *localVersionString  = [infoDic objectForKey:@"CFBundleShortVersionString"];
            if (![self.serverVersionString isEqualToString:localVersionString]) {
                self.forceUpdated = [[obj objectForKey:@"isforce"] boolValue];
                self.appUrl       = [obj objectForKey:@"ios_url"];
                NSString *message = [[obj objectForKey:@"update_log"] description];
                if ([obj objectForKey:@"showtip"] && [[obj objectForKey:@"showtip"] boolValue]) {
                    if (self.forceUpdated) {
                        UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"版本更新"
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"前去升级", nil];
                        [uav show];
                    }else{
                        UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"版本更新"
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                            otherButtonTitles:@"前去升级", nil];
                        [uav show];
                    }
                }

            }
        }
    }];
}



-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            if (self.forceUpdated) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appUrl]];
            }
        }
            break;
        case 1:{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appUrl]];
        }
            break;
        default:
            break;
    }
}


@end

//
//  PushSDK.h
//  PushSDK
//
//  Created by yeyun on 13-2-18.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>


#define VERSION_NAME  @"1.2.0"
#define VERSION  4

@protocol BPushDelegate <NSObject>

/**
 * binChannel的回调
 * @param
 *     method - 请求的方法，如bind,set_tags
 *     response - 返回结果字典，包含：error_code/request_id/app_id/user_id/channel_id/error_msg
 * @return
 *     none
 */
- (void)onMethod:(NSString*)method response:(NSDictionary*)data;

@end

@interface BPush : NSObject

/**
 * binChannel的回调
 * @param
 *     launchOptions -
 * @return
 *     none
 */
+ (void)setupChannel:(NSDictionary *)launchOptions;

/**
 * 设置delegate，该delegate必须实现onBindChannel函数
 * @param
 *     delegate -
 * @return
 *     none
 */
+ (void)setDelegate:(id) delegate;

/**
 * 注册device token
 * @param
 *     deviceToken - 通过app delegate的didRegisterForRemoteNotificationsWithDeviceToken回调的获取
 * @return
 *     none
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/**
 * 设置access token. 在bindChannel之前调用，如果access token改变后，必须重新设置并且重新bindChannel
 * @param
 *     token - Access Token
 * @return
 *     none
 */
+ (void)setAccessToken:(NSString *)token;

+ (void)setBduss:(NSString *)bduss forApp:(NSString *)appid;

/**
 * 绑定channel. 如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     none
 * @return
 *     none
 */
+ (void)bindChannel;

/**
 * 解绑定channel. 如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     none
 * @return
 *     none
 */
+ (void)unbindChannel;

/**
 * 设置tag。如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     tag - 需要设置的tag
 * @return
 *     none
 */
+ (void)setTag:(NSString *)tag;

/**
 * 设置多个tag。如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     tags - 需要设置的tag数组
 * @return
 *     none
 */
+ (void)setTags:(NSArray *)tags;

/**
 * 删除tag。如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     tag - 需要删除的tag
 * @return
 *     none
 */
+ (void)delTag:(NSString *)tag;

/**
 * 删除多个tag。如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     tags - 需要删除的tag数组
 * @return
 *     none
 */
+ (void)delTags:(NSArray *)tags;

/**
 * 获取当前设备应用的tag列表。如果用户有注册delegate并实现onMethod:response:，将会回调该函数，通过method参数来判断返回的方法。
 * @param
 *     none
 * @return
 *     none
 */
+ (void)listTags;

/**
 * 在didReceiveRemoteNotification中调用，用于推送反馈
 * @param
 *     userInfo
 * @return
 *     none
 */
+ (void)handleNotification:(NSDictionary *)userInfo;

/**
 * 获取应用ID，Channel ID，User ID。如果应用没有绑定，那么返回空
 * @param
 *     none
 * @return
 *     appid/channelid/userid
 */
+ (NSString *) getChannelId;
+ (NSString *) getUserId;
+ (NSString *) getAppId;

@end

// 返回结果的键
#define BPushRequestErrorCodeKey   @"error_code"
#define BPushRequestErrorMsgKey    @"error_msg"
#define BPushRequestRequestIdKey   @"request_id"
#define BPushRequestAppIdKey       @"app_id"
#define BPushRequestUserIdKey      @"user_id"
#define BPushRequestChannelIdKey   @"channel_id"
#define BPushRequestResponseParamsKey  @"response_params" // 服务端返回的原始值，其内容和以上的部分值可能有重合

// 方法名, 用BPushRequestMethodKey取出的值
#define BPushRequestMethod_Bind    @"bind"
#define BPushRequestMethod_Unbind    @"unbind"
#define BPushRequestMethod_SetTag  @"set_tag"
#define BPushRequestMethod_DelTag  @"del_tag"
#define BPushRequestMethod_ListTag  @"list_tag"

/**
 * 请求错误码
 */
typedef enum BPushErrorCode
{
    BPushErrorCode_Success = 0,
    
    BPushErrorCode_MethodTooOften = 22, // 调用过于频繁
    
    BPushErrorCode_NetworkInvalible = 10002, // 网络连接问题
    
    BPushErrorCode_InternalError = 30600, // 服务器内部错误
    BPushErrorCode_MethodNodAllowed = 30601, // 请求方法不允许
    BPushErrorCode_ParamsNotValid = 30602, // 请求参数错误
    BPushErrorCode_AuthenFailed = 30603, // 权限验证失败
    BPushErrorCode_DataNotFound = 30605, // 请求数据不存在
    BPushErrorCode_RequestExpired = 30606, // 请求时间戳验证超时
    BPushErrorCode_BindNotExists = 30608, // 绑定关系不存在
    
}TBpushErrorCode;

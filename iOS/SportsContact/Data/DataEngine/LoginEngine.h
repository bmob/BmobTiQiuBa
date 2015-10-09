//
//  LoginEngine.h
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>
#import "DataDef.h"



@interface LoginEngine : NSObject

/**
 *  登录
 *
 *  @param username 用户名
 *  @param password 密码
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password block:(EngineBlock()) engineBlock;


//+ (void)loginWithUserid:(NSString *)userid block:(EngineBlock()) engineBlock;





/**
 *  获取用户信息
 *
 *  @param username 用户名
 */
+ (void)getUserinfoWithPhoenumber:(NSString *)number block:(EngineBlock()) engineBlock;





/**
 *  添加user数据
 *
 *  @param username 用户名
 */
+ (void)getAddUserWithPhoenumber:(NSString *)number password:(NSString *)password  registerInvitationStr:(NSString *)registerInvitationStr block:(EngineBlock()) engineBlock;




/**
 *  修改密码
 *
 *  @param username 用户名
 *  @param password 新密码

 */
+ (void)getUpdatePasswordWithPhoenumber:(NSString *)number newPassword:(NSString *)newpassword block:(EngineBlock()) engineBlock;








@end

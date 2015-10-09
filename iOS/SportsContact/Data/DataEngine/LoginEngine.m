//
//  LoginEngine.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "LoginEngine.h"
#import "Util.h"
#import "DateUtil.h"


@implementation LoginEngine

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password block:(EngineBlock()) engineBlock
{
    [BmobUser loginWithUsernameInBackground:username password:password block:^(BmobUser *user, NSError *error)
    {
        if (!error)
        {
            if (user)
            {
                BDLog(@"ok   username————————%@",[user objectForKey:@"username"]);
//                NSString *obj = [[user objectForKey:@"team"] objectId];
//                BDLog(@"Team :%@", obj);
                UserInfo *dicUser = [[UserInfo alloc] initWithDictionary:user];
                engineBlock(dicUser, nil);
            }else
            {
                error = [NSError errorWithDomain:ErrorUnkown code:-1 userInfo:@{NSLocalizedDescriptionKey : @"未知异常"}];
                engineBlock(nil, error);
            }
        }else
        {
            engineBlock(nil, error);
        }
        
    }];
}




//获取用户信息
+ (void)getUserinfoWithPhoenumber:(NSString *)number block:(EngineBlock()) engineBlock
{
    
    //判断账号有没注册
    
    BmobQuery *query = [BmobQuery queryForUser];
    
    [query whereKey:@"username" equalTo:number];
    
    //查看username有无相关数据
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        
        
        
        if (!error)
        {
            
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in array)
            {
                [result addObject:[[UserInfo alloc] initWithDictionary:obj]];
            }
            engineBlock(result, nil);

            
            
        }else
        {
            engineBlock(nil, error);
        }


        
        
    }];

    
}




//插入一个新user
//+ (void)getAddUserWithPhoenumber:(NSString *)number password:(NSString *)password  registerInvitationNumber:(NSNumber *)registerInvitationNumber block:(EngineBlock()) engineBlock;
+ (void)getAddUserWithPhoenumber:(NSString *)number password:(NSString *)password  registerInvitationStr:(NSString *)registerInvitationStr block:(EngineBlock()) engineBlock;
{
    
    BmobUser *bUser  = [[BmobUser alloc] init];
    
    [bUser setUserName:number];
    
    [bUser setPassword:password];
    
    
    //球队邀请码用的Team的object id
    [bUser setObject:registerInvitationStr forKey:@"invitation"];
    
    [bUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        
        if (isSuccessful)
        {
            engineBlock(nil, nil);
        }else
        {
            engineBlock(nil, error);
        }

        
        
        
    }];
    
    
    
    
}



+ (void)getUpdatePasswordWithPhoenumber:(NSString *)number newPassword:(NSString *)newpassword block:(EngineBlock()) engineBlock
{
    
    
//    BmobQuery *query = [BmobQuery queryForUser];
//    
//    [query whereKey:@"username" equalTo:number];
//    
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
//        
//        
//        
//        if (!error)
//        {
    
//            BmobObject *bo =[array firstObject];
    
    
            BmobUser *bUser = [BmobUser getCurrentUser];

            [bUser setObject:newpassword forKey:@"password"];
            
            [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                
                
                if (!error)
                {
                    engineBlock(nil, nil);

                }
                else
                {
                    engineBlock(nil, error);
 
                }
                
                
            }];

            

            
//        }
//        else
//        {
//            engineBlock(nil, error);
//        }
//        
//        
//        
//        
//    }];


    
}









@end


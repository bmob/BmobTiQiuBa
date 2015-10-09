//
//  BPushUtil.m
//  SportsContact
//
//  Created by Bmob on 15-1-27.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "BPushUtil.h"
#import "Util.h"
#import "JSONKit.h"

@implementation BPushUtil

+(void)setTags:(NSArray *)tags{
    
    for (NSString *tag in tags) {
        [[self class] setTag:tag];

    }
    
}

+(void)setTag:(NSString *)tag{
    if (![AppSettings stringOfKey:SettingBPushUserId]) {
        return;
    }
    NSString *url = @"https://channel.api.duapp.com/rest/2.0/channel/channel";
    NSString *method = @"POST";
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    tmpDic[@"method"] = @"set_tag";
    tmpDic[@"apikey"] = bPushApiKey;
    tmpDic[@"tag"] = tag;
    
    tmpDic[@"user_id"] = [AppSettings stringOfKey:SettingBPushUserId];
    tmpDic[@"timestamp"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    tmpDic[@"sign"] = [[self class] encodeSign:tmpDic url:url method:method];
    
    [[self class] sendRequest:tmpDic url:url method:method];
}


+(void)deleteTags:(NSArray *)tags{
    for (NSString *tag in tags) {
        [[self class] deleteTag:tag];
        
    }
}

+(void)deleteTag:(NSString *)tag{
    
    if (![AppSettings stringOfKey:SettingBPushUserId]) {
        return;
    }
    
    NSString *url = @"https://channel.api.duapp.com/rest/2.0/channel/channel";
    NSString *method = @"POST";
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    tmpDic[@"method"] = @"delete_tag";
    tmpDic[@"apikey"] = bPushApiKey;
    tmpDic[@"tag"] = tag;
    tmpDic[@"user_id"] = [AppSettings stringOfKey:SettingBPushUserId];
    tmpDic[@"timestamp"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    tmpDic[@"sign"] = [[self class] encodeSign:tmpDic url:url method:method];
    
    [[self class] sendRequest:tmpDic url:url method:method];
}

+(void)sendRequest:(NSDictionary *)para url:(NSString *)urlString method:(NSString *)method{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ([method isEqualToString:@"POST"]) {
        [manager POST:urlString
           parameters:para
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                  BDLog(@"success para%@ response%@ ",para,operation.responseString);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                  BDLog(@"failure para%@ response%@ ",para,operation.responseString);
              }];
    }else if ([method isEqualToString:@"GET"]){
        [manager GET:urlString parameters:para
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
             }];
    }
    
    
}

+(NSString *)encodeSign:(NSDictionary *)dic url:(NSString *)url method:(NSString *)method{
    NSString *ascString = [Util asckeyAscValue:dic];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@",method,url,ascString,bPushSecretKey];
    NSString *urlenString = [Util stringByURLEncodingStringParameter:urlString];
    
    NSString *md5String = [Util md5WithString:urlenString];
    
    return md5String;
}


+(void)sendMessageToOne:(NSString *)username notice:(Notice *)notice block:(EngineBlock()) engineBlock{
    BmobQuery *query = [BmobUser query];
    [query whereKey:@"username" equalTo:username];
    [query orderByDescending:@"updatedAt"];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            if (array.count == 1) {
                BmobUser *user       = [array firstObject];
                NSString *deviceType = [user objectForKey:@"deviceType"];
                BOOL isAndroid       = YES;
                if ([deviceType isEqualToString:@"ios"]) {
                    isAndroid = NO;
                }else{
                    isAndroid = YES;
                }
                NSString *userId    = [user objectForKey:@"pushUserId"];
                NSString *channelId = [user objectForKey:@"pushChannelId"];
                if (userId && userId.length > 0 && channelId && channelId.length > 0) {
                    [[self class] saveMessageWithUsername:username
                                                   userid:[user objectForKey:@"pushUserId"]
                                                channelId:[user objectForKey:@"pushChannelId"]
                                                   notice:notice
                                                isAndroid:isAndroid
                                                    block:^(id result, NSError *error) {
                                                        if (engineBlock) {
                                                            engineBlock(result,error);
                                                        }
                                                    }];
                }else{
                    NSError *error1 = [NSError errorWithDomain:@"www.bmob.cn"
                                                         code:4000 userInfo:@{@"error":@"队长未登录"}];
                    if (engineBlock) {
                        engineBlock(nil,error1);
                    }
                }
            }else{
                NSError *error1 = [NSError errorWithDomain:@"www.bmob.cn"
                                                      code:4001 userInfo:@{@"error":@"未发现队长"}];
                if (engineBlock) {
                    engineBlock(nil,error1);
                }
            }
        }else{
            if (engineBlock) {
                engineBlock(nil,error);
            }
        }
    }];
}

+(void)saveMessageWithUsername:(NSString *)username
                        userid:(NSString *)bpushUserid
                     channelId:(NSString *)channelId
                        notice:( Notice *)aNotice
                     isAndroid:(BOOL)android
                         block:(EngineBlock()) engineBlock{
    BmobObject *pushObject = [BmobObject objectWithClassName:kTablePushMsg];
    [pushObject setObject:@"" forKey:@"belongId"];
    [pushObject setObject:@"" forKey:@"belongNick"];
    [pushObject setObject:username forKey:@"belongUsername"];
    [pushObject setObject:aNotice.aps.alert forKey:@"content"];
    [pushObject setObject:[NSNumber numberWithInteger:[[NSNumber numberWithBool:NO] integerValue]] forKey:@"isRead"];
    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"status"];
    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"msgType"];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
    [extraDic removeObjectForKey:@"aps"];
    [extraDic removeObjectForKey:@"objectId"];
    [extraDic removeObjectForKey:@"status"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extraDic options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [pushObject setObject:jsonString forKey:@"extra"];
    
    [pushObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         if (engineBlock) {
             engineBlock(nil, error);
         }
         if (isSuccessful) {
             aNotice.objectId = pushObject.objectId;
             aNotice.aps.badge = 1;
             if (android) {
                 [[self class] sendMessageToOneAndroidUser:bpushUserid channelId:channelId  notice:aNotice];
             }else{
                 [[self class] sendMessageToOneiOSUser:bpushUserid channelId:channelId notice:aNotice];
             }
         }
     }];
}


#define msg_keys @"msgkey"

+(void)sendMessageToOneAndroidUser:(NSString *)userId channelId:(NSString *)channelId notice:(Notice *)notice{
    
    static int singlePerson = 1;
    static int phoneType  = 3;
    static int messageType = 0;
    
    NSString *url = @"https://channel.api.duapp.com/rest/2.0/channel/channel";
    NSString *method = @"POST";
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    tmpDic[@"method"] = @"push_msg";
    tmpDic[@"apikey"] = bPushApiKey;
    tmpDic[@"user_id"]= userId;
//    tmpDic[@"channel_id"] = channelId;
    tmpDic[@"push_type"] = [NSNumber numberWithInt:singlePerson];
    tmpDic[@"device_type"] = [NSNumber numberWithInt:phoneType];
    tmpDic[@"message_type"]= [NSNumber numberWithInt:messageType];
    NSString *string = [[[self class] turnNoticeToDictionary:notice isAndroid:YES] JSONString];
    tmpDic[@"messages"] = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    tmpDic[@"msg_keys"] = msg_keys;
    tmpDic[@"timestamp"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    
    tmpDic[@"sign"] = [[self class] encodeSign:tmpDic url:url method:method];
    
    
    [[self class] sendRequest:tmpDic url:url method:method];
    
}

+(void)sendMessageToOneiOSUser:(NSString *)userId channelId:(NSString *)channelId notice:(Notice *)notice{
    static int singlePerson = 1;
    static int phoneType  = 4;
    static int messageType = 1;
    
    int isDevelopment = PSPDFIsDevelopmentBuild()? 1:2;
    
    NSString *url = @"https://channel.api.duapp.com/rest/2.0/channel/channel";
    NSString *method = @"POST";
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
    tmpDic[@"method"] = @"push_msg";
    tmpDic[@"apikey"] = bPushApiKey;
    tmpDic[@"user_id"]= userId;
//    tmpDic[@"channel_id"] = channelId;
    tmpDic[@"push_type"] = [NSNumber numberWithInt:singlePerson];
    tmpDic[@"device_type"] = [NSNumber numberWithInt:phoneType];
    tmpDic[@"message_type"]= [NSNumber numberWithInt:messageType];
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithDictionary:[[self class] turnNoticeToDictionary:notice isAndroid:NO]] ;
    
    NSString *tmpContentString = [dic JSONString];
    if (tmpContentString.length > 256) {
        NSMutableDictionary *apsDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"aps"]];
        NSString *alertString = apsDic[@"alert"];
        alertString = [alertString stringByReplacingCharactersInRange:NSMakeRange(alertString.length-8, 8) withString:@"..."];
        apsDic[@"alert"] = alertString;
        dic[@"aps"] = apsDic;
    }
    NSString *string = [dic JSONString];
    tmpDic[@"messages"] = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//[dic JSONString];
    tmpDic[@"msg_keys"] = msg_keys;
    tmpDic[@"deploy_status"] = [NSNumber numberWithInt:isDevelopment];
    
    tmpDic[@"timestamp"] = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];

    tmpDic[@"sign"] = [[self class] encodeSign:tmpDic url:url method:method];
    
    
    [[self class] sendRequest:tmpDic url:url method:method];
}




+(NSDictionary *)turnNoticeToDictionary:(Notice *)aNotice isAndroid:(BOOL)android{

    NSMutableDictionary *pushDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
    [pushDic removeObjectForKey:@"status"];
    if (!android) {
        [pushDic removeObjectForKey:@"extra"];
        
    }else{
//        [pushDic removeObjectForKey:@"aps"];
//        [pushDic setObject:[[pushDic objectForKey:@"extra"] JSONString] forKey:@"extra"];
    }
    
    [pushDic setObject:SettingsPushFlagvalueNotice forKey:SettingsPushFlag];
    
    return pushDic;

}



+(void)sendMessageToiOSTeam:(NSString *)tag notice:(Notice *)aNotice{

}

+(void)sendMessageToAndroidTeam:(NSString *)tag notice:(Notice *)aNotice{

}



- (void)pushNotice:(Notice *)aNotice toUsername:(NSString *)username block:(EngineBlock()) engineBlock;
{
    BmobObject *pushObject = [BmobObject objectWithClassName:kTablePushMsg];
    [pushObject setObject:@"" forKey:@"belongId"];
    [pushObject setObject:@"" forKey:@"belongNick"];
    [pushObject setObject:username forKey:@"belongUsername"];
    [pushObject setObject:aNotice.aps.alert forKey:@"content"];
    [pushObject setObject:[NSNumber numberWithInteger:[[NSNumber numberWithBool:NO] integerValue]] forKey:@"isRead"];
    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"status"];
    [pushObject setObject:[NSNumber numberWithInteger:0] forKey:@"msgType"];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
    [extraDic removeObjectForKey:@"aps"];
    [extraDic removeObjectForKey:@"objectId"];
    [extraDic removeObjectForKey:@"status"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extraDic options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [pushObject setObject:jsonString forKey:@"extra"];
    
    [pushObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         if (engineBlock) {
             engineBlock(nil, error);
         }
         if (isSuccessful) {
             BmobPush *push = [BmobPush push];
             BmobQuery *query = [BmobInstallation query];
             [query whereKey:@"uid" equalTo:username];
             [push setQuery:query];
             aNotice.objectId =pushObject.objectId;
             //            [[NoticeManager sharedManager] saveNotice:aNotice];
             aNotice.aps.badge = 1;
             NSMutableDictionary *pushDic = [NSMutableDictionary dictionaryWithDictionary:[aNotice getDictionary]];
             [pushDic removeObjectForKey:@"status"];
             [pushDic removeObjectForKey:@"extra"];
             [pushDic setObject:SettingsPushFlagvalueNotice forKey:SettingsPushFlag];
             [push setData:pushDic];
             BDLog(@"******send push dictionary******%@", pushDic);
             [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                 if (!isSuccessful)
                 {
                     BDLog(@"******send push error******%@", error);
                 }
             }];
         }else
         {
             BDLog(@"******save push error******%@", error);
         }
     }];
}



static BOOL PSPDFIsDevelopmentBuild(void) {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    static BOOL isDevelopment = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // There is no provisioning profile in AppStore Apps.
        NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"]];
        
        if (data) {
            const char *bytes = [data bytes];
            NSMutableString *profile = [[NSMutableString alloc] initWithCapacity:data.length];
            for (NSUInteger i = 0; i < data.length; i++) {
                [profile appendFormat:@"%c", bytes[i]];
            }
            // Look for debug value, if detected we're a development build.
            NSString *cleared = [[profile componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
            isDevelopment = [cleared rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
        }
    });
    return isDevelopment;
#endif
}

@end

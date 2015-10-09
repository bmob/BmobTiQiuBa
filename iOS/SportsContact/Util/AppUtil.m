//
//  AppUtil.m
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "AppUtil.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <UIDevice+iAppInfos.h>

@implementation AppUtil
+ (NSString *)appVersion
{
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        version = [infoDict objectForKey:@"CFBundleVersion"];
    });
    
    return version;
}

+ (NSString *)appShortVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)systemName
{
    static NSString *name = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [UIDevice currentDevice].systemName;
    });
    return name;
}

+ (NSString *)systemVersion
{
    static NSString *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion;
    });
    
    return version;
}

//+ (NSString *)deviceId
//{
//    static NSString *deviceId = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        deviceId = nil;
//    });
//
//    return deviceId;
//}

+ (NSString *)deviceInfo
{
    return [UIDevice jmo_modelName];
}

+ (NSString *)systemInfo
{
    return [NSString stringWithFormat:@"ios%@",[self systemVersion]];
}


+ (NSString *)deviceType
{
    static NSString *deviceType = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        size_t size;
        
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        deviceType = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        
        if (deviceType.length <= 0)
        {
            deviceType = @"unknown";
        }
    });
    
    return deviceType;
}

+ (NSString *)mac
{
    static NSString *macAddress = nil;
    if (macAddress == nil)
    {
        int mib[] =
        {
            CTL_NET,
            AF_ROUTE,
            0,
            AF_LINK,
            NET_RT_IFLIST,
            if_nametoindex("en0")
        };
        
        //get message size
        size_t length = 0;
        if (mib[5] == 0 || sysctl(mib, 6, NULL, &length, NULL, 0) < 0 || length == 0)
        {
            return nil;
        }
        
        //get message
        NSMutableData *data = [NSMutableData dataWithLength:length];
        if (sysctl(mib, 6, [data mutableBytes], &length, NULL, 0) < 0)
        {
            return nil;
        }
        
        //get socket address
        struct sockaddr_dl *socketAddress = ([data mutableBytes] + sizeof(struct if_msghdr));
        unsigned char *coreAddress = (unsigned char *)LLADDR(socketAddress);
        macAddress = [[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X",
                      coreAddress[0], coreAddress[1], coreAddress[2],
                      coreAddress[3], coreAddress[4], coreAddress[5]];
    }
    return macAddress;
}

+ (NSString *)resolution
{
    static NSString *size = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [NSString stringWithFormat:@"%d*%d",(int)[UIScreen mainScreen].bounds.size.width,(int)[UIScreen mainScreen].bounds.size.height];
    });
    return size;
}

@end

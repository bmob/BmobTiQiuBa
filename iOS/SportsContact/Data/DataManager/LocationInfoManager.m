//
//  LocationInfoManager.m
//  SportsContact
//
//  Created by bobo on 14-7-18.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "LocationInfoManager.h"
#import "Util.h"


@interface LocationInfoManager()

@property (nonatomic, strong) PCDOptionInfo *pcdInfo; //省市区数组



@end

@implementation LocationInfoManager

+ (LocationInfoManager *)sharedManager
{
    static LocationInfoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[[LocationInfoManager class] alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 省市区
        NSDictionary *pcdDic = [Util dictionaryFromPListFile:@"pcd"];
        PCDOptionInfo *pcdInfo = [PCDOptionInfo infoWithDic:pcdDic];
        self.pcdInfo = pcdInfo;
    }
    return self;
}

- (LocationInfo *)locationInfoOfProvinceName:(NSString *)aProvinceName cityName:(NSString *)aCityName districtName:(NSString *)aDistrictName
{
    LocationInfo *info = [[LocationInfo alloc] init];
    PCDOptionInfo *pInfo = [self.pcdInfo subInfoOfName:aProvinceName];
    [info setProvinceCode:pInfo.regionInfo.key];
    [info setProvinceName:pInfo.regionInfo.value];
    PCDOptionInfo *cInfo = [pInfo subInfoOfName:aCityName];
    [info setCityCode:cInfo.regionInfo.key];
    [info setCityName:cInfo.regionInfo.value];
    PCDOptionInfo *dInfo = [cInfo subInfoOfName:aDistrictName];
    [info setDistrictCode:dInfo.regionInfo.key];
    [info setDistrictName:dInfo.regionInfo.value];
    return info;
}

- (LocationInfo *)locationInfoOfCode:(NSNumber *)code
{
    NSInteger codeInt = [code integerValue];
    if (codeInt < 110000 || codeInt > 999999) {
        return nil;
    }
    NSNumber  *provinceCode = [NSNumber numberWithInteger:codeInt - codeInt % 10000];
    
    LocationInfo *info = [[LocationInfo alloc] init];
    PCDOptionInfo *pInfo = [self.pcdInfo subInfoOfCode:provinceCode];
    [info setProvinceCode:pInfo.regionInfo.key];
    [info setProvinceName:pInfo.regionInfo.value];
    
    if (codeInt % 10000 > 0) {
        NSNumber *cityCode = [NSNumber numberWithInteger:codeInt - codeInt % 100];
        PCDOptionInfo *cInfo = [pInfo subInfoOfCode:cityCode];
        [info setCityCode:cInfo.regionInfo.key];
        [info setCityName:cInfo.regionInfo.value];
        
        if (codeInt % 100 > 0)
        {
            NSNumber *districtCode = [NSNumber numberWithInteger:codeInt];
            PCDOptionInfo *dInfo = [cInfo subInfoOfCode:districtCode];
            [info setDistrictCode:dInfo.regionInfo.key];
            [info setDistrictName:dInfo.regionInfo.value];
        }
    }
    return info;
}

- (LocationInfo *)locationInfoOfProvinceCode:(NSNumber *)aProvinceCode cityCode:(NSNumber *)aCityCode districtName:(NSNumber *)aDistrictCode
{
    LocationInfo *info = [[LocationInfo alloc] init];
    PCDOptionInfo *pInfo = [self.pcdInfo subInfoOfCode:aProvinceCode];
    [info setProvinceCode:pInfo.regionInfo.key];
    [info setProvinceName:pInfo.regionInfo.value];
    PCDOptionInfo *cInfo = [pInfo subInfoOfCode:aCityCode];
    [info setCityCode:cInfo.regionInfo.key];
    [info setCityName:cInfo.regionInfo.value];
    PCDOptionInfo *dInfo = [cInfo subInfoOfCode:aDistrictCode];
    [info setDistrictCode:dInfo.regionInfo.key];
    [info setDistrictName:dInfo.regionInfo.value];
    return info;
}

- (NSArray *)provinceArray
{
    return self.pcdInfo.namesArray;
}

- (NSArray *)cityArrayInProvince:(NSString *)aProvince
{
    return [self.pcdInfo subInfoOfName:aProvince].namesArray;
}

- (NSArray *)districtArrayInProvince:(NSString *)aProvince city:(NSString *)aCity
{
    return [[self.pcdInfo subInfoOfName:aProvince] subInfoOfName:aCity].namesArray;
}

@end

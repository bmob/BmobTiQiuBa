//
//  LocationInfoManager.h
//  SportsContact
//
//  Created by bobo on 14-7-18.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDef.h"

@interface LocationInfoManager : NSObject

+ (LocationInfoManager *)sharedManager;

/**
 *  获取省市区信息
 *
 *  @param code 代码
 *
 *  @return LocationInfo
 */
- (LocationInfo *)locationInfoOfCode:(NSNumber *)code;

/**
 *  获取省市区代码
 *
 *  @param aProvinceName 省名
 *  @param aCityName     市名
 *  @param aDistrictName 区名
 *
 *  @return LocationInfo
 */
- (LocationInfo *)locationInfoOfProvinceName:(NSString *)aProvinceName cityName:(NSString *)aCityName districtName:(NSString *)aDistrictName;

/**
 *  获取省市区名称
 *
 *  @param aProvinceCode 省代码
 *  @param aCityCode     市代码
 *  @param aDistrictCode 区代码
 *
 *  @return LocationInfo
 */
- (LocationInfo *)locationInfoOfProvinceCode:(NSNumber *)aProvinceCode cityCode:(NSNumber *)aCityCode districtName:(NSNumber *)aDistrictCode;

/**
 *  获取省列表
 *
 *  @return 省名称数组
 */
- (NSArray *)provinceArray;

/**
 *  获取市列表
 *
 *  @param aProvince 省名称
 *
 *  @return 市名称数组
 */
- (NSArray *)cityArrayInProvince:(NSString *)aProvince;
//- (NSArray *)cityArrayInProvinceCode:(NSNumber *)aProvinceCode;

/**
 *  获取区列表
 *
 *  @param aProvince 省名称
 *  @param aCity     市名称
 *
 *  @return 区名称数组
 */
- (NSArray *)districtArrayInProvince:(NSString *)aProvince city:(NSString *)aCity;
//- (NSArray *)districtArrayInProvinceCode:(NSNumber *)aProvinceCode city:(NSNumber *)aCityCode;



@end

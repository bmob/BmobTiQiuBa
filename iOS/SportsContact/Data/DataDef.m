//
//  DataDef.m
//  SportsContact
//
//  Created by bobo on 14-7-11.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "DataDef.h"

NSString *positioningTypeStringFromEnum(PositioningType enumValue)
{
    switch (enumValue) {
        case PositioningTypeGoalkeeper:
            return @"守门员";
            break;
        case PositioningTypeBack:
            return @"后卫";
            break;
        case PositioningTypeMidfielder:
            return @"中场";
            break;
        case PositioningTypeForward:
            return @"前锋";
            break;
        default:
            return @"";
            break;
    }
}

NSString *begoodTypeStringFromEnum(BegoodType enumValue)
{
    switch (enumValue) {
        case BegoodTypeLeft:
            return @"左脚";
            break;
        case BegoodTypeRight:
            return @"右脚";
            break;
        case BegoodTypeAll:
            return @"左右开弓";
            break;
        default:
            return @"";
            break;
    }
}

NSString *tournamentTypeStringFromEnum(TournamentType enumValue)
{
    switch (enumValue) {
        case TournamentTypeGroup:
            return @"小组赛";
            break;
        case TournamentTypeKnockout:
            return @"淘汰赛";
            break;
        case TournamentTypeFriendly:
            return @"友谊赛";
            break;
        default:
            return @"友谊赛";
            break;
    }
}


@implementation UserInfo


@end

@implementation Team


@end

//@implementation PushMsg
//
//@end

@implementation ApsInfo

+ (ApsInfo *)apsInfoWithAlert:(NSString *)aAlert badge:(NSInteger)aBadge sound:(NSString *)aSound
{
    ApsInfo *aps = [[ApsInfo alloc] init];
    aps.alert = aAlert;
    aps.badge = aBadge;
    aps.sound = aSound;
    return aps;
}

- (NSDictionary *)getDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.alert ? self.alert : @"" forKey:@"alert"];
    [dic setObject:[NSNumber numberWithInteger:self.badge] forKey:@"badge"];
    [dic setObject:self.sound ? self.sound : @"" forKey:@"sound"];
    return [NSDictionary dictionaryWithDictionary:dic];
}

- (NSString *)getString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self getDictionary] options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.alert = [dictionary objectForKey:@"alert"] != [NSNull null] ? [dictionary objectForKey:@"alert"] : nil;
        self.badge = [[dictionary objectForKey:@"badge"] integerValue];
        self.sound = [dictionary objectForKey:@"sound"] != [NSNull null] ? [dictionary objectForKey:@"sound"] : nil;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err) {
            BDLog(@"******strong to json err******%@", err);
        }
        self.alert = [dictionary objectForKey:@"alert"] != [NSNull null] ? [dictionary objectForKey:@"alert"] : nil;
        self.badge = [[dictionary objectForKey:@"badge"] integerValue];
        self.sound = [dictionary objectForKey:@"sound"] != [NSNull null] ? [dictionary objectForKey:@"sound"] : nil;
    }
    return self;
}

@end


@implementation Notice

-(id)copyWithZone:(NSZone *)zone{
    Notice *copyNotice = [[Notice allocWithZone:zone] init];
    copyNotice.aps = self.aps;
    copyNotice.belongId = self.belongId;
    copyNotice.targetId = self.targetId;
    copyNotice.title = self.title;
    copyNotice.time = self.time;
    copyNotice.type = self.type;
    copyNotice.subtype = self.subtype;
    copyNotice.status = self.status;
    copyNotice.extra = self.extra;
    
    return copyNotice;
}

- (NSDictionary *)getDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.objectId ? self.objectId : @"" forKey:@"objectId"];
    [dic setObject:[self.aps getDictionary] forKey:@"aps"];
    [dic setObject:self.belongId ? self.belongId : @"" forKey:@"belongId"];
    [dic setObject:self.targetId ? self.targetId : @"" forKey:@"targetId"];
    [dic setObject:self.title ? self.title : @"" forKey:@"title"];
//    [dic setObject:self.content ? self.content : @"" forKey:@"content"];
    [dic setObject:[NSNumber numberWithInteger:self.time] forKey:@"time"];
    [dic setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    [dic setObject:[NSNumber numberWithInteger:self.subtype] forKey:@"subtype"];
    [dic setObject:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    if (self.extra)
    {
        [dic setObject:self.extra forKey:@"extra"];
    }
    return [NSDictionary dictionaryWithDictionary:dic];
}

- (NSString *)getString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self getDictionary] options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        [self setUpPropertyWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        id dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self setUpPropertyWithDictionary:dictionary];
    }
    return self;
}

- (void)setUpPropertyWithDictionary:(id)dictionary
{
    self.objectId = [dictionary objectForKey:@"objectId"] != [NSNull null] ? [dictionary objectForKey:@"objectId"] : nil;
    if ([[dictionary objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
        self.aps = [[ApsInfo alloc] initWithDictionary:[dictionary objectForKey:@"aps"]];
    }else if([[dictionary objectForKey:@"aps"] isKindOfClass:[NSString class]])
    {
        self.aps = [[ApsInfo alloc] initWithString:[dictionary objectForKey:@"aps"]];
    }else
    {
        self.aps = [dictionary objectForKey:@"aps"];
    }
    self.belongId = [dictionary objectForKey:@"belongId"] != [NSNull null] ? [dictionary objectForKey:@"belongId"] : nil;
    self.targetId = [dictionary objectForKey:@"targetId"] != [NSNull null] ? [dictionary objectForKey:@"targetId"] : nil;
    self.title = [dictionary objectForKey:@"title"] != [NSNull null] ? [dictionary objectForKey:@"title"] : nil;
//    self.content = [dictionary objectForKey:@"content"] != [NSNull null] ? [dictionary objectForKey:@"content"] : nil;
    self.time = [[dictionary objectForKey:@"time"] integerValue];
    self.type = [[dictionary objectForKey:@"type"] integerValue];
    self.subtype = [[dictionary objectForKey:@"subtype"] integerValue];
    self.status = [[dictionary objectForKey:@"status"] integerValue];
    if ([[dictionary objectForKey:@"extra"] isKindOfClass:[NSString class]]) {
        NSData *data = [[dictionary objectForKey:@"extra"] dataUsingEncoding:NSUTF8StringEncoding];
        id dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.extra = dictionary;
    }else
    {
         self.extra = [dictionary objectForKey:@"extra"];
    }
   
}

@end

@implementation LocationInfo

- (id)copyWithZone:(NSZone *)zone
{
    LocationInfo *newObj =  [LocationInfo allocWithZone:zone];
    newObj.provinceCode = self.provinceCode;
    newObj.provinceName = self.provinceName;
    newObj.cityCode = self.cityCode;
    newObj.cityName = self.cityName;
    newObj.districtCode = self.districtCode;
    newObj.districtName = self.districtName;
    return newObj;
}
@end

@implementation Lineup

@end


@implementation League

@end

@implementation Tournament

@end

@implementation TeamScore

@end


@implementation PlayerScore

@end

@implementation Comment

@end


@implementation LeagueScoreStat

@end




@implementation OptionInfo

+ (OptionInfo *)optionWithKey:(NSNumber *)aKey value:(NSString *)aValue
{
    OptionInfo *option = [[OptionInfo alloc] init];
    [option setValue:aValue];
    [option setKey:aKey];
    return option;
}

- (NSString *)description
{
    return self.value;
}

@end

@implementation PCDOptionInfo

+ (PCDOptionInfo *)infoWithDic:(NSDictionary *)aDic
{
    PCDOptionInfo *info = [[PCDOptionInfo alloc] init];
    
    OptionInfo *option = [[OptionInfo alloc] init];
    [option setValue:aDic[@"value"]];
    [option setKey:aDic[@"key"]];
    [info setRegionInfo:option];
    
    NSArray *array = aDic[@"sub"];
    if (array != nil)
    {
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in array)
        {
            PCDOptionInfo *subInfo = [PCDOptionInfo infoWithDic:dic];
            [subArray addObject:subInfo];
        }
        [info setSubArray:[NSArray arrayWithArray:subArray]];
    }
    return info;
}

- (NSArray *)optionsArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (PCDOptionInfo *info in self.subArray)
    {
        [array addObject:info.regionInfo];
    }
    if (array.count == 0) {
        return nil;
    }
    return array;
}

- (NSArray *)namesArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (PCDOptionInfo *info in self.subArray)
    {
        [array addObject:info.regionInfo.value];
    }
    if (array.count == 0) {
        return nil;
    }
    return array;
}

- (PCDOptionInfo *)subInfoOfName:(NSString *)aName
{
    if (aName.length <=0)
    {
        return nil;
    }
    for (PCDOptionInfo *info in self.subArray)
    {
        NSRange range = [info.regionInfo.value rangeOfString:aName];
        if (range.length > 0)
        {
            return info;
        }
    }
    return nil;
}

- (PCDOptionInfo *)subInfoOfCode:(NSNumber *)aCode
{
    for (PCDOptionInfo *info in self.subArray)
    {
        if ([aCode isEqualToNumber:info.regionInfo.key])
        {
            return info;
        }
    }
    return nil;
}
@end
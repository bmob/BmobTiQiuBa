//
//  AppSettings.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings


+ (NSString *)stringOfKey:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stringValue = [defaults stringForKey:aKey];
    return stringValue;
}

+ (void)setString:(NSString *)aString forKey:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aString forKey:aKey];
}

+ (BOOL)boolOfKey:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL boolValue = [defaults boolForKey:aKey];
    return boolValue;
}

+ (void)setBool:(BOOL)aBool forKey:(NSString *)aKey
{
    if (aKey.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:aBool forKey:aKey];
}

+ (NSNumber *)numberOfKey:(NSString *)aKey
{
    if (aKey.length <= 0) {
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *numberValue = [defaults objectForKey:aKey];
    return numberValue;
}

+ (void)setNumber:(NSNumber *)aNumber forKey:(NSString *)aKey
{
    if (aKey.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aNumber forKey:aKey];
}

+ (NSDictionary *)dictionaryOfKey:(NSString *)aKey
{
    if (aKey.length <= 0) {
        return 0;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [defaults objectForKey:aKey];
    return dictionary;
}

+ (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey
{
    if (aKey.length <= 0) {
        return;
    }
    
    NSDictionary *newDic = [self objectFromObject:aDictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newDic forKey:aKey];
}

+ (id)objectFromObject:(id)aObject
{
    if ([aObject isKindOfClass:[NSString class]] || [aObject isKindOfClass:[NSNumber class]])
    {
        return aObject;
    }
    else if ([aObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *newArray = [NSMutableArray array];
        for (id arrayObj in aObject)
        {
            id object = [self objectFromObject:arrayObj];
            if (object != nil)
            {
                [newArray addObject:object];
            }
        }
        return newArray;
    }
    else if ([aObject isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
        for (NSString *key in [aObject allKeys])
        {
            id object = [self objectFromObject:[aObject objectForKey:key]];
            if (object != nil)
            {
                [newDic setObject:object forKey:key];
            }
        }
        return newDic;
    }
    
    return nil;
}

+ (NSData *)dataOfKey:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:aKey];
    return data;
}

+ (void)setData:(NSData *)aData forKey:(NSString *)aKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aData forKey:aKey];
}

+ (NSDictionary *)dictionaryFromPListFile:(NSString *)aPListFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:aPListFile ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dictionary;
}

+ (void)synchronize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}

+ (void)removeObjectForKey:(NSString *)aKey;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:aKey];
}


@end

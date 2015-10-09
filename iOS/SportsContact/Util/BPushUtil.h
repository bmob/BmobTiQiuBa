//
//  BPushUtil.h
//  SportsContact
//
//  Created by Bmob on 15-1-27.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AppSettings.h"
#import "DataDef.h"

@interface BPushUtil : NSObject


+(void)setTags:(NSArray *)tags;

+(void)deleteTags:(NSArray *)tags;

+(void)sendMessageToOne:(NSString *)username notice:(Notice *)notice block:(EngineBlock()) engineBlock;

@end

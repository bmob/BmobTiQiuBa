//
//  NoticeManager.h
//  SportsContact
//
//  Created by bobo on 14-8-15.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDef.h"

@interface NoticeManager : NSObject

+ (void)updatePushProfile;

+ (instancetype)sharedManager;

- (void)bindDB;     // 登陆之后绑定DB
- (void)unbindDB;   // 注销之后解绑DB

- (void)pushNotice:(Notice *)aNotice toUsername:(NSString *)username;
- (void)pushNotice:(Notice *)aNotice toUsername:(NSString *)username block:(EngineBlock()) engineBlock;

- (void)pushNotice:(Notice *)aNotice toTeam:(NSString *)teamId;

- (void)saveNotice:(Notice *)aNotice;

//- (void)readNoticeListFinished:(void (^)(NSArray *noticeList))aFinishBlock;
- (void)readLeagueNoticeListFinished:(void (^)(NSArray *noticeList))aFinishBlock;

- (void)deleteNotice:(Notice *)aNotice;

//-(void)updateAllNoticesRead;

- (void)markNoticeDisposed:(Notice *)aNotice;

- (void)readUnreadCountFinished:(void (^)(NSInteger count))aFinishBlock;
- (void)readNoticeListFromDiskFinished:(void (^)(NSArray *noticeList))aFinishBlock;
- (void)readNoticeListFromWebFinished:(void (^)(NSArray *noticeList))aFinishBlock;

@end

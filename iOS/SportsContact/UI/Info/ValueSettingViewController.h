//
//  ValueSettingViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-20.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseViewController.h"

@protocol ValueSettingDelegate;

@interface ValueSettingViewController : BaseViewController

@property (nonatomic, strong) id<ValueSettingDelegate> delegate;
@property (assign, nonatomic) NSUInteger wordLimit;//输入字数控制


@end


@protocol ValueSettingDelegate <NSObject>

@required
- (void)valueSetting:(id)valueSelection didSaveValue:(NSString *)value;

@end
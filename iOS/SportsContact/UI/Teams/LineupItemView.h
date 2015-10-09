//
//  LineupItemView.h
//  SportsContact
//
//  Created by bobo on 14-8-19.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataDef.h"

@protocol LineupItemViewDelegate;

@interface LineupItemView : UIView
@property (weak, nonatomic) IBOutlet UIButton *controll;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) id<LineupItemViewDelegate> delegate;
@property (nonatomic, strong) UserInfo *userInfo;

@end


@protocol LineupItemViewDelegate <NSObject>

- (void)onClickAtlineupItemView:(LineupItemView *)lineupItemView;

@end
//
//  LineupItemView.m
//  SportsContact
//
//  Created by bobo on 14-8-19.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "LineupItemView.h"
#import "ViewUtil.h"
#import <UIImageView+WebCache.h>

@implementation LineupItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *view =  LoadNibOwner(@"LineupItemView", self);
        self.bounds = view.bounds;
        view.frame = self.bounds;
        [self addSubview:view];
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height / 2.0;
    }
    return self;
}

- (void)setUserInfo:(UserInfo *)userInfo
{
    _userInfo = userInfo;
    if (userInfo) {
        self.nameLabel.text = userInfo.nickname;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avator.url] placeholderImage:[UIImage imageNamed:@"lineup_men.png"] completed:nil];
    }else
    {
        self.nameLabel.text = @"暂无";
        self.avatarImageView.image = [UIImage imageNamed:@"lineup_men.png"];
    }
}
- (IBAction)onClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onClickAtlineupItemView:)])
    {
        [self.delegate onClickAtlineupItemView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

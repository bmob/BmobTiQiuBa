//
//  GamescoreTipView.m
//  SportsContact
//
//  Created by Bmob on 15-3-12.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "GamescoreTipView.h"

@implementation GamescoreTipView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.7f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"first_score_in"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

@end

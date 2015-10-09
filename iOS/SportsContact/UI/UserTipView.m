//
//  UserTipView.m
//  SportsContact
//
//  Created by Bmob on 15-3-11.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "UserTipView.h"
#import "ViewUtil.h"

@implementation UserTipView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
//    NSLog(@"awakeFromNib");
}


//- (IBAction)hide:(id)sender {
//    [UIView animateWithDuration:0.5f animations:^{
//        self.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
//}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.7f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"first_user_in"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}


@end

//
//  PageScrollView.m
//  SportsContact
//
//  Created by Bmob on 15-3-13.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "PageScrollView.h"

@implementation PageScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)] ;
//      [tapGesure  setCancelsTouchesInView:NO];
//        self.canCancelContentTouches = NO;
        [self addGestureRecognizer:tapGesure];
        self.delaysContentTouches = YES;
    }
    
    return self ;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"begin");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    [super touchesEnded:touches withEvent:event];
    
}

-(void)hide{
    [UIView animateWithDuration:0.7f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

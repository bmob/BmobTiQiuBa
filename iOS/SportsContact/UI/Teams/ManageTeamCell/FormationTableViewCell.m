//
//  FormationTableViewCell.m
//  SportsContact
//
//  Created by Nero on 7/28/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "FormationTableViewCell.h"

@implementation FormationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    [self.teamMemberScrollview setContentSize:CGSizeMake(197.0, 180.0)];
    
  //  [self performSelector:@selector(updateScrollView) withObject:nil afterDelay:0.0f];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setLineup:(Lineup *)lineup
{
    _lineup = lineup;
    NSMutableString *names = [[NSMutableString alloc] init];
    
    if (lineup.goalkeeper) {
        [names appendString:lineup.goalkeeper.nickname];
        [names appendString:@"  "];
    }
    for (UserInfo *user in (NSArray *)lineup.back)
    {
        [names appendString:user.nickname];
        [names appendString:@"  "];
    }
    for (UserInfo *user in (NSArray *)lineup.striker)
    {
        [names appendString:user.nickname];
        [names appendString:@"  "];
    }
    for (UserInfo *user in (NSArray *)lineup.forward)
    {
        [names appendString:user.nickname];
        [names appendString:@"  "];
    }
    if ([names isEqualToString:@""]) {
        self.namesLabel.text = @"暂无阵容信息";
        
        
        
    //判断是不是队长,是队长的话，
        if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
        {
            self.userInteractionEnabled=YES;
        }
        else
        {
            self.userInteractionEnabled=NO;
        }
        
        
        
    }else
    {
        self.namesLabel.text = names;
        self.userInteractionEnabled=YES;

    }
}


- (void) updateScrollView
{
    [myTimer invalidate];
    myTimer = nil;
    //time duration
    NSTimeInterval timeInterval = 5;
    //timer
    myTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                             selector:@selector(handleMaxShowTimer:)
                                             userInfo: nil
                                              repeats:YES];
}



- (void)handleMaxShowTimer:(NSTimer*)theTimer
{
    
    int currentPage = self.teamMemberScrollview.contentOffset.y/90;


    if(currentPage==0)
    {
        
        [self.teamMemberScrollview setContentOffset:CGPointMake(0, 0)];
        
        [self.teamMemberScrollview scrollRectToVisible:CGRectMake(90,90,197,90) animated:YES];
    }
    else
    {
        [self.teamMemberScrollview scrollRectToVisible:CGRectMake(90,0,197,90) animated:YES];
    }
    
}




#pragma mark   scrollview delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    
//    //禁止手动
//    int currentPage = self.teamMemberScrollview.contentOffset.y/90;
//    
//    
//    if(currentPage==0)
//    {
//        
//        [self.teamMemberScrollview setContentOffset:CGPointMake(0, 0)];
//        
//        [self.teamMemberScrollview scrollRectToVisible:CGRectMake(90,90,197,90) animated:YES];
//    }
//    else
//    {
//        [self.teamMemberScrollview scrollRectToVisible:CGRectMake(90,0,197,90) animated:YES];
//    }

    
}






@end

//
//  AuthFailViewController.m
//  SportsContact
//
//  Created by Bmob on 15-2-12.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "AuthFailViewController.h"
#import <BmobSDK/Bmob.h>
#import "MatchEngine.h"
#import "TeamEngine.h"
#import "ScoreManagerViewController.h"
#import "DateUtil.h"

@interface AuthFailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

@end

@implementation AuthFailViewController

@synthesize tournamentID = _tournamentID;
@synthesize teamID = _teamID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self performSelector:@selector(loadTournameScore) withObject:nil afterDelay:0.1f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.updateButton.enabled = YES;
}


-(void)loadTournameScore{
    [self showLoadingView];
    BmobQuery *query = [BmobQuery queryWithClassName:@"Tournament"];
    [query includeKey:@"home_court,opponent"];
//    __weak typeof(BmobQuery *) weakQuery = query;
    __weak typeof(self)weakSelf = self;
    [query getObjectInBackgroundWithId:self.tournamentID
                                 block:^(BmobObject *object, NSError *error) {
                                     __strong typeof(self)strongSelf= weakSelf;
                                     [strongSelf hideLoadingView];
                                     if (error) {
                                         
                                     }else{
                                         BmobObject *homeObj = [object objectForKey:@"home_court"];
                                         strongSelf.homeTeamLabel.text = [homeObj objectForKey:@"name"];
                                         BmobObject *opponentObj = [object objectForKey:@"opponent"];
                                         strongSelf.opponentTeamLabel.text = [opponentObj objectForKey:@"name"];
                                         
                                         NSString *hString = @"0";
                                         if ([object objectForKey:@"score_h"]) {
                                             hString = [[object objectForKey:@"score_h"] description];
                                         }
                                         NSString *h2String = @"0";
                                         if ([object objectForKey:@"score_h2"] ) {
                                             h2String = [[object objectForKey:@"score_h2"] description];
                                         }
                                         strongSelf.homeTeamScoreLabel.text = [NSString stringWithFormat:@"%@-%@",hString,h2String];
                                         NSString *oString = @"0";
                                         if ([object objectForKey:@"score_o"]) {
                                             oString = [[object objectForKey:@"score_o"] description];
                                         }
                                         NSString *o2String = @"0";
                                         if ([object objectForKey:@"score_o2"]) {
                                             o2String = [[object objectForKey:@"score_o2"] description];
                                         }
                                         strongSelf.opponentTeamScoreLabel.text = [NSString stringWithFormat:@"%@-%@",o2String,oString];;
                                         
                                         if ([hString isEqualToString:oString] && [h2String isEqualToString:o2String]) {
                                             strongSelf.updateButton.enabled = NO;
                                             strongSelf.title = @"认证成功";
                                         }
                                     }
                                 }];
}


- (IBAction)gotoScoreManage:(id)sender {
    [MatchEngine getMatchWithMatchId:self.tournamentID block:^(Tournament *tournament, NSError *error) {
        
        if (error) {
            [self hideLoadingView];
            [self showMessage:@"用户信息加载错误"];
        }else
        {
            [TeamEngine getInfoWithTeamId:self.teamID block:^(Team *team, NSError *error) {
                [self hideLoadingView];
                if (error) {
                    [self showMessage:@"比赛信息加载错误"];
                }else
                {
                    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
                    ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
                    scoreViewController.match = tournament;
                    scoreViewController.team = team;
                    if ([[NSDate dateFromServer] timeIntervalSince1970] > [tournament.start_time timeIntervalSince1970]) {
                        scoreViewController.canEdit = YES;
                    }
                    scoreViewController.userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                    [self.navigationController pushViewController:scoreViewController animated:YES];
                    
                    UIButton *tmpButton = (UIButton *)sender;
                    tmpButton.enabled = NO;
                }
            }];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

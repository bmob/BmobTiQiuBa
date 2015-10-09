//
//  ShooterboardViewController.m
//  SportsContact
//
//  Created by Nero on 8/16/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "ShooterboardViewController.h"
#import "Util.h"
#import "ViewUtil.h"
#import "LeagueEngine.h"


@interface ShooterboardViewController ()
//@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic)  NSMutableArray *playerScoreArr;


@end

@implementation ShooterboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadShooterboard:self.leagueId];
    self.tableView.scrollsToTop=YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/






-(void)loadShooterboard:(NSString *)leagueId
{
    
    [self showLoadingView];
    [LeagueEngine getPlayerscoreWithLeagueId:leagueId block:^(id result, NSError *error) {
        
        
        self.playerScoreArr=result;
        
        
        if ([self.playerScoreArr count]!=0 )
        {
            [self.tableView reloadData];
            
        }
        else
        {
            
            UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
            warningLabel.text = @"联赛射手榜暂无信息！";
            warningLabel.textColor = [UIColor blackColor];
            warningLabel.textAlignment = NSTextAlignmentCenter;
            warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            [self.view addSubview:warningLabel];
        }

        
        

        [self hideLoadingView];
        
    }];
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
    [headerView addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300.0, 22.0f)];
    titleLabel.text = self.leagueName;
    titleLabel.textColor = UIColorFromRGB(0x898989);
    titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [headerView addSubview:titleLabel];
    
    return headerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 21;
    }
    else
    {
        return 25;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.playerScoreArr count]+1;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (indexPath.row==0)
    {
        cell=[tableView dequeueReusableCellWithIdentifier:@"ShooterLabelCell"];
        
    }
    else
    {
        
        
        PlayerScore *playerscore=[self.playerScoreArr objectAtIndex:indexPath.row-1];
        
        
        cell=[tableView dequeueReusableCellWithIdentifier:@"ShooterNumberCell"];
        
        
        
        UILabel *rankLabel = (id)[cell.contentView viewWithTag:1];
        rankLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        
        UILabel *playerNameLabel = (id)[cell.contentView viewWithTag:2];
        playerNameLabel.text=playerscore.player.nickname;
        
        
        UILabel *teamNameLabel = (id)[cell.contentView viewWithTag:3];
        teamNameLabel.text=playerscore.team.name;
        
        UILabel *goalsLabel = (id)[cell.contentView viewWithTag:4];
        goalsLabel.text=[playerscore.goals stringValue];

        

        
    }
    
    
    if (indexPath.row%2 == 0) {
        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"ffffff"];
    }else{
        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"f1f2f4"];
    }
    
    
    
    
    
    
    
    return cell;
    
    
}


















@end


















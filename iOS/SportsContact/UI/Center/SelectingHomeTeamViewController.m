//
//  SelectingHomeTeamViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "SelectingHomeTeamViewController.h"
#import "MatchEngine.h"
#import "InfoEngine.h"

@interface SelectingHomeTeamViewController ()

@property (nonatomic, strong) NSArray *teams;

@end

@implementation SelectingHomeTeamViewController

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
     self.title = @"选择主队";
    [self showLoadingView];
    [InfoEngine getTeamsWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.teams = result;
             [self.tableView reloadData];
         }
     }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"push_opponent"]) {
        [segue.destinationViewController setValue:self.match forKey:@"match"];
        [segue.destinationViewController setValue:self.teams forKey:@"homeCourtTeams"];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"team_cell" forIndexPath:indexPath];
    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF0];
    nameLabel.text = [[self.teams objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.match.home_court = [self.teams objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"push_opponent" sender:nil];
}

@end

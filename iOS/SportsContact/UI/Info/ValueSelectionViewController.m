//
//  ValueSelectionViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-20.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "ValueSelectionViewController.h"
#import "Util.h"

@interface ValueSelectionViewController ()

@property (nonatomic) NSInteger selectIndex;

@end

@implementation ValueSelectionViewController

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
    
//    self.selectIndex = NSNotFound;
    [self.tableView reloadData];
    
    NSString *buttonTitle = self.buttonTitle ? self.buttonTitle : @"保存";
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:buttonTitle forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSave:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(valueSelection:didSaveAtIndex:)]) {
        [self.delegate valueSelection:self didSaveAtIndex:self.selectIndex];
    }
    [self.navigationController popViewControllerAnimated:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value_cell"];
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF0];
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF1];
    
    BOOL isLast = indexPath.row == self.dataSource.count - 1;
    line1.hidden = isLast;
    line2.hidden = !isLast;
    
    UILabel *label = (id)[cell.contentView viewWithTag:0xF2];
    label.text = [self.dataSource objectAtIndex:indexPath.row];
    
    UIImageView *choseView = (id)[cell.contentView viewWithTag:0xF3];
    if (self.selectIndex == indexPath.row) {
        choseView.hidden = NO;
    }else
    {
        choseView.hidden = YES;
         BDLog(@"SelectIndex is %@", self.selectIndex == indexPath.row ? @"YES" : @"NO");
    }
//    choseView.hidden = !self.selectIndex == indexPath.row;
   
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndex = indexPath.row;
    [tableView reloadData];
}

@end

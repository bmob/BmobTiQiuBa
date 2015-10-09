//
//  CommentViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "CommentViewController.h"
#import "Util.h"
#import "MatchEngine.h"
#import "NoticeManager.h"

#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>
#import "PickerViewController.h"

#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"



@interface CommentViewController () <UITextFieldDelegate, PickerViewControllerDelegate>

@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) Comment *comment;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UILabel *scoreLabel;





@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;

@property (assign) CGFloat averageScore;
@end

@implementation CommentViewController

@synthesize averageScore = _averageScore;

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
    if ([self.userInfo.objectId isEqualToString:[[BmobUser getCurrentUser] objectId]]) {
        self.needInputCell = NO;
    }
    [self.tableView reloadData];
    self.title = self.userInfo.nickname;
    

    if (self.needInputCell)
    {
        UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
        [rButton setTitle:@"发布" forState:UIControlStateNormal];
        [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    }else{
        
    }
    [self callAverageScore];
    [self loadData];
     // Do any additional setup after loading the view.
    
    //监听文字输入,限制字符串输入
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self.textField];
}


-(void)textFiledEditChanged:(NSNotification *)obj
{
    //    UITextField *textField = (UITextField *)obj.object;
    int wordLimit = 30;
    NSString *toBeString = self.textField.text;
    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"])
    {
        // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self.textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        
        if (!position)
        {
            if (toBeString.length > wordLimit)
            {
                self.textField.text = [toBeString substringToIndex:wordLimit];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > wordLimit)
        {
            self.textField.text = [toBeString substringToIndex:wordLimit];
        }
    }
}


- (void)loadData
{
    [self showLoadingView];
    [MatchEngine getCommentsWithAcceptUserId:self.userInfo.objectId tournamentId:self.match.objectId block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             
             NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
             for (Comment *comment in result)
             {
                 if ([comment.komm.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
                 {
                     continue ;
                 }
                 [array addObject:comment];
             }
             self.comments = array;
             if (self.needInputCell)
             {
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
             }else
             {
                 [self.tableView reloadData];
             }
         }
     }];
    
    if (self.needInputCell)
    {
        [self showLoadingView];
        [MatchEngine getCommentWithAcceptUserId:self.userInfo.objectId
                                     kommUserId:[[BmobUser getCurrentUser] objectId]
                                   tournamentId:self.match.objectId block:^(id result, NSError *error){
                                         [self hideLoadingView];
                                         if (error) {
                                             [self showMessage:[Util errorStringWithCode:error.code]];
                                         }else
                                         {
                                             self.comment = result;
                                             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                                         }
                                   }];
    }
}

- (void)callCommentScore
{
    [self showLoadingView];
    [BmobCloud callFunctionInBackground:@"commentScore" withParameters:@{@"objectId": self.userInfo.objectId} block:^(id object, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             [self showMessage:@"保存成功"];
             [self performRunnable:^{
                 Notice *msg = [[Notice alloc] init];
                 UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                 NSString *content = [NSString stringWithFormat:@"队友更新了您最近一场比赛的评分"];
                 msg.subtype = NoticeSubtypeMarking;
                 msg.targetId = [NSString stringWithFormat:@"%@&%@", self.userInfo.objectId, self.match.objectId];
                 msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                 msg.time = [[NSDate date] timeIntervalSince1970];
                 msg.belongId = selfUser.username;
                 msg.title = selfUser.nickname ? selfUser.nickname : selfUser.username;
                 msg.type = NoticeTypePersonal;
                 [[NoticeManager sharedManager] pushNotice:msg toUsername:self.userInfo.username];
                 [self.navigationController popViewControllerAnimated:YES];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kObserverCommentScoreChanged object:nil];
             } afterDelay:1.5];
             
         }else
         {
//             BDLog(@"**********Call commentScore err :%@",  error);
             [self showMessage:@"保存失败"];
         }
     }] ;
}

- (void)updatePlayerScore
{
    if (!self.playerScore) {
        [self callCommentScore];
        return ;
    }
    NSMutableArray *allComments = [[NSMutableArray alloc] initWithArray:self.comments];
    [allComments addObject:self.comment];
    double allscore = 0;
    for (Comment *comment in allComments) {
        allscore += [comment.score integerValue];
    }
    BmobObject *playerScore = [BmobObject objectWithoutDatatWithClassName:kTablePlayerScore objectId:self.playerScore.objectId];
    NSString *floatString = [NSString stringWithFormat:@"%.1f", allscore/(float)[allComments count]];
    [playerScore setObject:[NSNumber numberWithFloat:[floatString floatValue]] forKey:@"avg"];
    [playerScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if(isSuccessful)
        {
            [self callCommentScore];
        }else
        {
            [self showMessage:@"保存失败"];
        }
    }];
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

-(void)callAverageScore{
    BmobQuery *query = [BmobQuery queryWithClassName:kTablePlayerScore];
    [query whereKey:@"player" equalTo:[BmobUser objectWithoutDatatWithClassName:nil
                                                                       objectId:self.userInfo.objectId]];
    [query whereKey:@"competition" equalTo:[BmobObject objectWithoutDatatWithClassName:kTableTournament
                                                                              objectId:self.match.objectId]];
    query.limit = 1;
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count == 1) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BmobObject *obj = [array firstObject];
            strongSelf.averageScore = [[obj objectForKey:@"avg"] floatValue];
            
            [strongSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
    [headerView addSubview:bgView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300.0, 22.0f)];
    titleLabel.textColor = UIColorFromRGB(0x898989);
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [headerView addSubview:titleLabel];
    
    UILabel *avgLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 50.0, 22.0f)];
    avgLabel.textColor = UIColorFromRGB(0x898989);
    avgLabel.font = [UIFont systemFontOfSize:14.0f];
    avgLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:avgLabel];
    
    
    if (self.needInputCell && section == 0  )
    {
        NSString *name = self.userInfo.nickname ? self.userInfo.nickname:self.userInfo.username;
        titleLabel.text = [NSString stringWithFormat:@"根据%@本场比赛的表现，您对他的评分", name];
        avgLabel.text  = @"";
    }else
    {
        NSString *name = self.userInfo.nickname ? self.userInfo.nickname:self.userInfo.username;
        titleLabel.text = [NSString stringWithFormat:@"%@本场比赛获得的评分", name];
        avgLabel.text = [NSString stringWithFormat:@"%.2f",self.averageScore];//@"0.00";
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.needInputCell && indexPath.section == 0)
    {
         return 173.0f;;
    }else
    {
         return 54.0f;;
    }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.needInputCell) {
        return 2;
    }else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.needInputCell && section == 0)
    {
        return 1;
    }else
    {
        return [self.comments count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //comment_cell
     UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (self.needInputCell && indexPath.section == 0)
    {
         cell = [tableView dequeueReusableCellWithIdentifier:@"input_cell" forIndexPath:indexPath];
        self.textField = (id)[cell.contentView viewWithTag:0xF1];
        self.textField.text = self.comment.comment;
        self.scoreLabel = (id)[cell.contentView viewWithTag:0xF0];
        self.scoreLabel.text = [NSString stringWithFormat:@"%@",self.comment.score ? self.comment.score : @"0"];
        
        self.scoreLabel.userInteractionEnabled = YES;
        for (UITapGestureRecognizer *tap in self.scoreLabel.gestureRecognizers) {
            [self.scoreLabel removeGestureRecognizer:tap];
        }
        
//        UITapGestureRecognizer *scoreTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScoreDoubleTap:)];
//        scoreTap2.numberOfTapsRequired = 2;
//        [self.scoreLabel addGestureRecognizer:scoreTap2];
        
        UITapGestureRecognizer *scoreTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScoreSingleTap:)];
//        scoreTap1.numberOfTapsRequired = 1;
//        [scoreTap1 requireGestureRecognizerToFail:scoreTap2];
        [self.scoreLabel addGestureRecognizer:scoreTap1];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"comment_cell" forIndexPath:indexPath];
        Comment *comment= [self.comments objectAtIndex:indexPath.row];
        UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF0];
        nameLabel.text = comment.komm.nickname;
        UILabel *scoreLabel = (id)[cell.contentView viewWithTag:0xF1];
        scoreLabel.text = [NSString stringWithFormat:@"%@", comment.score];
        UILabel *commentLabel = (id)[cell.contentView viewWithTag:0xF2];
        commentLabel.text = [NSString stringWithFormat:@"%@", comment.comment ?comment.comment : @""];
        
    }
   
    
    return cell;
}

#pragma mark - PickerViewControllerDelegate
- (NSInteger)numberOfComponentsInPickerViewController:(PickerViewController *)pickerViewController
{
    return 1;
}

- (NSInteger)pickerViewController:(PickerViewController *)pickerViewController numberOfRowsInComponent:(NSInteger)component
{
    return 11;
}

- (NSString *)pickerViewController:(PickerViewController *)pickerViewController titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (void)didConfirmForPickerViewController:(PickerViewController *)pickerViewController
{
     self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[pickerViewController.pickerView selectedRowInComponent:0]];
    [pickerViewController hide];
}

#pragma mark - Event handler

- (void)onSave:(id)sender
{
    if (self.comment)
    {
         BmobObject *comment = [BmobObject objectWithoutDatatWithClassName:kTableComment objectId:self.comment.objectId];
        [comment setObject:[NSNumber numberWithInteger:[self.scoreLabel.text integerValue]] forKey:@"score"];
        [comment setObject:self.textField.text forKey:@"comment"];
        [self showLoadingView];
        [comment updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
        {
            [self hideLoadingView];
            if (isSuccessful) {
                self.comment = [[Comment alloc] initWithDictionary:comment];
                [self updatePlayerScore];
            }else
            {
                [self showMessage:[Util errorStringWithCode:error.code]];
            }
        }];
    }else
    {
        BmobObject *comment = [BmobObject objectWithClassName:kTableComment];
        [comment setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId] forKey:@"accept_comm"];
        [comment setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:[[BmobUser getCurrentUser] objectId]] forKey:@"komm"];
        [comment setObject:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId] forKey:@"competition"];
        [comment setObject:[NSNumber numberWithInteger:[self.scoreLabel.text integerValue]] forKey:@"score"];
        [comment setObject:self.textField.text forKey:@"comment"];
        [self showLoadingView];
        [comment saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
        {
            [self hideLoadingView];
            if (isSuccessful) {
                self.comment = [[Comment alloc] initWithDictionary:comment];
                [self updatePlayerScore];
            }else
            {
                [self showMessage:[Util errorStringWithCode:error.code]];
            }
        }];
    }
}

//- (void)onScoreDoubleTap:(id)sender
//{
//    if (!self.scoreLabel.text || [self.scoreLabel.text isEqualToString:@""]) {
//        self.scoreLabel.text = @"0";
//    }
//    NSInteger score = [self.scoreLabel.text integerValue] - 1 < 0 ? 0 : [self.scoreLabel.text integerValue] - 1;
//    
//    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
//    
//}

- (void)onScoreSingleTap:(id)sender
{
//    if (!self.scoreLabel.text || [self.scoreLabel.text isEqualToString:@""]) {
//        self.scoreLabel.text = @"0";
//    }
//    NSInteger score = [self.scoreLabel.text integerValue] + 1 > 10 ? 10 : [self.scoreLabel.text integerValue] + 1;
//    
//    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    
    PickerViewController *picker = [PickerViewController pickerViewController];
    [picker showInView:self.view parentViewController:self delegate:self];
    [picker.pickerView reloadAllComponents];
    [picker.pickerView selectRow:[self.scoreLabel.text integerValue] inComponent:0 animated:NO];
    
}





#pragma mark - share

- (IBAction)shareButtonClick:(id)sender
{
    
    CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"短信" andIcon:[UIImage imageNamed:@"message.png"] andSelectedBlock:^{
        
        BDLog(@"短信 selected");
        
        
        [self showShareViewWithType:ShareTypeSMS];
        
        
    }];
    
    
    [menuView addMenuItemWithTitle:@"微信" andIcon:[UIImage imageNamed:@"wx.png"] andSelectedBlock:^{
        
        BDLog(@"微信 selected");
        
        [self showShareViewWithType:ShareTypeWeixiSession];
        
        
    }];
    
    
    [menuView addMenuItemWithTitle:@"微信朋友圈" andIcon:[UIImage imageNamed:@"pyq.png"] andSelectedBlock:^{
        
        
        BDLog(@"微信朋友圈");
        
        [self showShareViewWithType:ShareTypeWeixiTimeline];
        
        
    }];
    
    
    
    [menuView addMenuItemWithTitle:@"微博" andIcon:[UIImage imageNamed:@"wb.png"] andSelectedBlock:^{
        
        BDLog(@"微博 selected");
        
        [self showShareViewWithType:ShareTypeSinaWeibo];
        
        
    }];
    
    
    [menuView show];
    
    
    
    
    
    
}

-(void)showShareViewWithType:(ShareType)type
{
    
    self.shareTitle=@"球员比赛";
    
    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/PlayerComment?player=%@&game=%@",self.userInfo.objectId,self.match.objectId];

    
    self.shareContent=[NSString stringWithFormat:@"%@在%@VS%@比赛中进球%@个，助攻%@次，大家对王大锤的综合评分是%@分。  链接：%@",self.userInfo.nickname,self.match.home_court.name,self.match.opponent.name,self.playerScore.goals,self.playerScore.assists,self.scoreLabel.text,self.shareUrl];
    
    

    
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:self.shareContent
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"res2.jpg"] quality:1]
                                                title:self.shareTitle
                                                  url:self.shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"踢球吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"踢球吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:type
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     BDLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     BDLog(@"发布失败!error code == %ld, error code == %@", (long)[error errorCode], [error errorDescription]);
                                 }
                             }];
    
    
}








@end

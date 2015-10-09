//
//  ValueSelectionViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-20.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"


@protocol ValueSelectionDelegate;

@interface ValueSelectionViewController : BaseTableViewController

@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, weak) id<ValueSelectionDelegate> delegate;

@end


@protocol ValueSelectionDelegate <NSObject>

@required
- (void)valueSelection:(id)valueSelection didSaveAtIndex:(NSInteger )index;

@end

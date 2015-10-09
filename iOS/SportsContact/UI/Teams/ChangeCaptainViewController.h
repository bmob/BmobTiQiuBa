//
//  ChangeCaptainViewController.h
//  SportsContact
//
//  Created by Nero on 8/9/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"


@protocol ChangeCaptainSelectionDelegate;

@interface ChangeCaptainViewController : BaseTableViewController

@property (nonatomic, weak) id<ChangeCaptainSelectionDelegate> delegate;

@end



@protocol ChangeCaptainSelectionDelegate <NSObject>

@required
- (void)valueSelection:(id)valueSelection changeCaptainId:(NSString *)userId;

@end


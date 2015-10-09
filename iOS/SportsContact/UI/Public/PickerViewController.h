//
//  PickerViewController.h
//  SportsContact
//
//  Created by bobo on 14/12/30.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseViewController.h"

@class PickerViewController;

@protocol PickerViewControllerDelegate <NSObject>

@required
- (NSInteger)numberOfComponentsInPickerViewController:(PickerViewController *)pickerViewController;
- (NSInteger)pickerViewController:(PickerViewController *)pickerViewController numberOfRowsInComponent:(NSInteger)component;

@optional
- (NSString *)pickerViewController:(PickerViewController *)pickerViewController titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)didConfirmForPickerViewController:(PickerViewController *)pickerViewController;
- (void)didCancelForPickerViewController:(PickerViewController *)pickerViewController;

@end

@interface PickerViewController : BaseViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id<PickerViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) id userInfo;

+ (PickerViewController *)pickerViewController;
- (void)showInView:(UIView *)view parentViewController:(UIViewController *)viewController delegate:(id<PickerViewControllerDelegate>) delegate;
- (void)hide;

@end

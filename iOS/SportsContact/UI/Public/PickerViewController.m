//
//  PickerViewController.m
//  SportsContact
//
//  Created by bobo on 14/12/30.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation PickerViewController

+ (PickerViewController *)pickerViewController
{
    return [[PickerViewController alloc] initWithNibName:@"PickerViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.backgroundView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInView:(UIView *)view parentViewController:(UIViewController *)viewController delegate:(id<PickerViewControllerDelegate>)delegate
{
    self.delegate = delegate;
    [viewController addChildViewController:self];
    self.view.frame = view.bounds;
    self.backgroundView.alpha = 0.0f;
    __block CGRect rect = self.contentView.frame;
    rect.origin.y = view.bounds.size.height;
    self.contentView.frame = rect;
    self.view.backgroundColor = [UIColor clearColor];
    [view addSubview:self.view];
    [UIView animateWithDuration:0.3 animations:^{
        rect.origin.y = view.bounds.size.height - rect.size.height;
        self.contentView.frame = rect;
        self.backgroundView.alpha = 0.3f;
    } completion:NULL];
}

- (void)hide
{
    __block CGRect rect = self.contentView.bounds;
    [UIView animateWithDuration:0.3 animations:^{
        rect.origin.y = self.view.bounds.size.height;
        self.contentView.frame = rect;
        self.backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
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

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.delegate respondsToSelector:@selector(pickerViewController:titleForRow:forComponent:)]) {
        return [self.delegate pickerViewController:self titleForRow:row forComponent:component];
    }else
    {
        return @"";
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.delegate numberOfComponentsInPickerViewController:self];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.delegate pickerViewController:self numberOfRowsInComponent:component];
}


#pragma mark - Event handler
- (IBAction)onSure:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didConfirmForPickerViewController:)])
    {
        [self.delegate didConfirmForPickerViewController:self];
    }
}
- (IBAction)onCancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelForPickerViewController:)])
    {
        [self.delegate didCancelForPickerViewController:self];
    }
    [self hide];
}

@end

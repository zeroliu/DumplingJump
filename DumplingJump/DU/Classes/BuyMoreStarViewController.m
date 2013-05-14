//
//  BuyMoreStarViewController.m
//  CastleRider
//
//  Created by zero.liu on 5/13/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "BuyMoreStarViewController.h"
#import "cocos2d.h"
#import "Constants.h"
@interface BuyMoreStarViewController ()

@end

@implementation BuyMoreStarViewController

+ (BuyMoreStarViewController *) shared
{
    static BuyMoreStarViewController *shared = nil;
    
    if (shared == nil)
    {
        shared = [[BuyMoreStarViewController alloc] initWithNibName:@"BuyMoreStar" bundle:nil];
    }
    
    return shared;
}

- (void) showWithNumber:(int)number
{
    [self.view removeFromSuperview];
    
    //Set scale
    CGAffineTransform tr = CGAffineTransformMakeScale(0.01, 0.01);
    [self.popupHolder setTransform:tr];
    
    //Show popup animation
    tr = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.05 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self.popupHolder setTransform:tr];
     } completion:^(BOOL finished){
         [self setButtonEnabled:YES];
     }];
    
    //Change text
    [self.descriptionLabel setText:[NSString stringWithFormat:@"You need %d more stars to complete your purchase. Buy more stars?", number]];
    
    self.view.layer.zPosition = Z_BUYMORESTARS;
    [VIEW addSubview:self.view];
}

- (void) hide
{
    CGAffineTransform tr = CGAffineTransformScale(self.popupHolder.transform, 0.01, 0.01);
    [UIView animateWithDuration:0.05 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self.popupHolder setTransform:tr];
     } completion:^(BOOL finished){
         [self.view removeFromSuperview];
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:20]];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:12]];
}

- (void) setButtonEnabled:(BOOL)isEnabled
{
    [self.cancelButton setEnabled:isEnabled];
    [self.confirmButton setEnabled:isEnabled];
}


- (void)dealloc {
    [_titleLabel release];
    [_descriptionLabel release];
    [_cancelButton release];
    [_confirmButton release];
    [_popupHolder release];
    [_mask release];
    self.delegate = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDescriptionLabel:nil];
    [self setCancelButton:nil];
    [self setConfirmButton:nil];
    [self setPopupHolder:nil];
    [self setMask:nil];
    [super viewDidUnload];
}

- (IBAction)didTapCancel:(id)sender
{
    [self setButtonEnabled:NO];
    [self hide];
}

- (IBAction)didTapConfirm:(id)sender
{
    [self setButtonEnabled:NO];
    [self hide];
    if ([self.delegate respondsToSelector:@selector(iapConfirmed)])
    {
        [self.delegate performSelector:@selector(iapConfirmed)];
    }
}
@end

//
//  BuyMoreStarViewController.h
//  CastleRider
//
//  Created by zero.liu on 5/13/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BuyMoreStarViewDelegate <NSObject>
- (void) iapConfirmed;
@end

@interface BuyMoreStarViewController : UIViewController

+ (BuyMoreStarViewController *) shared;
- (void) showWithNumber:(int)number;
- (void) hide;

@property (retain, nonatomic) IBOutlet UIView *popupHolder;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *confirmButton;
@property (retain, nonatomic) IBOutlet UIImageView *mask;
@property (retain, nonatomic) id delegate;
- (IBAction)didTapCancel:(id)sender;
- (IBAction)didTapConfirm:(id)sender;

@end

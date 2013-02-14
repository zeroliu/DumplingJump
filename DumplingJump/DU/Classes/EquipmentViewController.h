//
//  EquipmentTableViewController.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-13.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <UIKit/UIKit.h>

@protocol EquipmentViewControllerDelegate <NSObject>
- (void) didEquipmentViewBack;
- (void) didEquipmentViewContinue;
@end

@interface EquipmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    //Equipment View buttons
    IBOutlet UIView *backgroundView;
    IBOutlet UIButton *continueButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *storeButton;
    IBOutlet UIImageView *bottomImage;
}


@property (nonatomic, retain) id delegate;

- (id)initWithDelegate:(id)theDelegate;

- (void) showEquipmentView;

- (IBAction)didBackButtonClicked:(id)sender;
- (IBAction)didStoreButtonClicked:(id)sender;
- (IBAction)didContinueButtonClicked:(id)sender;

@end

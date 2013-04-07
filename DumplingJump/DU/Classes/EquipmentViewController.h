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
@optional
- (void) didEquipmentViewBack;
- (void) didEquipmentViewContinue;
- (void) didHideEquipmentViewAnimStart;
@end

@interface EquipmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    IBOutlet UIView *backgroundView;
    IBOutlet UIButton *continueButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *storeButton;
    IBOutlet UIImageView *bottomImage;
    IBOutlet UIImageView *starIcon;
    IBOutlet UILabel *starNumLabel;
}

@property (nonatomic, retain) id delegate;
- (id)initWithDelegate:(id)theDelegate;

- (void) setContinueButtonVisibility:(BOOL)isVisible;

- (void) showEquipmentView;
- (void) hideEquipmentView;
- (void) updateStarNum:(int)num;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

- (IBAction)didBackButtonClicked:(id)sender;
- (IBAction)didStoreButtonClicked:(id)sender;
- (IBAction)didContinueButtonClicked:(id)sender;

@end

//
//  EquipmentTableViewController.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-13.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "OutlineLabel.h"
#import <UIKit/UIKit.h>
#import "BuyMoreStarViewController.h"

@protocol EquipmentViewControllerDelegate <NSObject>
@optional
- (void) didEquipmentViewBack;
- (void) didHideEquipmentViewAnimStart;
@end

@interface EquipmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, BuyMoreStarViewDelegate>
{
    IBOutlet UITableView *tableview;
    IBOutlet UIView *backgroundView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *storeButton;
    IBOutlet UIImageView *bottomImage;
    IBOutlet UIImageView *starIcon;
    IBOutlet OutlineLabel *starNumLabel;
    IBOutlet UILabel *noInternetMessageLabel;
    IBOutlet UIView *tutorialMask;
    IBOutlet OutlineLabel *tutorialHintLabel;
}

@property (nonatomic, retain) id delegate;
- (id)initWithDelegate:(id)theDelegate;

- (void) showEquipmentView;
- (void) hideEquipmentView;
- (void) updateStarNum:(int)num;
- (void) reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void) reloadTableview;
- (IBAction)didBackButtonClicked:(id)sender;
- (IBAction)didStoreButtonClicked:(id)sender;
- (void) removeTutorial;
@end

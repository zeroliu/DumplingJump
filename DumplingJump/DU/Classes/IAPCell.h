//
//  EquipmentTableViewCell.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DUTableViewCell.h"

@interface IAPCell : DUTableViewCell
{
    IBOutlet UIView *holder;
    IBOutlet UIButton *cellButton;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *rewardLabel;
    IBOutlet UIImageView *itemImageView;
}

- (IBAction)didTapButton:(id)sender;
- (IBAction)didPressDownButton:(id)sender;
@end

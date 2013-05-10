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

@interface EquipmentViewLevelCell : DUTableViewCell
{
    IBOutlet UIImageView *unlock0;
    IBOutlet UIImageView *unlock1;
    IBOutlet UIImageView *unlock2;
    IBOutlet UIImageView *unlock3;
    IBOutlet UIImageView *unlock4;
    
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UIImageView *equipmentImageView;
    IBOutlet UIImageView *band;
    IBOutlet UIImageView *priceLabelImage;
    
    IBOutlet UIButton *currentButton;
    
    IBOutlet UIView *holder;
    NSDictionary *myContent;
}
- (IBAction)didTapButton:(id)sender;
- (IBAction)didPressDown:(id)sender;

@end

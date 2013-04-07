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

@interface LockedEquipmentViewCell : DUTableViewCell
{
    IBOutlet UIView *parentView;
    IBOutlet UIImageView *equipmentImageView;
    
    IBOutlet UILabel *priceLabel;
    IBOutlet UIButton *cellButton;
    UIView *overlay;
}

@end

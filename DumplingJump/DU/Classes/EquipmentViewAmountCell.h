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

@interface EquipmentViewAmountCell : DUTableViewCell
{
    
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UIImageView *equipmentImageView;
    IBOutlet UILabel *amountLabel;
    
//    IBOutlet UILabel *priceLabel;
//    IBOutlet UILabel *descriptionLabel;
//    IBOutlet UILabel *amountLabel;
//    IBOutlet UIImageView *equipmentImageView;
}

@end

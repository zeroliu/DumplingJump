//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "LockedEquipmentViewCell.h"

@interface LockedEquipmentViewCell()
{

}

@end

@implementation LockedEquipmentViewCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {

    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_shadow.png",[content objectForKey:@"image"]]]];
}
- (void)dealloc {
    [equipmentImageView release];
    [super dealloc];
}
@end
//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "EquipmentTableViewCell.h"

@interface EquipmentTableViewCell()
{
    NSMutableArray *unlockArray;
}

@end

@implementation EquipmentTableViewCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        unlockArray = [[NSMutableArray alloc] initWithCapacity:4];
        [unlockArray insertObject:unlock0 atIndex:0];
        [unlockArray insertObject:unlock1 atIndex:1];
        [unlockArray insertObject:unlock2 atIndex:2];
        [unlockArray insertObject:unlock3 atIndex:3];
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    
    
}
- (void)dealloc {
    [unlockArray release];
    [unlock1 release];
    [unlock2 release];
    [unlock3 release];
    [unlock0 release];
    [priceLabel release];
    [descriptionLabel release];
    [equipmentImageView release];
    [super dealloc];
}
@end

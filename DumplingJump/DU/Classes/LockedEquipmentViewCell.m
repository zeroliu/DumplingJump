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
    equipmentImageView.hidden = YES;
    
    if (overlay != nil)
    {
        [overlay removeFromSuperview];
        [overlay release];
        overlay = nil;
    }
    
    overlay = [[UIView alloc] initWithFrame:[equipmentImageView frame]];
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_shadow.png",[content objectForKey:@"image"]]]];
    [maskImageView setFrame:[overlay bounds]];
    [[overlay layer] setMask:[maskImageView layer]];
    [overlay setBackgroundColor:[UIColor blackColor]];
    [parentView addSubview:overlay];
}
- (void)dealloc {
    [overlay release];
    [equipmentImageView release];
    [parentView release];
    [super dealloc];
}
@end

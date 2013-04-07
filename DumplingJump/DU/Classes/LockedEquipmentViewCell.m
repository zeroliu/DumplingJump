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
        [cellButton setImage:[UIImage imageNamed:@"UI_equip_box_locked_press.png"] forState:UIControlStateHighlighted];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_shadow.png",[content objectForKey:@"image"]]]];
    equipmentImageView.hidden = YES;
    
    [priceLabel setText:[NSString stringWithFormat:@"%d", [[content objectForKey:@"unlockPrice"] intValue]]];
    
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
    [cellButton release];
    [overlay release];
    [equipmentImageView release];
    [parentView release];
    [priceLabel release];
    [super dealloc];
}
@end

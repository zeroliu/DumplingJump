//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "LockedEquipmentViewCell.h"
#import "UserData.h"
#import "Constants.h"
#import "EquipmentViewController.h"

@interface LockedEquipmentViewCell()
{
    NSDictionary *myContent;
}

@end

@implementation LockedEquipmentViewCell
@synthesize path = _path;

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        [cellButton setImage:[UIImage imageNamed:@"UI_equip_box_locked_press.png"] forState:UIControlStateHighlighted];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:15]];
        [titleLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_shadow.png",[content objectForKey:@"image"]]]];
    equipmentImageView.hidden = YES;
    
    [priceLabel setText:[NSString stringWithFormat:@"%d", [[content objectForKey:@"unlockPrice"] intValue]]];
    [titleLabel setText:[NSString stringWithFormat:@"Unlock %@", [content objectForKey:@"displayName"]]];
    
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
    
    myContent = [content retain];
}

- (IBAction)didTapButton:(id)sender
{
    int price = [priceLabel.text intValue];
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];

    if (currentStar >= price)
    {
        //Have enough money
        [USERDATA setObject:[NSNumber numberWithInt:1] forKey: [myContent objectForKey:@"name"]];
        [USERDATA setObject:[NSNumber numberWithInt:currentStar-price] forKey:@"star"];
    }
    else
    {
        //TODO: show IAP
    }
    [self showUnlockAnimation];
    [self.parentTableView updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
}

- (void) showUnlockAnimation
{
    [self.parentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_path]];
}

- (void)dealloc {
    [_path release];
    [cellButton release];
    [overlay release];
    [equipmentImageView release];
    [parentView release];
    [priceLabel release];
    [titleLabel release];
    [myContent release];
    [super dealloc];
}
@end

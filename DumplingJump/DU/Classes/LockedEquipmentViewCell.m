//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013 CMU ETC. All rights reserved.
//

#import "LockedEquipmentViewCell.h"
#import "UserData.h"
#import "Constants.h"
#import "EquipmentViewController.h"
#import "BuyMoreStarViewController.h"
#import "TutorialManager.h"

@interface LockedEquipmentViewCell()
{
    NSDictionary *myContent;
    BOOL justTapped;
}

@end

@implementation LockedEquipmentViewCell


- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        [cellButton setImage:[UIImage imageNamed:@"UI_equip_box_locked_press.png"] forState:UIControlStateHighlighted];
        [cellButton setImage:[UIImage imageNamed:@"UI_equip_box_locked_press.png"] forState:UIControlStateSelected];
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [titleLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        justTapped = NO;
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_shadow.png",[content objectForKey:@"image"]]]];
    equipmentImageView.hidden = YES;
    
    [priceLabel setText:[NSString stringWithFormat:@"%d", [[content objectForKey:@"unlockPrice"] intValue]]];
    [titleLabel setText:[NSString stringWithFormat:@"%@", [content objectForKey:@"unlockDescription"]]];
    
    //update band
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    if (currentStar >= [[content objectForKey:@"unlockPrice"] intValue])
    {
        [band setHidden:NO];
        [priceLabelImage setImage:[UIImage imageNamed:@"UI_equip_box_price.png"]];
    }
    else
    {
        [band setHidden:YES];
        [priceLabelImage setImage:[UIImage imageNamed:@"UI_equip_box_price_locked.png"]];
    } 
    
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
    if (justTapped)
    {
        [self performSelector:@selector(resetHolderPosition) withObject:nil afterDelay:0.1];
    }
    else
    {
        [self resetHolderPosition];
    }
    
    int price = [priceLabel.text intValue];
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];

    if (currentStar >= price)
    {
        //Have enough money
        [USERDATA setObject:[NSNumber numberWithInt:0] forKey: [myContent objectForKey:@"name"]];
        [USERDATA setObject:[NSNumber numberWithInt:currentStar-price] forKey:@"star"];
        [self showUnlockAnimation];
        [self.parentTableView updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
        if ([[TutorialManager shared] isInStoreTutorial])
        {
            [self.parentTableView performSelector:@selector(removeTutorial) withObject:nil afterDelay:0.5];
        }
    }
    else
    {
        //show IAP
        [[BuyMoreStarViewController shared] showWithNumber:price - currentStar];
    }
}

- (IBAction)didPressDown:(id)sender
{
    justTapped = YES;
    [self performSelector:@selector(resetJustTapValue) withObject:nil afterDelay:0.1];
    holder.center = ccp(holder.frame.size.width/2, holder.frame.size.height/2+2);
}

- (void) resetJustTapValue
{
    justTapped = NO;
}

- (void) resetHolderPosition
{
    holder.center = ccp(holder.frame.size.width/2, holder.frame.size.height/2);
}

- (void) showUnlockAnimation
{
    [self.parentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.path] withRowAnimation:UITableViewRowAnimationLeft];
    [self.parentTableView performSelector:@selector(reloadTableview) withObject:nil afterDelay:0.3];
}

- (void)dealloc
{
    [holder release];
    holder = nil;
    [band release];
    band = nil;
    [cellButton release];
    cellButton = nil;
    [overlay release];
    overlay = nil;
    [equipmentImageView release];
    equipmentImageView = nil;
    [parentView release];
    parentView = nil;
    [priceLabel release];
    priceLabel = nil;
    [titleLabel release];
    titleLabel = nil;
    [myContent release];
    myContent = nil;
    [priceLabelImage release];
    priceLabelImage = nil;
    [super dealloc];
}
@end

//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "EquipmentViewLevelCell.h"
#import "UserData.h"
#import "Constants.h"
#import "EquipmentViewController.h"

@interface EquipmentViewLevelCell()
{
    NSMutableArray *unlockArray;
    BOOL justTapped;
}

@end

@implementation EquipmentViewLevelCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        [currentButton setImage:[UIImage imageNamed:@"UI_equip_box_normal_press.png"] forState:UIControlStateHighlighted];
        [currentButton setImage:[UIImage imageNamed:@"UI_equip_box_normal_press.png"] forState:UIControlStateSelected];
        
        unlockArray = [[NSMutableArray alloc] initWithCapacity:5];
        [unlockArray insertObject:unlock0 atIndex:0];
        [unlockArray insertObject:unlock1 atIndex:1];
        [unlockArray insertObject:unlock2 atIndex:2];
        [unlockArray insertObject:unlock3 atIndex:3];
        [unlockArray insertObject:unlock4 atIndex:4];
        
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setTextAlignment:UITextAlignmentLeft];
        [descriptionLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [descriptionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        for (UIImageView *view in unlockArray)
        {
            [view setHighlighted:NO];
        }
        
        justTapped = NO;
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    [super setLayoutWithDictionary:content];
    if (myContent != nil)
    {
        [myContent release];
        myContent = nil;
    }
    myContent = [content retain];
    [self updateCellUI];
    
}

- (void) updateCellUI
{
    [self setUserInteractionEnabled:YES];
    
    int level = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    for (int i=0; i<5; i++)
    {
        if (i<=level)
        {
            [[unlockArray objectAtIndex:i] setHighlighted:YES];
        }
        else
        {
            [[unlockArray objectAtIndex:i] setHighlighted:NO];
        }
    }
    
    int price = 0;
    if (level >= 4)
    {
        [priceLabel setText:@"max"];
        [self setUserInteractionEnabled:NO];
    }
    else
    {
        price = [[myContent objectForKey:[NSString stringWithFormat:@"price%d",level]] intValue];
        
        [priceLabel setText:[NSString stringWithFormat:@"%d",price]];
        [self setUserInteractionEnabled:YES];
    }
    
    //update band
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    if (level < 4 && currentStar >= price)
    {
        [band setHidden:NO];
        [priceLabelImage setImage:[UIImage imageNamed:@"UI_equip_box_price.png"]];
    }
    else
    {
        [band setHidden:YES];
        [priceLabelImage setImage:[UIImage imageNamed:@"UI_equip_box_price_locked.png"]];
    }
    
    float effectValue = [[myContent objectForKey:[NSString stringWithFormat:@"level%d", level]] floatValue];
    
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[myContent objectForKey:@"description"], [NSNumber numberWithFloat:effectValue], [myContent objectForKey:@"unit"]]];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[myContent objectForKey:@"image"]]]];
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
    int currentLevel = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    if (currentStar >= price)
    {
        //Have enough money
        [USERDATA setObject:[NSNumber numberWithInt:currentLevel+1] forKey: [myContent objectForKey:@"name"]];
        //TODO: star reducing anim
        [USERDATA setObject:[NSNumber numberWithInt:currentStar-price] forKey:@"star"];
        [self.parentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.path] withRowAnimation:UITableViewRowAnimationFade];
        [self.parentTableView performSelector:@selector(reloadTableview)];
    }
    else
    {
        //show IAP
        [[BuyMoreStarViewController shared] showWithNumber:price - currentStar];
    }
    [self.parentTableView updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];

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

- (void)dealloc
{
    [holder release];
    holder = nil;
    [unlockArray release];
    unlockArray = nil;
    [unlock1 release];
    unlock1 = nil;
    [unlock2 release];
    unlock2 = nil;
    [unlock3 release];
    unlock3 = nil;
    [unlock4 release];
    unlock4 = nil;
    [unlock0 release];
    unlock0 = nil;
    [priceLabel release];
    priceLabel = nil;
    [descriptionLabel release];
    descriptionLabel = nil;
    [equipmentImageView release];
    equipmentImageView = nil;
    [currentButton release];
    currentButton = nil;
    [myContent release];
    myContent = nil;
    [band release];
    band = nil;
    [priceLabelImage release];
    priceLabelImage = nil;
    [super dealloc];
}

@end

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
        [descriptionLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:13]];
        [descriptionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        for (UIImageView *view in unlockArray)
        {
            [view setHighlighted:NO];
        }
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
    float base = [[myContent objectForKey:@"base"] floatValue];
    float multiplier = [[myContent objectForKey:@"multiplier"] floatValue];
    
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
        if (level == 0)
        {
            price = base;
        }
        else
        {
            price = base * multiplier * level;
        }
        
        [priceLabel setText:[NSString stringWithFormat:@"%d",price]];
        [self setUserInteractionEnabled:YES];
    }
    
    //update band
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    if (level < 4 && currentStar >= price)
    {
        [band setHidden:NO];
    }
    else
    {
        [band setHidden:YES];
    }
    
    float effectValue = [[myContent objectForKey:[NSString stringWithFormat:@"level%d", level]] floatValue];
    
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[myContent objectForKey:@"description"], [NSNumber numberWithFloat:effectValue], [myContent objectForKey:@"unit"]]];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[myContent objectForKey:@"image"]]]];
}

- (IBAction)didTapButton:(id)sender
{
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
        [self.parentTableView performSelector:@selector(reloadTableview) withObject:nil afterDelay:0.2];
    }
    else
    {
        //TODO: show IAP
    }
    [self.parentTableView updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];

}

- (void)dealloc {
    [unlockArray release];
    [unlock1 release];
    [unlock2 release];
    [unlock3 release];
    [unlock4 release];
    [unlock0 release];
    [priceLabel release];
    [descriptionLabel release];
    [equipmentImageView release];
    [currentButton release];
    [myContent release];
    [band release];
    [super dealloc];
}

@end

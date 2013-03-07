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
        unlockArray = [[NSMutableArray alloc] initWithCapacity:4];
        [unlockArray insertObject:unlock0 atIndex:0];
        [unlockArray insertObject:unlock1 atIndex:1];
        [unlockArray insertObject:unlock2 atIndex:2];
        [unlockArray insertObject:unlock3 atIndex:3];
        
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
            [view setHidden:YES];
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
    float base = [[myContent objectForKey:@"base"] floatValue];
    float multiplier = [[myContent objectForKey:@"multiplier"] floatValue];
    
    int level = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    for (int i=0; i<level; i++)
    {
        [[unlockArray objectAtIndex:i] setHidden:NO];
    }
    
    if (level >= 4)
    {
        [priceLabel setText:@"max"];
        [self setUserInteractionEnabled:NO];
    }
    else
    {
        [priceLabel setText:[NSString stringWithFormat:@"%d",(int)(base * multiplier * (level+1))]];
        [self setUserInteractionEnabled:YES];
    }
    
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[myContent objectForKey:@"description"], [NSNumber numberWithFloat:15], [myContent objectForKey:@"unit"]]];
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
    }
    else
    {
        //TODO: show IAP
    }
    [self updateCellUI];
    [self.parentTableView updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];

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
    [currentButton release];
    [myContent release];
    [super dealloc];
}

@end

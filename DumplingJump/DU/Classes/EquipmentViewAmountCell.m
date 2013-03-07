//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "EquipmentViewAmountCell.h"
#import "UserData.h"
#import "Constants.h"
#import "EquipmentViewController.h"

@interface EquipmentViewAmountCell()

@end

@implementation EquipmentViewAmountCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {        
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setTextAlignment:UITextAlignmentLeft];
        [descriptionLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:13]];
        [descriptionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentCenter];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [priceLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        
        [amountLabel setBackgroundColor:[UIColor clearColor]];
        [amountLabel setTextAlignment:UITextAlignmentCenter];
        [amountLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:11]];
        [amountLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
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
    
    int amount = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    [amountLabel setText:[NSString stringWithFormat:@"%d", amount]];
    [priceLabel setText:[NSString stringWithFormat:@"%d",(int)(base * multiplier * amount)]];
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[myContent objectForKey:@"description"], [NSNumber numberWithFloat:15], [myContent objectForKey:@"unit"]]];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[myContent objectForKey:@"image"]]]];
}

- (IBAction)didTapButton:(id)sender
{
    int price = [priceLabel.text intValue];
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    int currentNum = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    if (currentStar >= price)
    {
        //Have enough money
        [USERDATA setObject:[NSNumber numberWithInt:currentNum+1] forKey: [myContent objectForKey:@"name"]];
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
    [priceLabel release];
    [descriptionLabel release];
    [equipmentImageView release];
    [amountLabel release];
    [myContent release];
    [super dealloc];
}

@end

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
{
    NSDictionary *myContent;
}

@end

@implementation EquipmentViewAmountCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        [cellButton setImage:[UIImage imageNamed:@"UI_equip_box_normal_press.png"] forState:UIControlStateHighlighted];
 
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
    [self setUserInteractionEnabled:YES];
    float base = [[myContent objectForKey:@"base"] floatValue];
    float multiplier = [[myContent objectForKey:@"multiplier"] floatValue];
    
    int amount = [[USERDATA objectForKey:[myContent objectForKey:@"name"]] intValue];
    
    [amountLabel setText:[NSString stringWithFormat:@"%d", amount]];

    if (amount >= 4)
    {
        [priceLabel setText:@"max"];
        [self setUserInteractionEnabled:NO];
    }
    else
    {
        int price = [[myContent objectForKey:[NSString stringWithFormat:@"price%d",amount]] intValue];
//        if (amount == 0)
//        {
//            price = base;
//        }
//        else
//        {
//            price = base * multiplier * amount;
//        }
        
        [priceLabel setText:[NSString stringWithFormat:@"%d",price]];
    }
    
    [descriptionLabel setText:[NSString stringWithFormat:@"%@",[myContent objectForKey:@"description"]]];
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
    [cellButton release];
    [priceLabel release];
    [descriptionLabel release];
    [equipmentImageView release];
    [amountLabel release];
    [myContent release];
    [priceLabelImage release];
    [super dealloc];
}

@end

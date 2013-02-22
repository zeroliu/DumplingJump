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
    
    float base = [[content objectForKey:@"base"] floatValue];
    float multiplier = [[content objectForKey:@"multiplier"] floatValue];
    
    int amount = [[USERDATA objectForKey:[content objectForKey:@"name"]] intValue];
    
    [amountLabel setText:[NSString stringWithFormat:@"%d", amount]];
    [priceLabel setText:[NSString stringWithFormat:@"%d",(int)(base * multiplier)]];
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[content objectForKey:@"description"], [NSNumber numberWithFloat:15], [content objectForKey:@"unit"]]];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[content objectForKey:@"image"]]]];
    
    NSLog(@"%@", amountLabel.text);
}
- (void)dealloc {
    [priceLabel release];
    [descriptionLabel release];
    [equipmentImageView release];
    [amountLabel release];
    [super dealloc];
}
@end

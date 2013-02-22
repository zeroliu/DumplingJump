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
    float base = [[content objectForKey:@"base"] floatValue];
    float multiplier = [[content objectForKey:@"multiplier"] floatValue];
    
    int level = [[USERDATA objectForKey:[content objectForKey:@"name"]] intValue];
    
    for (int i=0; i<level; i++)
    {
        [[unlockArray objectAtIndex:i] setHidden:NO];
    }
    
    [priceLabel setText:[NSString stringWithFormat:@"%d",(int)(base * multiplier)]];
    [descriptionLabel setText:[NSString stringWithFormat:@"%@ %@%@",[content objectForKey:@"description"], [NSNumber numberWithFloat:15], [content objectForKey:@"unit"]]];
    [equipmentImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[content objectForKey:@"image"]]]];
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
    [super dealloc];
}
@end

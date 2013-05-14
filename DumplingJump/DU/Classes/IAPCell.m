//
//  EquipmentTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "IAPCell.h"
#import "UserData.h"
#import "Constants.h"
#import "EquipmentViewController.h"
#import "DUIAPHelper.h"

@interface IAPCell()
{
    NSDictionary *myContent;
    BOOL justTapped;
    SKProduct *product;
}

@end

@implementation IAPCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super initWithXib:xibName])
    {
        [cellButton setImage:[UIImage imageNamed:@"UI_purch_box_press.png"] forState:UIControlStateHighlighted];
        
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:13]];
        
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentRight];
        [priceLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:15]];
        
        [rewardLabel setBackgroundColor:[UIColor clearColor]];
        [rewardLabel setTextAlignment:UITextAlignmentLeft];
        [rewardLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:19]];
        
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

    [itemImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [myContent objectForKey:@"picture"]]]];
    
    if (![[myContent objectForKey:@"isConsumable"] boolValue] && [[DUIAPHelper sharedInstance] productPurchased:[myContent objectForKey:@"productID"]])
    {
        [self setUserInteractionEnabled:NO];
        [priceLabel setText:@"SOLD"];
    }
  
    
    [titleLabel setText:[myContent objectForKey:@"name"]];
    [rewardLabel setText:[myContent objectForKey:@"reward"]];
    
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
    
    if ([[myContent objectForKey:@"category"] isEqualToString:@"premium"])
    {
        [[DUIAPHelper sharedInstance] buyProduct:product];
    }
}

- (IBAction)didPressDownButton:(id)sender
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

- (void) updatePrice:(NSString *)price
{
    if ([[myContent objectForKey:@"isConsumable"] boolValue] || ![[DUIAPHelper sharedInstance] productPurchased:[myContent objectForKey:@"productID"]])
    {
        [priceLabel setText:price];
    }
}

- (void) setProduct:(SKProduct *)theProduct
{
    product = [theProduct retain];
}

- (void)dealloc
{
    [holder release];
    holder = nil;
    [cellButton release];
    cellButton = nil;
    [priceLabel release];
    priceLabel = nil;
    [titleLabel release];
    titleLabel = nil;
    [rewardLabel release];
    rewardLabel = nil;
    [itemImageView release];
    rewardLabel = nil;
    [product release];
    product = nil;
    [myContent release];
    myContent = nil;
    [super dealloc];
}

@end

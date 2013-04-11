//
//  EquipmentTableViewController.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-13.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "EquipmentViewController.h"
#import "Constants.h"
#import "EquipmentData.h"
#import "EquipmentViewLevelCell.h"
#import "LockedEquipmentViewCell.h"
#import "EquipmentViewAmountCell.h"
#import "UserData.h"

#define EQUIPMENT_DICT ((EquipmentData *)[EquipmentData shared]).structedDictionary

@interface EquipmentViewController()
{
    NSArray *equipmentTypesArray;
}

@end

@implementation EquipmentViewController
@synthesize delegate = _delegate;

- (id)initWithDelegate:(id)theDelegate
{
    if (self = [super init])
    {
        _delegate = theDelegate;
        equipmentTypesArray = [[NSArray alloc] initWithObjects:@"powerups",@"items",@"skills",@"multipliers", nil];
    }
    return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [equipmentTypesArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[EQUIPMENT_DICT objectForKey:[equipmentTypesArray objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *equipmentData = [[EQUIPMENT_DICT objectForKey:[equipmentTypesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NSString *equipmentName = [equipmentData objectForKey:@"name"];
    
    DUTableViewCell *cell = nil;
    BOOL unlocked = YES;
    if ([[USERDATA objectForKey:equipmentName] intValue] < 0)
    {
        unlocked = NO;
    }
    
    Class cellClass = NSClassFromString([equipmentData objectForKey:@"layout"]);
    if (unlocked)
    {
        cell = (DUTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[equipmentData objectForKey:@"layout"]];
        if (cell == nil)
        {
            cell = [[[cellClass alloc] initWithXib:[equipmentData objectForKey:@"layout"] ] autorelease];
        }
    }
    else
    {
        cell = (LockedEquipmentViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LockedEquipmentViewCell"];
        if (cell == nil)
        {
            cell = [[[LockedEquipmentViewCell alloc] initWithXib:@"LockedEquipmentViewCell"] autorelease];
        }
    }
    cell.path = indexPath;
    cell.parentTableView = self;
    [cell setLayoutWithDictionary:equipmentData];

    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 29)] autorelease];
    UIImageView *bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UI_equip_sort.png"]] autorelease];
    [bgImage setBounds:CGRectMake(0, 0, 260, 29)];
    [bgImage setCenter:ccp(130, 14.5)];
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0, 260, 29)] autorelease];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setText:[[equipmentTypesArray objectAtIndex:section] uppercaseString]];
    [titleLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:20]];
    [titleLabel setTextColor:[UIColor colorWithRed:242.0/255.0 green:228.0/255.0 blue:133.0/255.0 alpha:1]];
    [header addSubview:bgImage];
    [header addSubview:titleLabel];
    
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (void) equipmentViewFlyInAnimationWithTarget:(id)target selector:(SEL)callback
{
    [UIView animateWithDuration:0.1 delay:0.1 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self setEquipmentButtonsEnabled:YES];
     } completion:^(BOOL finished) {
         
     }];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         CGSize winSize = [[CCDirector sharedDirector] winSize];
         //move background image
         backgroundView.center = ccp(winSize.width/2.0, backgroundView.bounds.size.height/2.0);
         //move bottom image
         float destinationBottom = backgroundView.bounds.size.height - bottomImage.bounds.size.height/2.0;
         bottomImage.center = ccp(winSize.width/2.0, destinationBottom);
         
     } completion:^(BOOL finished) {
         [target performSelector:callback];
     }];
}

- (void) equipmentViewFlyOutAnimationWithTarget:(id)target selector:(SEL)callback
{
    if ([self.delegate respondsToSelector:@selector(didHideEquipmentViewAnimStart)])
    {
        [self.delegate performSelector:@selector(didHideEquipmentViewAnimStart)];
    }
    [UIView animateWithDuration:0.1 delay:0.1 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self setEquipmentButtonsEnabled:NO];
     } completion:^(BOOL finished) {
         
     }];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^
     {
         CGSize winSize = [[CCDirector sharedDirector] winSize];
         //move background image
         float destinationBG = backgroundView.bounds.size.height*3.0/2.0;
         backgroundView.center = ccp(winSize.width/2.0, destinationBG);
         //move bottom image
         float destinationBottom = winSize.height + bottomImage.bounds.size.height/2.0;
         bottomImage.center = ccp(winSize.width/2.0, destinationBottom);
     } completion:^(BOOL finished) {
         [target performSelector:callback];
     }];
}

- (void) setEquipmentButtonsEnabled:(BOOL)isEnabled
{
    [storeButton setEnabled:isEnabled];
    [backButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    storeButton.alpha = opacity;
    backButton.alpha = opacity;
}

- (void) showEquipmentView
{
    [self equipmentViewFlyInAnimationWithTarget:nil selector:nil];
}

- (void) hideEquipmentView
{
    [self equipmentViewFlyOutAnimationWithTarget:nil selector:nil];
}

- (IBAction)didBackButtonClicked:(id)sender
{
    [self equipmentViewFlyOutAnimationWithTarget:self.delegate selector:@selector(didEquipmentViewBack)];
}

- (IBAction)didStoreButtonClicked:(id)sender
{
}

//- (IBAction)didContinueButtonClicked:(id)sender
//{
//    [self equipmentViewFlyOutAnimationWithTarget:self.delegate selector:@selector(didEquipmentViewContinue)];
//}

- (void) updateStarNum:(int)num
{
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        [starNumLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:25]];
        [starNumLabel setText:[NSString stringWithFormat:@"%d", num]];
        [starNumLabel sizeToFit];
        [starIcon setCenter:ccp(starNumLabel.frame.origin.x-starIcon.frame.size.width/2.0 - 5,starNumLabel.center.y)];
    }
    else
    {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", num]];
        [string addAttributes:@{NSStrokeWidthAttributeName:@(-25),
                               NSStrokeColorAttributeName:[UIColor blackColor],
                               NSForegroundColorAttributeName:[UIColor whiteColor]
         } range:NSMakeRange(0, [string length])];
        
        [starNumLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:25]];
        [starNumLabel setAttributedText:string];
        [starNumLabel sizeToFit];
        //Increase the size of the starNumLabel frame in order to see the last part of the stroke
        starNumLabel.frame = CGRectMake(starNumLabel.frame.origin.x, starNumLabel.frame.origin.y,starNumLabel.frame.size.width+5, starNumLabel.frame.size.height);
        [starIcon setCenter:ccp(starNumLabel.frame.origin.x-starIcon.frame.size.width/2.0 - 5,starNumLabel.center.y)];
        
        [string release];
    }
}

//- (void) setContinueButtonVisibility:(BOOL)isVisible
//{
//    [continueButton setHidden:!isVisible];
//}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [tableview reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void) reloadTableview
{
    [tableview reloadData];
}

- (void)dealloc
{
    [tableview release];
    [equipmentTypesArray release];
//    [continueButton release];
    [backgroundView release];
    [backButton release];
    [storeButton release];
    [bottomImage release];
    [starIcon release];
    [starNumLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [starIcon release];
    starIcon = nil;
    [starNumLabel release];
    starNumLabel = nil;
    [super viewDidUnload];
}
@end

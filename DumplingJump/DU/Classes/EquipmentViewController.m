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
#import "UserData.h"
#import "DUIAPHelper.h"
#import "IAPCell.h"
#import "LoadingView.h"
#import "TutorialManager.h"

#define EQUIPMENT_DICT ((EquipmentData *)[EquipmentData shared]).structedDictionary

@interface EquipmentViewController()
{
    NSArray *_equipmentTypesArray;
    NSArray *_IAPTypesArray;
    NSArray *_productArray;
    LoadingView *loadingView;
    BOOL _loadSuccess;
    BOOL _isIAP;
    NSNumberFormatter * _priceFormatter;
}

@end

@implementation EquipmentViewController
@synthesize delegate = _delegate;

- (id)initWithDelegate:(id)theDelegate
{
    if (self = [super init])
    {
        _delegate = theDelegate;
        _isIAP = NO;
        _equipmentTypesArray = [[NSArray alloc] initWithObjects:@"powerups",@"special", nil];
        _IAPTypesArray = [[NSArray alloc] initWithObjects:@"premium", @"free", nil];
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        [BuyMoreStarViewController shared].delegate = self;
        
        
    }
    return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isIAP)
    {
        return [_IAPTypesArray count];
    }
    return [_equipmentTypesArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isIAP)
    {
        return [[[DUIAPHelper sharedInstance].dataDictionary objectForKey:[_IAPTypesArray objectAtIndex:section]] count];
    }
    return [[EQUIPMENT_DICT objectForKey:[_equipmentTypesArray objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DUTableViewCell *cell = nil;
    NSDictionary *cellData = nil;
    if (!_isIAP)
    {
        cellData = [[EQUIPMENT_DICT objectForKey:[_equipmentTypesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        NSString *equipmentName = [cellData objectForKey:@"name"];
        BOOL unlocked = YES;
        if ([[USERDATA objectForKey:equipmentName] intValue] < 0)
        {
            unlocked = NO;
        }
        
        Class cellClass = NSClassFromString([cellData objectForKey:@"layout"]);
        if (unlocked)
        {
            cell = (DUTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[cellData objectForKey:@"layout"]];
            if (cell == nil)
            {
                cell = [[[cellClass alloc] initWithXib:[cellData objectForKey:@"layout"] ] autorelease];
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
    }
    else
    {
        cellData = [[[DUIAPHelper sharedInstance].dataDictionary objectForKey:[_IAPTypesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        cell = [[[IAPCell alloc] initWithXib:@"IAPCell"] autorelease];
        
        if ([[cellData objectForKey:@"category"] isEqualToString:@"free"])
        {
            [(IAPCell *)cell updatePrice:@"FREE"];
        }
        else
        {
            for (SKProduct *product in _productArray)
            {
                if ([product.productIdentifier isEqualToString:[cellData objectForKey:@"productID"]])
                {
                    [_priceFormatter setLocale:product.priceLocale];
                    [(IAPCell *)cell updatePrice:[_priceFormatter stringFromNumber:product.price]];
                    [(IAPCell *)cell setProduct:product];
                }
            }
        }
    }
    cell.path = indexPath;
    cell.parentTableView = self;
    [cell setLayoutWithDictionary:cellData];
    
    if ([[TutorialManager shared] isInStoreTutorial])
    {
        if (indexPath.row != 0 || indexPath.section != 0)
        {
            [cell setUserInteractionEnabled:NO];
        }
    }
    
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
    
    if (_isIAP)
    {
        [titleLabel setText:[[_IAPTypesArray objectAtIndex:section] uppercaseString]];
    }
    else
    {
        [titleLabel setText:[[_equipmentTypesArray objectAtIndex:section] uppercaseString]];
    }
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
         if ([[TutorialManager shared] isInStoreTutorial])
         {
             //Back and store button disable
             [backButton setEnabled:NO];
             [storeButton setEnabled:NO];
         }
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
    [backButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    backButton.alpha = opacity;
    
    //when showing IAP view, don't show store button
    if (!(isEnabled && _isIAP))
    {
        [storeButton setEnabled:isEnabled];
        storeButton.alpha = opacity;
    }
}

- (void) setIAPButtonsEnabled:(BOOL)isEnabled
{
    [backButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    backButton.alpha = opacity;
}

- (void) showEquipmentView
{
    [tableview setHidden:NO];
    [noInternetMessageLabel setHidden:NO];
    [self equipmentViewFlyInAnimationWithTarget:nil selector:nil];
    noInternetMessageLabel.hidden = YES;
    if ([[TutorialManager shared] isInStoreTutorial])
    {
        [tutorialHintLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:23]];
        [tutorialHintLabel setText:@"Unlock BOOSTER"];
        [self createEquipmentviewTutorialMask];
        //0
        //Tableview scroll disable
        [tableview setScrollEnabled:NO];

        //1
        //Play UI fade animation
        [self playTutorialAnimation];
    }
}

- (void) hideEquipmentView
{
    [self equipmentViewFlyOutAnimationWithTarget:nil selector:nil];
}

- (void) playTutorialAnimation
{
    [tutorialHintLabel setAlpha:0];
    [UIView animateWithDuration:0.2 delay:1 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [tutorialHintLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:23]];
         [tutorialHintLabel setAlpha:1];
         [tutorialMask setAlpha:0.8];
     } completion:^(BOOL finished)
    {
         
     }];
}

- (IBAction)didBackButtonClicked:(id)sender
{
    if (_isIAP)
    {
        _isIAP = NO;
        [_productArray release];
        _productArray = nil;
        [self reloadTableview];
        [self equipmentViewFlyOutAnimationWithTarget:self selector:@selector(showEquipmentView)];
    }
    else
    {
        [self equipmentViewFlyOutAnimationWithTarget:self.delegate selector:@selector(didEquipmentViewBack)];
    }
}

- (IBAction)didStoreButtonClicked:(id)sender
{
    [self equipmentViewFlyOutAnimationWithTarget:self selector:@selector(loadIAP)];
}

- (void) loadIAP
{
    loadingView = [[LoadingView loadingViewInView:[[CCDirector sharedDirector] view] withTitle:@"Loading..."] retain];
    [[DUIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            _productArray = [products retain];
        }
        _loadSuccess = success;
        [self showIAPView];
    }];
}

- (void) showIAPView
{
    [loadingView removeView];
    [loadingView release];
    loadingView = nil;
    
    _isIAP = YES;
    if (_loadSuccess)
    {
        [tableview setHidden:NO];
        [noInternetMessageLabel setHidden:YES];
    }
    else
    {
        [tableview setHidden:YES];
        [noInternetMessageLabel setHidden:NO];
        [noInternetMessageLabel setFont:[UIFont fontWithName:@"Eras Bold ITC" size:18]];
        [noInternetMessageLabel setText:@"Cannot connect to the store.\n\nPlease check your Internet connection"];
    }
    [self reloadTableview];
    [self equipmentViewFlyInAnimationWithTarget:nil selector:nil];
}

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

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [tableview reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void) reloadTableview
{
    [tableview reloadData];
}

- (void) removeTutorial
{
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self setEquipmentButtonsEnabled:YES];
         [tableview setScrollEnabled:YES];
         [tutorialMask setAlpha:0];
         [tutorialHintLabel setAlpha:0];
     } completion:^(BOOL finished) {
         [self reloadTableview];
         [[TutorialManager shared] finishTutorial];
     }];
}

- (void) productPurchased:(NSNotification *)notification
{
    NSString * productID = notification.object;
    [[[DUIAPHelper sharedInstance].dataDictionary objectForKey:@"premium"] enumerateObjectsUsingBlock:^(NSDictionary *productData, NSUInteger idx, BOOL *stop) {
        if ([[productData objectForKey:@"productID" ] isEqualToString:productID])
        {
            if ([productID rangeOfString:@"ForeverDouble"].location != NSNotFound)
            {
                [USERDATA setObject:[NSNumber numberWithBool:YES] forKey:@"foreverDouble"];
            }
            else
            {
                int reward = [[productData objectForKey:@"reward"] intValue];
                int currentStar = [[USERDATA objectForKey:@"star"] intValue];
                [USERDATA setObject:[NSNumber numberWithInt:currentStar+reward] forKey:@"star"];
                [self updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
            }
            *stop = YES;
        }
    }];
    [self reloadTableview];
}

- (void) iapConfirmed
{
    [self equipmentViewFlyOutAnimationWithTarget:self selector:@selector(loadIAP)];
}

- (void) createEquipmentviewTutorialMask
{
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = CGRectMake(BLACK_HEIGHT, 0, 320, 480);
    
    CGRect rectInTableView = [tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect rectInSuperView = [tableview convertRect:rectInTableView toView:[tableview superview]];
    CGRect smallerRect = rectInSuperView;
    smallerRect.size = CGSizeMake(smallerRect.size.width-10, smallerRect.size.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor orangeColor] CGColor]];
    
    
    tutorialMask.layer.mask = maskWithHole;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tableview release];
    tableview = nil;
    [_equipmentTypesArray release];
    _equipmentTypesArray = nil;
    [backgroundView release];
    backgroundView = nil;
    [backButton release];
    backButton = nil;
    [storeButton release];
    storeButton = nil;
    [bottomImage release];
    bottomImage = nil;
    [starIcon release];
    starIcon = nil;
    [starNumLabel release];
    starNumLabel = nil;
    [noInternetMessageLabel release];
    noInternetMessageLabel = nil;
    [_productArray release];
    _productArray = nil;
    [_priceFormatter release];
    _priceFormatter = nil;
    [tutorialMask release];
    tutorialMask = nil;
    [tutorialHintLabel release];
    tutorialHintLabel = nil;
    [super dealloc];
}
@end

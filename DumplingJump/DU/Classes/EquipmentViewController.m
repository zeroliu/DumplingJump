//
//  EquipmentTableViewController.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-13.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "EquipmentViewController.h"
#import "Constants.h"

@implementation EquipmentViewController
@synthesize delegate = _delegate;

- (id)initWithDelegate:(id)theDelegate
{
    if (self = [super init])
    {
        _delegate = theDelegate;
    }
    return self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test"];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"] autorelease];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"test %ld", (long)indexPath.row];
    
    return cell;
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
         float destinationBottom = backgroundView.bounds.size.height - bottomImage.bounds.size.height/2;
         bottomImage.center = ccp(winSize.width/2.0, destinationBottom);
         
     } completion:^(BOOL finished) {
 
     }];
}

- (void) hideEquipmentView
{
    
}

- (void)dealloc
{
    [continueButton release];
    [backgroundView release];
    [backButton release];
    [storeButton release];
    [bottomImage release];
    [super dealloc];
}

- (IBAction)didBackButtonClicked:(id)sender
{
    [UIView animateWithDuration:0.1 delay:0.1 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self setEquipmentButtonsEnabled:NO];
     } completion:^(BOOL finished) {
         
     }];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         CGSize winSize = [[CCDirector sharedDirector] winSize];
         //move background image
         backgroundView.center = ccp(winSize.width/2.0, backgroundView.bounds.size.height * 3/2);
         //move bottom image
         float destinationBottom = backgroundView.bounds.size.height + bottomImage.bounds.size.height/2;
         bottomImage.center = ccp(winSize.width/2.0, destinationBottom);
    
     } completion:^(BOOL finished) {
         if ([self.delegate respondsToSelector:@selector(didEquipmentViewBack)])
         {
             [self.delegate performSelector:@selector(didEquipmentViewBack)];
         }
     }];
}



- (IBAction)didStoreButtonClicked:(id)sender
{
}

- (IBAction)didContinueButtonClicked:(id)sender
{
    
    //Show Equipment buttons
    [UIView animateWithDuration:0.1 delay:0.1 options:(UIViewAnimationOptionCurveLinear) animations:^
     {
         [self setEquipmentButtonsEnabled:NO];
     } completion:^(BOOL finished) {
         
     }];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^
     {
         CGSize winSize = [[CCDirector sharedDirector] winSize];
         //move background image
         float destinationBG = backgroundView.bounds.size.height*3/2;
         backgroundView.center = ccp(winSize.width/2.0, destinationBG);
         //move bottom image
         float destinationBottom = winSize.height + bottomImage.bounds.size.height/2;
         bottomImage.center = ccp(winSize.width/2.0, destinationBottom);
     } completion:^(BOOL finished) {
         
         if ([self.delegate respondsToSelector:@selector(didEquipmentViewContinue)])
         {
             [self.delegate performSelector:@selector(didEquipmentViewContinue)];
         }
         
     }];

}

@end

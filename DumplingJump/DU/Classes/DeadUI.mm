//
//  DeadUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DeadUI.h"
#import "LevelManager.h"
#import "HeroManager.h"
#import "BoardManager.h"
#import "CCBReader.h"

@implementation DeadUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DeadUI alloc] init];
    }
    return shared;
}

-(void) createUI
{
    [super createUI];
    [self createEquipmentView];
}

- (void) createEquipmentView
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    equipmentViewController = [[EquipmentViewController alloc] initWithDelegate:self];
    equipmentView = [[[NSBundle mainBundle] loadNibNamed:@"EquipmentView" owner:equipmentViewController options:nil] objectAtIndex:0];
    equipmentView.center = ccp(winSize.width/2, winSize.height/2);
    equipmentView.layer.zPosition = Z_SECONDARY_UI;
    [equipmentView setHidden:YES];
    [VIEW addSubview:equipmentView];

    [equipmentViewController hideEquipmentView];
    [equipmentViewController setContinueButtonVisibility:NO];
}

- (void) showEquipment
{
    [equipmentView setHidden:NO];
    [equipmentViewController showEquipmentView];
    [equipmentViewController updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
}

- (void) didEquipmentViewBack
{
    [equipmentView setHidden:YES];
    [self setDeadUIVisible:YES callback:nil];
    [self setButtonsEnable:YES];
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadUI.ccbi";
        priority = Z_DEADUI;
        winsize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}

-(void) updateUIDataWithScore:(int)score Star:(int)star TotalStar:(int)totalStar Distance:(int)distance Multiplier:(float)multiplier IsHighScore:(BOOL)isHighScore
{
    [scoreText setString:[NSString stringWithFormat:@"%d",score]];
    [starText setString:[NSString stringWithFormat:@"%d",star]];
    [totalStarText setString:[NSString stringWithFormat:@"%d",totalStar]];
    [distanceText setString:[NSString stringWithFormat:@"%d",distance]];
    [multiplierText setString:[NSString stringWithFormat:@"%gx",multiplier]];
    if (isHighScore)
    {
        [highscoreSprite setOpacity:255];
    }
    else
    {
        [highscoreSprite setOpacity:0];
    }
}

-(void) retry:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Fade White"];
    id delay = [CCDelayTime actionWithDuration:0.2f];
    id restartFunc = [CCCallFunc actionWithTarget:[[Hub shared] gameLayer] selector:@selector(restart)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay,restartFunc,selfDestruction, nil];
    [node runAction:sequence];
}

-(void) didArsenalTapped:(id)sender
{
    [self setDeadUIVisible:NO callback:@selector(showEquipment)];
    [self setButtonsEnable:NO];
}

-(void) setButtonsEnable:(BOOL)isEnable
{
    [homeButton setEnabled:isEnable];
    [missionButton setEnabled:isEnable];
    [equipmentButton setEnabled:isEnable];
    [retryButton setEnabled:isEnable];
    [facebookButton setEnabled:isEnable];
    [twitterButton setEnabled:isEnable];
}

-(void) home:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"]]];
}

- (void) setDeadUIVisible:(BOOL)isVisible callback:(SEL)selector
{
    CGPoint targetPosition;
    DLog(@"%g,%g",rideAgainSprite.position.x, rideAgainSprite.position.y);
    if (isVisible)
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height/2.0);
    }
    else
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height*1.5);
    }
    
    id moveToAnim = [CCMoveTo actionWithDuration:0.1 position:targetPosition];
    //id moveToAnim = [CCEaseInOut actionWithAction:moveToAnimRaw];
    if (selector != nil)
    {
        id callbackFunc = [CCCallFunc actionWithTarget:self selector:selector];
        [rideAgainSprite runAction:[CCSequence actions:moveToAnim, callbackFunc, nil]];
    }
    else
    {
        [rideAgainSprite runAction:moveToAnim];
    }
}

- (void) dealloc
{
    [super dealloc];
    [homeButton release];
    [missionButton release];
    [equipmentButton release];
    [retryButton release];
    [facebookButton release];
    [twitterButton release];
    [highscoreSprite release];
    [newItemSprite release];
    [rideAgainSprite release];
    
    [scoreText release];
    [starText release];
    [totalStarText release];
    [distanceText release];
    [multiplierText release];
    [equipmentViewController release];
}

@end

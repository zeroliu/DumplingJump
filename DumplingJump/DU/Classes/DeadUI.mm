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
}

- (void) showEquipment
{
    [equipmentView setHidden:NO];
    [equipmentViewController showEquipmentView];
    //TODO: get star number from user data
    [equipmentViewController updateStarNum:200];
}

- (void) didEquipmentViewBack
{
    [equipmentView setHidden:YES];
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadUI.ccbi";
        priority = Z_DEADUI;
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
}

-(void) retry:(id)sender
{
    DLog(@"retry");
    [animationManager runAnimationsForSequenceNamed:@"Fade White"];
    id delay = [CCDelayTime actionWithDuration:0.2f];
    id restartFunc = [CCCallFunc actionWithTarget:[[Hub shared] gameLayer] selector:@selector(restart)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay,restartFunc,selfDestruction, nil];
    [node runAction:sequence];
}

-(void) didArsenalTapped:(id)sender
{
    [self showEquipment];
}

-(void) home:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"]]];
}

@end

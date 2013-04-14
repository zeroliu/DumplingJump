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
#import "DeadAchievementUI.h"
#import "CCBReader.h"
#import "EquipmentData.h"
#import "AchievementNode.h"
#import "AchievementManager.h"

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

- (void) didAchievementTapped:(id)sender
{
    [self setDeadUIVisible:NO callback:@selector(showAchievement)];
    [self setButtonsEnable:NO];
}

- (void) showAchievement
{
    [[DeadAchievementUI shared] createUI];
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
    [self showDeadUI];
}

- (void) showDeadUI
{
    [self setDeadUIVisible:YES callback:nil];
    [self setButtonsEnable:YES];
    [self updateNewItemSign];
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
    [multiplierText setString:[NSString stringWithFormat:@"%dx",[[USERDATA objectForKey:@"multiplier"] intValue]]];
    if (isHighScore)
    {
        [highscoreSprite setOpacity:255];
    }
    else
    {
        [highscoreSprite setOpacity:0];
    }
    
    [self updateNewItemSign];
}

-(void) updateNextMission:(NSDictionary *)nextMissionData
{
    [nextMission.UnlockIcon setVisible:NO];
    
    //update title
    [nextMission.MissionName setString:[nextMissionData objectForKey:@"name"]];
    
    //update description
    NSString *description2 = [nextMissionData objectForKey:@"description2"];
    if (description2 == nil)
    {
        description2 = @"";
    }
    [nextMission.DescriptionText setString:[NSString stringWithFormat:@"%@ %d %@", [nextMissionData objectForKey:@"description1"], [[nextMissionData objectForKey:@"number"] intValue], description2]];
    
    //percentage of how much you have finished (for life type)
    float percentage = [[AchievementManager shared] getFinishPercentageWithType:[nextMissionData objectForKey:@"type"] target:[[nextMissionData objectForKey:@"number"] floatValue]];
    
    [nextMission.Bar setScaleY:percentage];
}

-(void) updateNewItemSign
{
    int unlockItemNum = [[EquipmentData shared] isAffordable:[[USERDATA objectForKey:@"star"] intValue]];
    if (unlockItemNum > 0)
    {
        [newItemSprite setVisible:YES];
        [newItemText setVisible:YES];
        [newItemText setString:[NSString stringWithFormat:@"%d",unlockItemNum]];
        [self animateExclamationSign];
    }
    else
    {
        [newItemSprite setVisible:NO];
        [newItemText setVisible:NO];
    }
}

-(void) animateExclamationSign
{

//===========================================
//===========UNUSED SHAKE EFFECT=============
//===========================================
//    NSMutableArray *actions = [NSMutableArray array];
    
//    id changeToRed = [CCCallBlock actionWithBlock:^{
//        CCSpriteFrame *warningRed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_play_warning.png"];
//        [newItemSprite setDisplayFrame:warningRed];
//    }];
//    [actions addObject:changeToRed];
//    int direction = 1;
//    for (int i=0; i<50; i++)
//    {
//        float angle;
//        if (direction > 0)
//        {
//            angle = randomFloat(5.0, 25.0);
//        }
//        else
//        {
//            angle = randomFloat(-25.0, -5.0);
//        }
//        direction = direction * -1;
//        
//        id rotate = [CCRotateTo actionWithDuration:0.05 angle:angle];
//        [actions addObject:rotate];
//    }
//    id changeToNormal = [CCCallBlock actionWithBlock:^{
//        CCSpriteFrame *warningNormal = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"UI_retry_expression.png"];
//        [newItemSprite setDisplayFrame:warningNormal];
//        [newItemSprite setRotation:0];
//    }];
//    [actions addObject:changeToNormal];
//    id delay = [CCDelayTime actionWithDuration:2];
//    id restart = [CCCallFunc actionWithTarget:self selector:@selector(animateExclamationSign)];
//    [actions addObject:delay];
//    [actions addObject:restart];
    
    [newItemSprite stopAllActions];
    id scaleUp = [CCScaleTo actionWithDuration:0.1 scale:1.2];
    id scaleDown = [CCScaleTo actionWithDuration:0.4 scale:1];
    id restart = [CCCallFunc actionWithTarget:self selector:@selector(animateExclamationSign)];
    
    [newItemSprite runAction:[CCSequence actions:scaleUp, scaleDown, restart,nil]];
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
    [newItemText release];
    [equipmentViewController release];
    
    [nextMission release];
}

@end

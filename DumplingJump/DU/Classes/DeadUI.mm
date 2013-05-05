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

@interface DeadUI()
@property (nonatomic, assign) int finalScore;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) int scoreDisplay;

@end

@implementation DeadUI
@synthesize isNew = _isNew;
@synthesize finalScore = _finalScore;
@synthesize distance = _distance;
@synthesize scoreDisplay = _scoreDisplay;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DeadUI alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadUI.ccbi";
        priority = Z_DEADUI;
        winsize = [[CCDirector sharedDirector] winSize];
        _isNew = NO;
        _scoreDisplay = 0;
    }
    return self;
}

-(void) createUI
{
    [super createUI];
    [self createEquipmentView];
    [self updateNewAchievementSign];
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
    _isNew = NO;
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
    [self updateNewAchievementSign];
}

- (void) updateNewAchievementSign
{
    if (_isNew)
    {
        [newAchievement stopAllActions];
        id scaleUp = [CCScaleTo actionWithDuration:0.1 scale:1.2];
        id scaleDown = [CCScaleTo actionWithDuration:0.4 scale:1];
        [newAchievement runAction:[CCRepeatForever actionWithAction: [CCSequence actions:scaleUp, scaleDown, nil]]];
        
        [newAchievement setVisible:YES];
    }
    else
    {
        [newAchievement stopAllActions];
        [newAchievement setVisible:NO];
    }
}

-(void) updateUIDataWithScore:(int)score Star:(int)star TotalStar:(int)totalStar Distance:(int)distance Multiplier:(float)multiplier IsHighScore:(BOOL)isHighScore
{
    _finalScore = score;
    _distance = distance;
    _scoreDisplay = 0;
    [scoreText setString:@"0"];
    [starText setString:[NSString stringWithFormat:@"%d",star]];
    [totalStarText setString:[NSString stringWithFormat:@"%d",totalStar]];
    [distanceText setString:[NSString stringWithFormat:@"%d",distance]];
    [multiplierText setString:[NSString stringWithFormat:@"%dx",(int)multiplier]];
    [highscoreSprite setOpacity:0];
//    if (isHighScore)
//    {
//        [highscoreSprite setOpacity:255];
//    }
//    else
//    {
//        [highscoreSprite setOpacity:0];
//    }
    
    [self updateNewItemSign];
    
    [self performSelector:@selector(playShowDistanceEffect) withObject:nil afterDelay:0.8];
}

-(void) playShowDistanceEffect
{
    //distance label pop
    id tweenDistance = [CCActionTween actionWithDuration:0.4 key:@"scoreDisplay" from: 0 to: _distance];
    [distanceText runAction:[self createPopMoveEffectWithDistance:15]];
    [distanceText runAction:[self createPopScaleEffect]];
    [self runAction:tweenDistance];
    //score label pop
    [scoreText runAction:[self createPopMoveEffectWithDistance:25]];
    [scoreText runAction:[self createPopScaleEffect]];
    
    [self updateScoreLabel:[NSNumber numberWithInt:_distance]];
    
    //Show score effect if multiplier is greater than 1
    if ([[USERDATA objectForKey:@"multiplier"] intValue] > 1)
    {
        [self performSelector:@selector(playShowScoreEffect) withObject:nil afterDelay:0.7];
    }
}

-(void) playShowScoreEffect
{
    id tweenScore = [CCActionTween actionWithDuration:0.4 key:@"scoreDisplay" from: _distance to: _finalScore];
    
    //multiplier label pop
    [multiplierText runAction:[self createPopMoveEffectWithDistance:15]];
    [multiplierText runAction:[self createPopScaleEffect]];
    [self runAction:tweenScore];
    
    //score label pop
    [scoreText runAction:[self createPopMoveEffectWithDistance:25]];
    [scoreText runAction:[self createPopScaleEffect]];
    
    [self updateScoreLabel:[NSNumber numberWithInt:_finalScore]];
}

-(void) updateScoreLabel:(NSNumber *)target
{
    if (_scoreDisplay <= [target intValue])
    {
        [scoreText setString:[NSString stringWithFormat:@"%d", (int)_scoreDisplay]];
        if (_scoreDisplay < [target intValue])
        {
            [self performSelector:@selector(updateScoreLabel:) withObject:target afterDelay:0.01];
        }
    }
}

-(id) createPopMoveEffectWithDistance:(float)distance
{
    id moveUp = [CCMoveBy actionWithDuration:0.2 position:ccp(0,distance)];
    id moveDown = [CCMoveBy actionWithDuration:0.2 position:ccp(0,-distance)];
    return [CCSequence actions:moveUp, moveDown, nil];
}

-(id) createPopScaleEffect
{
    id scaleUp = [CCScaleTo actionWithDuration:0.15 scale:1.3];
    id scaleDown = [CCScaleTo actionWithDuration:0.15 scale:1];
    return [CCSequence actions:scaleUp, scaleDown, nil];
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
    if (isVisible)
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height/2.0);
    }
    else
    {
        targetPosition = ccp(winsize.width/2.0, winsize.height*1.5);
    }
    
    id moveToAnim = [CCMoveTo actionWithDuration:0.1 position:targetPosition];
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
    [equipmentViewController release];
    [super dealloc];
}

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
@end

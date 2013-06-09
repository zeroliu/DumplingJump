//
//  AchievementUnlockUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AchievementUnlockUI.h"
#import "AchievementManager.h"
#import "AchievementData.h"
#import "AchievementNode.h"
#import "DeadUI.h"
#import "CCBReader.h"
#import "UserData.h"
#import "ItemUnlockUI.h"
#import "GameUI.h"
#import "Constants.h"

#define TRANSITION_ANIM @"UI_mission_item_transition"
@implementation AchievementUnlockUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AchievementUnlockUI alloc] init];
        
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"AchievementUnlockUI.ccbi";
        priority = Z_DEADUI+1;
        winsize = [[CCDirector sharedDirector] winSize];
        [self registerAnimationForName:TRANSITION_ANIM];
    }
    
    return self;
}

-(void) registerAnimationForName:(NSString *)name
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=5; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"%@_%d.png",TRANSITION_ANIM,i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id animObject = [CCAnimation animationWithSpriteFrames :frameArray delay:ANIMATION_DELAY_INBETWEEN];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animObject name:TRANSITION_ANIM];
}

-(void) createUI
{
    [super createUI];
    
    //load achievement data
    [missionNode drawWithAchievementDataWithGroupID:[[USERDATA objectForKey:@"achievementGroup"] intValue]];
    
    //hide forward button
    [forwardButton setOpacity:0];
    [forwardButton setEnabled:NO];
    
    //hide new unlocked achievement star icons
    NSArray *unlockedEvents = [[AchievementManager shared] getUnlockedEvents];
    NSMutableArray *animationArray = [NSMutableArray array];
    
    for (NSDictionary *achievement in unlockedEvents)
    {
        int achievementID = [[achievement objectForKey:@"id"] intValue];
        AchievementNode *achievementNode = ((AchievementNode *)[missionNode.missionArray objectAtIndex:achievementID-1]);
        CCSprite *unlockIcon = achievementNode.UnlockIcon;
        [unlockIcon setOpacity:0];
        unlockIcon.scale = 5;
        unlockIcon.zOrder = 100;
        id callbackBlock = [CCCallBlock actionWithBlock:^{
            id actionFadeIn = [CCFadeIn actionWithDuration:0.1];
            id actionScaleDown = [CCScaleTo actionWithDuration:0.3 scale:1];
            achievementNode.zOrder = 100;
            [unlockIcon runAction:[CCEaseExponentialIn actionWithAction: actionFadeIn]];
            [unlockIcon runAction:[CCEaseExponentialIn actionWithAction: actionScaleDown]];
        }];
        id delay = [CCDelayTime actionWithDuration:0.3];
        id hitEffect = [CCCallBlock actionWithBlock:^{
            CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_coinstarGet.ccbi" parent:unlockIcon.parent z:unlockIcon.zOrder+1];
            particleNode.position = unlockIcon.position;
            id shakeStep1 = [CCMoveTo actionWithDuration:0.01 position:ccp(nodeHolder.position.x+8, nodeHolder.position.y-8)];
            id wait = [CCDelayTime actionWithDuration:0.08];
            id shakeStep2 = [CCMoveTo actionWithDuration:0.01 position:ccp(nodeHolder.position.x, nodeHolder.position.y)];
            [nodeHolder runAction:[CCSequence actions:shakeStep1, wait, shakeStep2, nil]];
        }];
        id delayAgain = [CCDelayTime actionWithDuration:0.2];
        [animationArray addObject:callbackBlock];
        [animationArray addObject:[CCSequence actions:delay, hitEffect, delayAgain, nil]];
    }
    [[AchievementManager shared] removeAllUnlockedEvent];
    
    //Play animation
    id delay = [CCDelayTime actionWithDuration:0.5];
    id animationSequence = [CCSequence actionWithArray:animationArray];
    
    //If unlocked all the four achievements
    //show the transitiion animation and automatically switch to itemGet
    if ([[AchievementData shared] hasUnlockedAllAchievementsByGroup:[[USERDATA objectForKey:@"achievementGroup"] intValue]])
    {
        id aShortWait = [CCDelayTime actionWithDuration:0.8];
        id transitionSpriteFadeIn = [CCCallBlock actionWithBlock:^{
            [missionNode.TransitionAnim runAction:[CCFadeIn actionWithDuration:0.4]];
        }];
        
        id delay2 = [CCDelayTime actionWithDuration:0.2];
        
        id transitionAnim = [CCCallBlock actionWithBlock:^{
            id animate = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:TRANSITION_ANIM]];
            [missionNode.TransitionAnim runAction:animate];
        }];
        
        id showWhiteEffect = [CCCallBlock actionWithBlock:^{
            id whiteEffectDelay = [CCDelayTime actionWithDuration:0.3];
            id whiteEffectFadeIn = [CCFadeIn actionWithDuration:0.2];
            id switchToItemGet = [CCCallBlock actionWithBlock:^{
                [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
                id delay = [CCDelayTime actionWithDuration:0.3];
                id resumeGameFunc = [CCCallFunc actionWithTarget:[ItemUnlockUI shared] selector:@selector(createUI)];
                id whiteEffectFadeOut = [CCCallBlock actionWithBlock:^{
                    [whiteMask runAction:[CCFadeOut actionWithDuration:0.4]];
                }];
                id waitForFadeOut = [CCDelayTime actionWithDuration:0.4];
                id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
                id sequence = [CCSequence actions:delay, resumeGameFunc, whiteEffectFadeOut, waitForFadeOut, selfDestruction, nil];
                [nodeHolder runAction:sequence];
            }];

            [whiteMask runAction:[CCSequence actions:whiteEffectDelay, whiteEffectFadeIn, switchToItemGet, nil]];
        }];
        
                
        [node runAction:[CCSequence actions:delay, animationSequence, aShortWait, transitionSpriteFadeIn, delay2, transitionAnim, showWhiteEffect,  nil]];
    }
    else
    {
        //If not, show the forward button and switch to dead ui
        id showForwardButton = [CCCallBlock actionWithBlock:^{
            [forwardButton runAction:[CCFadeIn actionWithDuration:0.3]];
            [forwardButton setEnabled:YES];
        }];
        
        [node runAction:[CCSequence actions:delay, animationSequence, showForwardButton, nil]];
    }
    
    [forwardButton setEnabled:YES];
}

-(void)didTapFoward:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [forwardButton setEnabled:NO];
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(showDeadUI)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void) dealloc
{
//    [nodeHolder release];
//    [missionNode release];
//    [forwardButton release];
//    [whiteMask release];
    [super dealloc];
}

@end

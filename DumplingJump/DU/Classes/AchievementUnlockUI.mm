//
//  AchievementUnlockUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AchievementUnlockUI.h"
#import "AchievementManager.h"
#import "AchievementNode.h"
#import "DeadUI.h"
#import "CCBReader.h"
#import "UserData.h"

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
            id actionFadeIn = [CCFadeIn actionWithDuration:0.05];
            id actionScaleDown = [CCScaleTo actionWithDuration:0.3 scale:1];
            achievementNode.zOrder = 100;
            [unlockIcon runAction:actionFadeIn];
            [unlockIcon runAction:actionScaleDown];
        }];
        id delay = [CCDelayTime actionWithDuration:0.2];
        [animationArray addObject:callbackBlock];
        [animationArray addObject:delay];
    }
    
    //Play animation
    id delay = [CCDelayTime actionWithDuration:0.5];
    id animationSequence = [CCSequence actionWithArray:animationArray];
    
    //Check if unlock the item
    //if yes
    //show the item unlock screen
    
    
    //Show the forward button
    id showForwardButton = [CCCallBlock actionWithBlock:^{
        [forwardButton runAction:[CCFadeIn actionWithDuration:0.3]];
        [forwardButton setEnabled:YES];
    }];
    
    [node runAction:[CCSequence actions:delay, animationSequence, showForwardButton, nil]];
    
    [[AchievementManager shared] removeAllUnlockedEvent];
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"AchievementUnlockUI.ccbi";
        priority = Z_DEADUI+1;
        winsize = [[CCDirector sharedDirector] winSize];
    }
    
    return self;
}

-(void)didTapFoward:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(showDeadUI)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void) dealloc
{
    [missionNode release];
    [forwardButton release];
    [super dealloc];
}

@end

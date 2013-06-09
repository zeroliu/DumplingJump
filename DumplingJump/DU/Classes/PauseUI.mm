//
//  PauseUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "PauseUI.h"
#import "AchievementNode.h"

@implementation PauseUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[PauseUI alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"PauseUI.ccbi";
        priority = Z_PAUSEUI;
    }
    
    return self;
}

-(void) createUI
{
    [super createUI];
    [missionNode drawWithAchievementDataWithGroupID:[[USERDATA objectForKey:@"achievementGroup"] intValue]];
    [retryButton setEnabled:YES];
    [forwardButton setEnabled:YES];
}

-(void)resumeGame:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [forwardButton setEnabled:NO];
    [[AudioManager shared] setBackgroundMusicVolume:1];
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(resumeGame)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

-(void)restartGame:(id)sender
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [retryButton setEnabled:NO];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id restartGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(restart)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, restartGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void)dealloc
{
    [missionNode release];
    [super dealloc];
}
@end

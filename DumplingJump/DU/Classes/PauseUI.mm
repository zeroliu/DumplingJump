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
    [((AchievementNode *)[missionNode.missionArray objectAtIndex:0]).MissionName setString:@"test"];
}

-(void)resumeGame:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(resumeGame)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

-(void)restartGame:(id)sender
{
    id delay = [CCDelayTime actionWithDuration:0.2];
    id restartGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(restart)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, restartGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}
@end

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

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadUI.ccbi";
        priority = Z_DEADUI;
    }
    
    return self;
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

-(void) home:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"]]];
    
}

-(void) test:(id)sender
{
}

@end

//
//  DeadAchievementUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DeadAchievementUI.h"
#import "DeadUI.h"
#import "CCBReader.h"
#import "UserData.h"

@implementation DeadAchievementUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DeadAchievementUI alloc] init];
    }
    return shared;
}

-(void) createUI
{
    [super createUI];
    [missionNode drawWithAchievementDataWithGroupID:[[USERDATA objectForKey:@"achievementGroup"] intValue]];
    [forwardButton setEnabled:YES];
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"DeadAchievementUI.ccbi";
        priority = Z_DEADUI+1;
        winsize = [[CCDirector sharedDirector] winSize];
    }
    
    return self;
}

-(void)didTapFoward:(id)sender
{
    [forwardButton setEnabled:NO];
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:[DeadUI shared] selector:@selector(showDeadUI)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void) dealloc
{
    [missionNode release];
    [super dealloc];
}

@end

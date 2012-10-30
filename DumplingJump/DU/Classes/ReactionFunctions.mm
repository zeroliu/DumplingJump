//
//  ReactionFunctions.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ReactionFunctions.h"
#import "GameLayer.h"
#import "BoardManager.h"
#import "AddthingObject.h"
@implementation ReactionFunctions

+(id) shared
{
    static id shared = nil;
    if(shared == nil)
    {
        shared = [[ReactionFunctions alloc] init];
    }
    
    return shared;
}

-(void) testFunction
{
    DLog(@"test test");
}

-(void) explode:(id)source data:(void*)data
{
     CCSprite *target = (CCSprite *)source;
    if (target.position.x > [[CCDirector sharedDirector] winSize].width/2)
    {
        [self explode_r:source data:data];
    } else
    {
        [self explode_l:source data:data];
    }
    DLog(@"explode");
}

-(void) explode_l:(id)source data:(void*)data
{
    Reaction *reaction = (Reaction *)data;
    
    [[[BoardManager shared] getBoard] missleEffectWithDirection:0];
    id delay = [CCDelayTime actionWithDuration:reaction.reactionLasting];
    id functionWrapper = [CCCallFunc actionWithTarget:[[BoardManager shared] getBoard] selector:@selector(recover)];
    id sequence = [CCSequence actions:delay,functionWrapper, nil];
    [((Board *)[[BoardManager shared] getBoard]).sprite runAction:sequence];

   DLog(@"explode_l");
}

-(void) explode_r:(id)source data:(void*)data
{
    Reaction *reaction = (Reaction *)data;
    
    [[[BoardManager shared] getBoard] missleEffectWithDirection:1];
    id delay = [CCDelayTime actionWithDuration:reaction.reactionLasting];
    id functionWrapper = [CCCallFunc actionWithTarget:[[BoardManager shared] getBoard] selector:@selector(recover)];
    id sequence = [CCSequence actions:delay,functionWrapper, nil];
    [((Board *)[[BoardManager shared] getBoard]).sprite runAction:sequence];
    
    DLog(@"explode_r");
}
@end

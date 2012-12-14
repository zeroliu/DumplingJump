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
#import "HeroManager.h"
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
    CCSprite *engine = ((Board *)[[BoardManager shared] getBoard]).engineLeft;
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM_BROKEN];
    if(animation != nil)
    {
        [engine stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
        [engine runAction:animAction];
    }
    
    [[[BoardManager shared] getBoard] missleEffectWithDirection:0];
    id delay = [CCDelayTime actionWithDuration:reaction.reactionLasting];
    id functionWrapper = [CCCallFunc actionWithTarget:[[BoardManager shared] getBoard] selector:@selector(recover)];
    [engine stopAllActions];
    id engineRecover = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM_RECOVER]];
    id engineAnimPlay = [CCCallBlock actionWithBlock:^
                         {
                             [engine stopAllActions];
                             [engine runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM]]]];
                         }];
    
    id sequence = [CCSequence actions:delay,functionWrapper, nil];
    id engineSequence = [CCSequence actions:delay, engineRecover, engineAnimPlay, nil];
    [engine runAction:engineSequence];
    [((Board *)[[BoardManager shared] getBoard]).sprite runAction:sequence];


   DLog(@"explode_l");
}

-(void) explode_r:(id)source data:(void*)data
{
    Reaction *reaction = (Reaction *)data;
    CCSprite *engine = ((Board *)[[BoardManager shared] getBoard]).engineRight;
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM_BROKEN];
    if(animation != nil)
    {
        [engine stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
        [engine runAction:animAction];
    }

    [[[BoardManager shared] getBoard] missleEffectWithDirection:1];
    id delay = [CCDelayTime actionWithDuration:reaction.reactionLasting];
    id functionWrapper = [CCCallFunc actionWithTarget:[[BoardManager shared] getBoard] selector:@selector(recover)];
    id engineRecover = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM_RECOVER]];
    id engineAnimPlay = [CCCallBlock actionWithBlock:^
                         {
                             [engine stopAllActions];
                             [engine runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:ANIM_BROOM]]]];
                         }];
    
    id sequence = [CCSequence actions:delay,functionWrapper, nil];
    id engineSequence = [CCSequence actions:delay, engineRecover, engineAnimPlay, nil];
    [engine runAction:engineSequence];
    [((Board *)[[BoardManager shared] getBoard]).sprite runAction:sequence];
    
    DLog(@"explode_r");
}

/*
 * We did some tricks here by reusing the code of heromanager -> heroReactWithReaction
 * In order to do that, we need to pass the reaction name, hero animation name and reaction duration
 * Then, hardcode the selector name that you want to trigger in this reaction
 * Different from heroRactionWithReaction, the param for the function is not a string but an id
 * We did that just because I am lazy and I don't want to parse the string, lol
 */

-(void) bow:(id)source data:(void*)data
{
    CCSprite *target = (CCSprite *)source;
    Reaction *reaction = (Reaction *)data;
    
    [[HeroManager shared] heroReactWithReactionName:reaction.name heroAnimName:reaction.heroReactAnimationName reactionLasting:reaction.reactionLasting heroSelectorName:@"bowEffect" heroSelectorParam:[NSValue valueWithCGPoint: target.position]];
    
    DLog(@"bow reaction %g,%g", target.position.x, target.position.y);
}
@end

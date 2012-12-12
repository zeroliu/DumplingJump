//
//  DUParticleManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-11.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUParticleManager.h"
#import "CCParticleSystemQuad.h"
#import "CCBReader.h"
@implementation DUParticleManager
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DUParticleManager alloc] init];
    }
    return shared;
}

-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z
{
    return [self createParticleWithName:ccbiFileName parent:parent z:z duration:-1 life:-1];
}

-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z duration:(float)duration life:(float)life
{
    return [self createParticleWithName:ccbiFileName parent:parent z:z duration:-1 life:-1 following:nil];
}

-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z duration:(float)duration life:(float)life following:(CCNode *)follower
{
    CCNode *node = [CCBReader nodeGraphFromFile:ccbiFileName];
    float duration_;
    float life_;
    
    if (follower != nil)
    {
        id delay = [CCDelayTime actionWithDuration:0.01];
        id followAction = [CCCallBlock actionWithBlock:^
                           {
                               node.position = follower.position;
                           }];
        [node runAction:[CCRepeatForever actionWithAction: [CCSequence actions:delay, followAction, nil]]];
    }
    
    if (duration > 0)
    {
        duration_ = duration;
        life_ = life;
    } else
    {
        for (id particle in [node children])
        {
            if ([particle isMemberOfClass:[CCParticleSystemQuad class]])
            {
                //NSLog(@"Find one particle");
                duration_ = max(((CCParticleSystemQuad*)particle).duration, duration_);
                life_ = max(((CCParticleSystemQuad*)particle).life+ABS(((CCParticleSystemQuad*)particle).lifeVar), life_);
            }
        }
    }
    
    id delayDuration = [CCDelayTime actionWithDuration:duration_];
    id stopEmiting = [CCCallBlock actionWithBlock:^
                      {
                          NSLog(@"duration = %g", duration_);
                          for (id particle in [node children])
                          {
                              if ([particle isMemberOfClass:[CCParticleSystemQuad class]])
                              {
                                  [((CCParticleSystemQuad*)particle) stopSystem];
                              }
                          }
                      }];
    id delayLife_ = [CCDelayTime actionWithDuration:life_];
    id removeParticle = [CCCallBlock actionWithBlock:^
                    {
                        NSLog(@"life = %g", life_);
                        [node stopAllActions];
                        [node removeFromParentAndCleanup:YES];
                    }];
    
    [parent addChild:node];
    [parent runAction:[CCSequence actions:delayDuration,stopEmiting,delayLife_,removeParticle, nil]];
    
    return node;
}

@end

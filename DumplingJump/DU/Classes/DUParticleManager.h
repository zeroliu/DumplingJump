//
//  DUParticleManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-11.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface DUParticleManager : CCNode
+(id) shared;

-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z;

-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z duration:(float)duration life:(float)life;

/*
 *  Use the follower if the particle need to follow a sprite
 */
 
-(CCNode *) createParticleWithName:(NSString *)ccbiFileName parent:(id)parent z:(int)z duration:(float)duration life:(float)life following:(CCNode *)follower;

@end

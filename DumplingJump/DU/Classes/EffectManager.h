//
//  EffectManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface EffectManager : CCNode

+(id) shared;

-(void) PlayEffectWithName:(NSString *)effectName position:(CGPoint)thePosition;

@end

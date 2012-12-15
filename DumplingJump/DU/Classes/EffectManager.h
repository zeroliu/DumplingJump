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

-(id) PlayEffectWithName:(NSString *)effectName position:(CGPoint)thePosition;
-(id) PlayEffectWithName:(NSString *)effectName position:(CGPoint)thePosition z:(int)theZ parent:(id)theParent;
@end

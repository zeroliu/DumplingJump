//
//  Hero.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface Hero : DUPhysicsObject

-(id) initHeroWithName:(NSString *)theName position:(CGPoint)thePosition;
-(void) updateHeroPositionWithAccX:(float)accX;
-(void) jump;
@end

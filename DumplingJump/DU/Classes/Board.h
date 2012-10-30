//
//  Board.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface Board : DUPhysicsObject

-(id) initBoardWithBoardName:(NSString *)theName spriteName:(NSString *)fileName position:(CGPoint) pos;

-(void) missleEffectWithDirection:(int)direction; //0:left, 1:right
-(void) recover;
@end

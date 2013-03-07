//
//  Board.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface Board : DUPhysicsObject
@property (nonatomic, retain) CCSprite *engineLeft;
@property (nonatomic, retain) CCSprite *engineRight;

-(id) initBoardWithBoardName:(NSString *)theName spriteName:(NSString *)fileName position:(CGPoint) pos leftFreq:(float)freq_l middleFreq:(float)freq_m rightFreq:(float)freq_r leftDamp:(float)damp_l middleDamp:(float)damp_m rightDamp:(float)damp_r;
-(void) missleEffectWithDirection:(int)direction; //0:left, 1:right
-(void) recover;
-(void) rocketPowerup:(float)duration;
-(void) updateBoardForce;
-(void) updateEnginePosition;
-(void) cleanEngine;
-(void) boosterEffect;
-(void) boosterEnd;
-(void) hideBoard;
@end

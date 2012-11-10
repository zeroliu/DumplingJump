//
//  Hero.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "DUContactListener.h"

@interface Hero : DUPhysicsObject
{
    DUContactListener *listener;
    b2FixtureDef shellFixtureDef;
    b2Fixture *shellFixture;
}

@property (nonatomic, retain) NSString *heroState;
@property (nonatomic, retain) NSString *powerup;
@property (nonatomic, assign) float powerupCountdown;
-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius mass:(float)theMass I:(float)theI fric:(float)theFric maxVx:(float)theMaxVx maxVy:(float)theMaxVy accValue:(float)theAccValue jumpValue:(float)theJumpValue gravityValue:(float)theGravity;
-(void) updateHeroPositionWithAccX:(float)accX;
-(void) updateHeroPowerupCountDown:(ccTime)dt;
-(void) jump;
-(void) idle;
//Called from AddthingObject
-(void) flat;
-(void) dizzy;
-(void) hurt:(NSArray *)value;
-(void) freeze;
-(void) bowEffect:(NSArray *)value;
-(void) spring;
-(void) shelter;
-(void) magic:(NSArray *)value;
-(void) blind;
-(void) updateHeroForce;
//-(void) heroLandOnBoard:(NSNotification *)notification;
@end

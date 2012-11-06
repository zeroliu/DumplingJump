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
}

@property (nonatomic, retain) NSString *heroState;


-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius mass:(float)theMass I:(float)theI fric:(float)theFric maxVx:(float)theMaxVx maxVy:(float)theMaxVy accValue:(float)theAccValue jumpValue:(float)theJumpValue;
-(void) updateHeroPositionWithAccX:(float)accX;
-(void) jump;
-(void) idle;
//Called from AddthingObject
-(void) flat;
-(void) dizzy;
-(void) hurt:(NSArray *)value;
-(void) freeze;
-(void) bowEffect:(NSArray *)value;
-(void) updateHeroForce;
//-(void) heroLandOnBoard:(NSNotification *)notification;
@end

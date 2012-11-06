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
@property (nonatomic, assign) float radius;

-(id) initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius;
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

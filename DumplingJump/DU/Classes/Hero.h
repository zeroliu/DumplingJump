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

-(id) initHeroWithName:(NSString *)theName position:(CGPoint)thePosition;
-(void) updateHeroPositionWithAccX:(float)accX;
-(void) jump;
-(void) idle;
//Called from AddthingObject
-(void) flat;
-(void) dizzy;
-(void) hurt:(NSArray *)value;
-(void) freeze;

-(void) updateHeroForce;
//-(void) heroLandOnBoard:(NSNotification *)notification;
@end

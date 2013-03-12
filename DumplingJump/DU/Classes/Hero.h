//
//  Hero.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "CircleMask.h"
@interface Hero : DUPhysicsObject
{
    //b2FixtureDef shellFixtureDef;
    //b2Fixture *shellFixture;
    CircleMask *maskNode;
}

@property (nonatomic, retain) NSString *heroState;
@property (nonatomic, retain) NSMutableDictionary *overlayHeroStateDictionary;
@property (nonatomic, assign) BOOL canReborn;
@property (nonatomic, assign) BOOL isSpringBoost;

-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius mass:(float)theMass I:(float)theI fric:(float)theFric maxVx:(float)theMaxVx maxVy:(float)theMaxVy accValue:(float)theAccValue jumpValue:(float)theJumpValue gravityValue:(float)theGravity;
-(void) updateHeroPositionWithAccX:(float)accX;
-(void) updateHeroChildrenPosition;
-(void) jump;
-(void) idle;
-(void) headStart;
//Called from AddthingObject
-(void) flat:(NSArray *)value;
-(void) hurt:(NSArray *)value;
-(void) freeze:(NSArray *)value;
-(void) bowEffect:(NSArray *)value;
-(void) spring:(NSArray *)value;
-(void) booster:(NSArray *)value;
-(void) magic:(NSArray *)value;
-(void) blind:(NSArray *)value;
-(void) star:(NSArray *)value;
-(void) megastar:(NSArray *)value;
-(void) reborn;
-(void) updateHeroForce;
-(void) bombPowerup;
-(void) rebornPowerup;
-(void) rocketPowerup:(float)duration;
-(void) absorbPowerup;
-(void) shieldPowerup;
-(void) updateHeroBoosterEffect;
-(void) updateJumpState;
-(void) beforeDie;
-(BOOL) isShelterOn;
//-(void) heroLandOnBoard:(NSNotification *)notification;
@end

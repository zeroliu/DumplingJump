//
//  AddthingObjectData.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AddthingObjectData.h"
@implementation AddthingObjectData
@synthesize 
name = _name,
shape = _shape,
spriteName = _spriteName,
radius = _radius,
width = _width,
length = _length,
i = _i,
mass = _mass,
restitution = _restitution,
friction = _friction,
gravity = _gravity,
blood = _blood,
wait = _wait,
warningTime = _warningTime,
reactionName = _reactionName,
animationName = _animationName,
customData = _customData,
firstTouchSFX = _firstTouchSFX;

-(id) initWithName:(NSString *)theName 
             shape:(NSString *)theShape 
        spriteName:(NSString *)theSpriteName
            radius:(double)theRadius
             width:(double)theWidth
            length:(double)theLength
                 I:(double)theI
              mass:(double)theMass
       restitution:(double)theRes
          friction:(double)theFric
           gravity:(double)theGravity
             blood:(double)theBlood
              wait:(double)theWait
       warningTime:(double)theWarningTime
      reactionName:(NSString *)theReactionName
     animationName:(NSString *)theAnimationName
        customData:(NSString *)theCustomData
{
    if (self = [super init])
    {
        _name = theName;
        _shape = theShape;
        _spriteName = theSpriteName;
        _radius = theRadius;
        _width = theWidth;
        _length = theLength;
        _i = theI;
        _mass = theMass;
        _restitution = theRes;
        _friction = theFric;
        _gravity = theGravity;
        _blood = theBlood;
        _wait = theWait;
        _warningTime = theWarningTime;
        _reactionName = theReactionName;
        _animationName = theAnimationName;
        _customData = theCustomData;
    }
    
    return self;
}

-(id) initEmptyData
{
    if (self = [super init])
    {
        _name = nil;
        _shape = nil;
        _spriteName = nil;
        _radius = 0;
        _width = 0;
        _length = 0;
        _i = 0;
        _mass = 0;
        _restitution = 0;
        _friction = 0;
        _gravity = 100;
        _blood = 1;
        _wait = 0;
        _warningTime = 0;
        _reactionName = nil;
        _animationName = nil;
        _customData = nil;
        _firstTouchSFX = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_spriteName release];
    [_reactionName release];
    [_animationName release];
    [_customData release];
    [_firstTouchSFX release];
    [super dealloc];
}
@end

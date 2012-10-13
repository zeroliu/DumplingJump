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
reactionName = _reactionName,
animationName = _animationName;

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
      reactionName:(NSString *)theReactionName
     animationName:(NSString *)theAnimationName;
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
        _reactionName = theReactionName;
        _animationName = theAnimationName;
    }
    
    return self;
}

@end

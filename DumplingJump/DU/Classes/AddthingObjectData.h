//
//  AddthingObjectData.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface AddthingObjectData : CCNode

@property (nonatomic, retain)
NSString *name,*shape,*spriteName, *reactionName, *animationName;
@property (nonatomic, assign)
double radius, //Used for circle
width, //Used for Box
length, //Used for Box
i, //Inertia
mass,
restitution,
friction,
gravity,
blood;


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

-(id) initEmptyData;
@end

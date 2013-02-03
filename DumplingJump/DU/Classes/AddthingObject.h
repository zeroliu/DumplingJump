//
//  AddthingObject.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "Reaction.h"
#import "DUPhysicsObject.h"

@interface AddthingObject : DUPhysicsObject

@property (nonatomic, retain) Reaction *reaction;
@property (nonatomic, retain) NSString *animation;
@property (nonatomic, assign) double wait;
-(id) initWithID:(NSString *)theID name:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL)resize reaction:(NSString *)reactionName animation:(NSString *)animationName wait:(double)waitTime;
-(void) removeAddthing;


@end

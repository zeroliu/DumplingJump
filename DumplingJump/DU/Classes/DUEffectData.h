//
//  DUEffectData.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface DUEffectData : CCNode
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *animationName;
@property (nonatomic, retain) NSString *idlePictureName;
@property (nonatomic, assign) int times; //How many times the animation should play before it is destroied

-(id) initWithName:(NSString *)theName animation:(NSString *)animationName idlePictureName:(NSString *)idleName times:(int)theTimes;
-(id) initEmptyEffect;
@end

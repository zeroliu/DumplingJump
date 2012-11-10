//
//  DUEffectData.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUEffectData.h"
#import "AnimationManager.h"
@implementation DUEffectData
@synthesize name=_name, animationName=_animationName, times=_times, idlePictureName=_idlePictureName;

-(id) initWithName:(NSString *)theName animation:(NSString *)animationName idlePictureName:(NSString *)idleName times:(int)theTimes
{
    if (self = [super init])
    {
        _name = theName;
        _animationName = animationName;
        _idlePictureName = idleName;
        _times = theTimes;
    }
    
    return self;
}

-(id) initEmptyEffect
{
    if (self = [super init])
    {
        _name = nil;
        _animationName = nil;
        _idlePictureName = nil;
        _times = 1;
    }
    
    return self;
}

@end

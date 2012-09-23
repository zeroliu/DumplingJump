//
//  DUEffectData.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUEffectData.h"

@implementation DUEffectData
@synthesize name=_name, animationName=_animationName, times=_times, idlePictureName=_idlePictureName;

-(id) initWithName:(NSString *)theName animation:(NSString *)animationName idlePicture:(NSString *)idlePictureName times:(int)theTimes
{
    if (self = [super init])
    {
        _name = theName;
        _idlePictureName = idlePictureName;
        _animationName = animationName;
        _times = theTimes;
    }
    
    return self;
}

@end

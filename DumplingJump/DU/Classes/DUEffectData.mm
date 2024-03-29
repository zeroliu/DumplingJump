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
@synthesize name=_name, animationName=_animationName, times=_times, idlePictureName=_idlePictureName, scale = _scale, sound = _sound;

-(id) initWithName:(NSString *)theName animation:(NSString *)animationName idlePictureName:(NSString *)idleName times:(int)theTimes scale:(float)theScale sound:(NSString *)theSound
{
    if (self = [super init])
    {
        self.name = theName;
        self.animationName = animationName;
        self.idlePictureName = idleName;
        self.times = theTimes;
        self.scale = theScale;
        self.sound = theSound;
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
        _scale = 1;
        self.sound = @"NULL";
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_animationName release];
    [_idlePictureName release];
    [_sound release];
    [super dealloc];
}
@end

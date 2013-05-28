//
//  AudioManager.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "AudioManager.h"
#import "UserData.h"
#import "Constants.h"
@implementation AudioManager

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AudioManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

-(void) preloadBackgroundMusic:(NSString *)musicName
{
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:musicName];
}

-(void) preloadSFX:(NSString *)SFXName
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:SFXName];
}

-(void) playBackgroundMusic:(NSString *)musicName loop:(BOOL)isLoop
{
    if ([[USERDATA objectForKey:@"music"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicName loop:isLoop];
    }
}

-(void) stopBackgroundMusic
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(void) playSFX:(NSString *)SFXName
{
    if ([[USERDATA objectForKey:@"sfx"] boolValue])
    {
        [[SimpleAudioEngine sharedEngine] playEffect:SFXName];
    }
}

-(ALuint) playSFXwithLoop:(NSString *)SFXName
{
    if ([[USERDATA objectForKey:@"sfx"] boolValue])
    {
        return [[SimpleAudioEngine sharedEngine] playEffectWithLoop:SFXName];
    }
    
    return 0;
}

-(void) stopSFX:(ALuint)SFXTag
{
    [[SimpleAudioEngine sharedEngine] stopEffect:SFXTag];
}

-(void) fadeInBackgroundMusic
{
    
}

-(void) fadeOutBackgroundMusic
{
    [self stopBackgroundMusic];
}

-(void) setBackgroundMusicVolume:(float)volume
{
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:volume];
}

@end

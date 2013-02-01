//
//  AudioManager.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "AudioManager.h"
#import "SimpleAudioEngine.h"
#import "UserData.h"
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
    if (!((UserData *)[UserData shared]).isMusicMuted)
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
    if (!((UserData *)[UserData shared]).isSFXMuted)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:SFXName];
    }
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

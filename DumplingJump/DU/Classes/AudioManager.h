//
//  AudioManager.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "SimpleAudioEngine.h"
@interface AudioManager : CCNode

+(id) shared;

-(void) preloadBackgroundMusic:(NSString *)musicName;
-(void) preloadSFX:(NSString *)SFXName;

-(void) playBackgroundMusic:(NSString *)musicName loop:(BOOL)isLoop;
-(void) stopBackgroundMusic;
-(void) playSFX:(NSString *)SFXName;
-(ALuint) playSFXwithLoop:(NSString *)SFXName;
-(void) stopSFX:(ALuint)SFXTag;

-(void) fadeInBackgroundMusic;
-(void) fadeOutBackgroundMusic;

-(void) setBackgroundMusicVolume:(float)volume;
@end

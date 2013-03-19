//
//  DUGameModel.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "cocos2d.h"
#import "Level.h"

@interface GameModel : CCNode

//@property (assign, nonatomic) float scrollSpeed;
@property (nonatomic, retain) Level *currentLevel;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) float multiplier;
@property (nonatomic, assign) float star;
@property (nonatomic, readonly) float gameSpeed;
@property (nonatomic, readonly) float gameSpeedIncreaseUnit;
@property (nonatomic, readonly) float gameSpeedMax;
@property (nonatomic, readonly) float objectInitialSpeed;

//Achievement related
@property (nonatomic, assign) int jumpCount;
@property (nonatomic, assign) int useBoosterCount;
@property (nonatomic, assign) int useSpringCount;
@property (nonatomic, assign) int useMagicCount;
@property (nonatomic, assign) int useRebornCount;
@property (nonatomic, assign) int useShieldCount;
@property (nonatomic, assign) int useMagnetCount;
@property (nonatomic, assign) int useHeadstartCount;
@property (nonatomic, assign) int eatMegaStarCount;


@property (nonatomic, retain) NSMutableDictionary *powerUpData;

-(void) loadPowerUpLevelsData;
-(void) updateGameSpeed;
-(void) resetGameSpeed;
-(void) boostGameSpeed:(float)interval;
-(void) resetGameData;
@end

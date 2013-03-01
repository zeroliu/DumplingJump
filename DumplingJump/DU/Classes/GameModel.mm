//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#import "WorldData.h"
#import "GameModel.h"
#import "cocos2d.h"
#import "Constants.h"
#import "Hub.h"

@interface GameModel()
{
    float currentGameSpeed;
}
@end

@implementation GameModel
@synthesize currentLevel = _currentLevel;
@synthesize state = _state;
@synthesize distance = _distance;

@synthesize powerUpData = _powerUpData, gameSpeed = _gameSpeed, gameSpeedIncreaseUnit = _gameSpeedIncreaseUnit, gameSpeedMax = _gameSpeedMax, objectInitialSpeed = _objectInitialSpeed, multiplier = _multiplier;

-(id) init
{
    if (self = [super init])
    {
        _gameSpeed = 1;
        _gameSpeedIncreaseUnit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"gameSpeedIncreaseUnit"] floatValue];
        _gameSpeedMax = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"gameSpeedMax"] floatValue];
        _objectInitialSpeed = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"objectInitialSpeed"] floatValue];
    }
    
    return self;
}

-(void) loadPowerUpLevelsData
{
    if (_powerUpData == nil)
    {
        _powerUpData = [[NSMutableDictionary alloc] init];
    }
    
    //TODO: load power up from plist file
    self.multiplier = 5.8f;
    [_powerUpData setObject:[NSNumber numberWithFloat:5] forKey:@"shield"];
    [_powerUpData setObject:[NSNumber numberWithFloat:2] forKey:@"reborn"];
    [_powerUpData setObject:[NSNumber numberWithFloat:5] forKey:@"booster"];
    [_powerUpData setObject:[NSNumber numberWithFloat:10] forKey:@"absorb"];
    [_powerUpData setObject:[NSNumber numberWithFloat:2] forKey:@"headstart"];
    [_powerUpData setObject:[NSNumber numberWithInt:20] forKey:@"megastar"];
}

-(void) updateGameSpeed
{
    if (_gameSpeed < _gameSpeedMax)
    {
        _gameSpeed = MIN(_gameSpeed +_gameSpeedIncreaseUnit, _gameSpeedMax);
    }
}

-(void) boostGameSpeed:(float)interval
{
    if (currentGameSpeed == 0)
    {
        currentGameSpeed = _gameSpeed;
        _gameSpeed = max(_gameSpeed * 2, _gameSpeedMax);
        id delay = [CCDelayTime actionWithDuration:interval];
        id resetBack = [CCCallBlock actionWithBlock:^
        {
            _gameSpeed = currentGameSpeed;
            currentGameSpeed = 0;
        }];
        [GAMELAYER runAction:[CCSequence actions:delay, resetBack, nil]];
    }
}

-(void) resetGameSpeed
{
    _gameSpeed = 1;
}

- (void)dealloc
{
    [_powerUpData release];
    [super dealloc];
}
@end

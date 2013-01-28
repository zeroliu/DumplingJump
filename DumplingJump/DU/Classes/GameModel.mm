//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "GameModel.h"

@interface GameModel()

@end

@implementation GameModel
@synthesize currentLevel = _currentLevel;
@synthesize state = _state;
@synthesize distance = _distance;

@synthesize powerUpData = _powerUpData, gameSpeed = _gameSpeed, gameSpeedIncreaseUnit = _gameSpeedIncreaseUnit, gameSpeedMax = _gameSpeedMax, objectInitialSpeed = _objectInitialSpeed;

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
    [_powerUpData setObject:[NSNumber numberWithFloat:1] forKey:@"bomb"];
    [_powerUpData setObject:[NSNumber numberWithFloat:3] forKey:@"reborn"];
    [_powerUpData setObject:[NSNumber numberWithFloat:5] forKey:@"rocket"];
    [_powerUpData setObject:[NSNumber numberWithFloat:20] forKey:@"absorb"];
}

-(void) updateGameSpeed
{
    if (_gameSpeed < _gameSpeedMax)
    {
        _gameSpeed = MIN(_gameSpeed * (1+_gameSpeedIncreaseUnit), _gameSpeedMax);
        //DLog(@"game speed: %f", _gameSpeed);
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

//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#import "WorldData.h"
#import "GameModel.h"

#import "Constants.h"
#import "Hub.h"
#import "EquipmentData.h"
#import "UserData.h"

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
    
    NSDictionary *equipmentDictionary = ((EquipmentData *)[EquipmentData shared]).dataDictionary;
    
    for (NSString *key in [equipmentDictionary allKeys])
    {
        NSDictionary *itemData = [equipmentDictionary objectForKey:key];
        
        NSString *itemName = [itemData objectForKey:@"name"];
        
        if ([[itemData objectForKey:@"layout"] isEqualToString:@"EquipmentViewLevelCell"])
        {
            int itemLevel = [[USERDATA objectForKey:itemName] intValue];
            if (itemLevel < 0)
            {
                [_powerUpData setObject:[NSNumber numberWithFloat:-1] forKey: itemName];
            }
            else
            {
                float value = [[itemData objectForKey:[NSString stringWithFormat:@"level%d", itemLevel]] floatValue];
                [_powerUpData setObject:[NSNumber numberWithFloat:value] forKey: itemName];
            }
        }
        else if ([[itemData objectForKey:@"layout"] isEqualToString:@"EquipmentViewAmountCell"])
        {
            [_powerUpData setObject:[NSNumber numberWithFloat:[[USERDATA objectForKey:itemName] intValue]] forKey: itemName];
        }
    }
    
    self.multiplier = 5.8f;
    
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

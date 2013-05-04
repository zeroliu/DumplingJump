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
    BOOL isUsingBoosterData;
    float currentObjectInitialSpeedIncrease;
    float currentScrollSpeedIncrease;
    float currentDroprateIncrease;
}
@end

@implementation GameModel
@synthesize currentLevel = _currentLevel;
@synthesize state = _state;
@synthesize distance = _distance;

@synthesize
powerUpData = _powerUpData,
objectInitialSpeed = _objectInitialSpeed,
multiplier = _multiplier,
isHighScore = _isHighScore,
scrollSpeedIncrease = _scrollSpeedIncrease,
scrollSpeedIncreaseMax = _scrollSpeedIncreaseMax,
scrollSpeedIncreaseUnit = _scrollSpeedIncreaseUnit,
objectInitialIncrease = _objectInitialIncrease,
objectInitialIncreaseUnit = _objectInitialIncreaseUnit,
objectInitialIncreaseMax = _objectInitialIncreaseMax,
dropRateIncrease = _dropRateIncrease,
dropRateIncreaseUnit = _dropRateIncreaseUnit,
dropRateIncreaseMax = _dropRateIncreaseMax;

@synthesize
jumpCount           = _jumpCount,
useBoosterCount     = _useBoosterCount,
useSpringCount      = _useSpringCount,
useMagicCount       = _useMagicCount,
useRebornCount      = _useRebornCount,
useShieldCount      = _useShieldCount,
useMagnetCount      = _useMagnetCount,
useHeadstartCount   = _useHeadstartCount,
eatMegaStarCount    = _eatMegaStarCount,
powerCollectCount   = _powerCollectCount,
gameTime            = _gameTime;

-(id) init
{
    if (self = [super init])
    {
        isUsingBoosterData = NO;
        
        //Reset increases
        _dropRateIncrease = 1;
        _objectInitialIncrease = 1;
        _scrollSpeedIncrease = 1;
        
        //load increase unit
        _dropRateIncreaseUnit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRateIncreaseUnit"] floatValue];
        _objectInitialIncreaseUnit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"objectInitialSpeedIncreaseUnit"] floatValue];
        _scrollSpeedIncreaseUnit = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"scrollSpeedIncreaseUnit"] floatValue];

        //load increase max
        _dropRateIncreaseMax = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRateIncreaseMax"] floatValue];
        _objectInitialIncreaseMax = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"objectInitialSpeedIncreaseMax"] floatValue];
        _scrollSpeedIncreaseMax = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"scrollSpeedIncreaseMax"] floatValue];
        
        //preload initial data so that we don't need to search into the dictionary everytime
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
    }
    
    self.multiplier = [[USERDATA objectForKey:@"multiplier"] intValue];
    
}

-(void) updateGameSpeed
{
    if (_scrollSpeedIncrease < _scrollSpeedIncreaseMax)
    {
        _scrollSpeedIncrease = MIN(_scrollSpeedIncrease +_scrollSpeedIncreaseUnit, _scrollSpeedIncreaseMax);
    }
    
    if (_objectInitialIncrease < _objectInitialIncreaseMax)
    {
        _objectInitialIncrease = MIN(_objectInitialIncrease + _objectInitialIncreaseUnit, _objectInitialIncreaseMax);
    }
    
    if (_dropRateIncrease < _dropRateIncreaseMax)
    {
        _dropRateIncrease = MIN(_dropRateIncrease +_dropRateIncreaseUnit, _dropRateIncreaseMax);
    }
}

-(void) decreaseGameSpeed
{
    if (_scrollSpeedIncrease > 1)
    {
        _scrollSpeedIncrease = MAX(_scrollSpeedIncrease -_scrollSpeedIncreaseUnit, 1);
    }
    
    if (_objectInitialIncrease > 1)
    {
        _objectInitialIncrease = MAX(_objectInitialIncrease - _objectInitialIncreaseUnit, 1);
    }
    
    if (_dropRateIncrease > 1)
    {
        _dropRateIncrease = MAX(_dropRateIncrease -_dropRateIncreaseUnit, 1);
    }
}

-(void) boostGameSpeed:(float)interval
{
    if (!isUsingBoosterData)
    {
        isUsingBoosterData = YES;
        currentDroprateIncrease = _dropRateIncrease;
        currentObjectInitialSpeedIncrease = _objectInitialIncrease;
        currentScrollSpeedIncrease = _scrollSpeedIncrease;

        _dropRateIncrease = _dropRateIncreaseMax * 2;
        _objectInitialIncrease = _objectInitialIncreaseMax * 2;
        _scrollSpeedIncrease = _scrollSpeedIncreaseMax * 2;
        
        id delay = [CCDelayTime actionWithDuration:interval];
        id resetBack = [CCCallBlock actionWithBlock:^
        {
            _dropRateIncrease = currentDroprateIncrease;
            _objectInitialIncrease = currentObjectInitialSpeedIncrease;
            _scrollSpeedIncrease = currentScrollSpeedIncrease;
            isUsingBoosterData = NO;
        }];
        [GAMELAYER runAction:[CCSequence actions:delay, resetBack, nil]];
    }
}

-(void) resetGameSpeed
{
    isUsingBoosterData = NO;
    _dropRateIncrease = 1;
    _objectInitialIncrease = 1;
    _scrollSpeedIncrease = 1;
}

-(void) resetGameData
{
    _star = 0;
    _distance = 0;
    _jumpCount = 0;
    _useMagnetCount = 0;
    _useMagicCount = 0;
    _useBoosterCount = 0;
    _useSpringCount = 0;
    _useRebornCount = 0;
    _useShieldCount = 0;
    _useHeadstartCount = 0;
    _eatMegaStarCount = 0;
    _powerCollectCount = 0;
    _gameTime = 0;
    _isHighScore = NO;
}

- (void) addStarWithNum:(int)num
{
    GAMEMODEL.star += num;
    [MESSAGECENTER postNotificationName:NOTIFICATION_STAR object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.star] forKey:@"num"]];
    
    //Add number to star bank
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentStar + num] forKey:@"star"];
    
    int currentTotalStar = [[USERDATA objectForKey:@"totalStar"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentTotalStar+num] forKey:@"totalStar"];
    [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_STAR object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[[USERDATA objectForKey:@"totalStar"] intValue]] forKey:@"num"]];
}

- (void)dealloc
{
    [_powerUpData release];
    [super dealloc];
}
@end

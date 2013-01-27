//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel
@synthesize currentLevel = _currentLevel;
@synthesize state = _state;
@synthesize distance = _distance;

@synthesize powerUpData = _powerUpData;

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

- (void)dealloc
{
    [_powerUpData release];
    [super dealloc];
}
@end

//
//  LevelData.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "LevelData.h"


@interface LevelData()
@property (nonatomic, retain) NSMutableDictionary *levelDictionary;

@end

@implementation LevelData
@synthesize levelDictionary = _levelDictionary;

-(id) levelDictionary
{
    if (_levelDictionary == nil) _levelDictionary = [[NSMutableDictionary alloc] init];
    return _levelDictionary;
}

-(id) init
{
    if (self = [super init])
    {
        Level *aLevel = [[Level alloc] initWithName:LEVEL_NORMAL];
        aLevel.backgroundName = MAZE;
        aLevel.boardType = MAZE_BOARD;
        [self.levelDictionary setObject:aLevel forKey:LEVEL_NORMAL];
    }
    
    return self;
}

-(Level *) getLevelByName:(NSString *)levelName
{
    return [self.levelDictionary objectForKey:levelName];
}

@end

//
//  LevelData.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "Level.h"

@interface LevelData : CCNode
-(Level *) getLevelByName:(NSString *)levelName;

@end

//
//  LevelManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "LevelData.h"

@interface LevelManager : CCNode

-(Level *) selectLevelWithName:(NSString *)levelName;

@end
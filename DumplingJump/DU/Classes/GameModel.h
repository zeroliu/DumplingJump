//
//  DUGameModel.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "Level.h"

@interface GameModel : CCNode

//@property (assign, nonatomic) float scrollSpeed;
@property (nonatomic, retain) Level *currentLevel;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) float distance;
@end

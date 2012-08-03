//
//  GameManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "Common.h"
@class DUGameModel;
@class DUGameManager;

@interface DUGameManager : CCNode

+(id) shared;
-(void) update:(ccTime)dt;
-(void) reset;
@end

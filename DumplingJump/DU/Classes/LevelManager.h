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

+(id) shared;
-(Level *) selectLevelWithName:(NSString *)levelName;
-(void) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position;
-(void) dropAddthingWithName:(NSString *)objectName atSlot:(int) num;

-(void) dropNextAddthing;
-(void) loadParagraphAtIndex:(int) index;
-(int) paragraphsCount;
@end

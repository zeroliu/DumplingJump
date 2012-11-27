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
@property (nonatomic, retain) NSMutableArray *generatedObjects;

+(id) shared;
-(Level *) selectLevelWithName:(NSString *)levelName;
-(id) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position;
-(id) dropAddthingWithName:(NSString *)objectName atSlot:(int) num;

-(void) dropNextAddthing;
-(void) loadParagraphAtIndex:(int) index;
-(int) paragraphsCount;
-(void) removeObjectFromList:(DUObject *)myObject;
-(void) destroyAllObjects;
-(void) stopCurrentParagraph;
@end

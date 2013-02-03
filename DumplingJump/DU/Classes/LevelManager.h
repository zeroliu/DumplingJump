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

//Save all the addthingObject in this array
@property (nonatomic, retain) NSMutableArray *generatedObjects;

+(id) shared;
-(Level *) selectLevelWithName:(NSString *)levelName;

-(id) dropAddthingWithName:(NSString *)objectName atPosition:(CGPoint)position;
-(id) dropAddthingWithName:(NSString *)objectName atSlot:(int) num;

-(void) restart;
-(void) jumpToNextLevel;
-(void) dropNextAddthing;
-(void) stopCurrentParagraph;
-(void) resetParagraph;
-(void) loadCurrentParagraph;
-(void) loadParagraphWithName:(NSString *)name; //Used in Debug tool
-(int) paragraphsCount; //Used in Debug tool
-(void) removeObjectFromList:(DUObject *)myObject;
-(void) destroyAllObjects;
-(void) switchToNextLevelEffect;
-(NSString *) getParagraphNameByIndex:(int)index;
@end

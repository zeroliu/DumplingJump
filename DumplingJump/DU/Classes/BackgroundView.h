//
//  BackgroundView.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface BackgroundView : CCNode

@property (nonatomic, retain) CCSpriteBatchNode *bgBatchNode;

-(void) setBgBatchNodeWithName:(NSString *)bgName;
-(void) setBackgroundWithBGArray:(NSMutableArray *)theArray;
-(void) updateBackgroundWithBGArray:(NSMutableArray *)theArray;
@end

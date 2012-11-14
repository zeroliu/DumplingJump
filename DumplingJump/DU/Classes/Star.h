//
//  Star.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface Star : CCNode

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int width;
@property (nonatomic, retain) NSArray *starLines;

-(id) initEmptyStar;

@end

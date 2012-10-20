//
//  Sentence.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-19.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface Sentence : CCNode
@property (nonatomic, assign) float distance;
@property (nonatomic, retain) NSArray *words;

-(id) initWithDistance: (float)theDistance Words: (NSArray *)theWords;

@end

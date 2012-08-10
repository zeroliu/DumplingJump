//
//  Level.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface Level : CCNode
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *backgroundName;
@property (nonatomic, retain) NSString *boardType;

-(id) initWithName: (NSString *)levelName;
@end


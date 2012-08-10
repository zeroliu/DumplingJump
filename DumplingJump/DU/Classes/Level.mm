//
//  Level.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Level.h"

@implementation Level
@synthesize name = _name, backgroundName = _backgroundName;
@synthesize boardType = _boardType;

-(id) initWithName: (NSString *)levelName
{
    if (self = [self init])
    {
        self.name = levelName;
    }
    
    return self;
}

@end

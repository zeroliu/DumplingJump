//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel
@synthesize currentLevel = _currentLevel;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[GameModel alloc] init];
    }
    
    return shared;
}

@end

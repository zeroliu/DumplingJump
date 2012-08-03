//
//  DUGameModel.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUGameModel.h"

@implementation DUGameModel
@synthesize scrollSpeed;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DUGameModel alloc] init];
    }
    
    return shared;
}

@end

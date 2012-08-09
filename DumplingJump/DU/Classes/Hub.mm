//
//  Hub.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-7-17.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Hub.h"

@implementation Hub
@synthesize gameLayer = _gameLayer;

+(id)shared
{
    static id shared = Nil;
    if(shared == Nil)
    {
        shared = [[Hub alloc] init];
    }
    return shared;
}
@end

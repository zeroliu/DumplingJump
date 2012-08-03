//
//  GameManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUGameManager.h"
#import "DUGameModel.h"
#import "GameLayer.h"

@implementation DUGameManager

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DUGameManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self reset];
    }
    
    return self;
}

-(void) reset
{
    ((DUGameModel *)DUGAMEMODEL).scrollSpeed = 0.1;
}

-(void) update:(ccTime)dt
{
    DLog(@"%d",[SCOREMANAGER increaseDistance]);
}
@end

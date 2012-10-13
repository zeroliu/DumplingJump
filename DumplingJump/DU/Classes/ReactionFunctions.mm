//
//  ReactionFunctions.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ReactionFunctions.h"
#import "GameLayer.h"
#import "HeroManager.h"

@implementation ReactionFunctions

+(id) shared
{
    static id shared = nil;
    if(shared == nil)
    {
        shared = [[ReactionFunctions alloc] init];
    }
    
    return shared;
}

-(void) testFunction
{
    DLog(@"test test");
}

-(void) explode
{
    DLog(@"explode");
}
@end

//
//  DUUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "CCBReader.h"
@implementation DUUI


-(void) createUI
{
    node = [CCBReader nodeGraphFromFile:ccbFileName owner:self];
    node.position = ccp(0,0);
    [GAMELAYER addChild:node z:priority];
    animationManager = node.userObject;
    DLog(@"class name: %@", [self class]);
}

-(void) destroy
{
    [node removeFromParentAndCleanup:NO];
    //[node release];
    //node = nil;
}
@end

//
//  MainMenu.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "MainMenu.h"
#import "GameLayer.h"
#import "CCBReader.h"
#import "CCScrollPageControlView.h"
@implementation MainMenu

- (void) didLoadFromCCB
{
    [self createScrollPageControlView];
}

-(void) createScrollPageControlView
{
    CCScrollPageControlView *scrollView = [[CCScrollPageControlView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^
                     {
                         CCNode *sampleNode = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                         return sampleNode;
                     } num:3 padding:0];
    NSLog(@"%g,%g", objectHolder.position.x, objectHolder.position.y);
    scrollView.position = ccp(0,0);
    [objectHolder addChild:scrollView];
    CCLabelTTF * text = [CCLabelTTF labelWithString:@"test" fontName:@"Marker Felt" fontSize:24];
    text.position = ccp(0,0);
    [objectHolder addChild:text];
    
}

-(void) gameStart
{
    NSLog(@"game start");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]]];
    //[[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
}


@end

//
//  GameUI.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "GameUI.h"
#import "PauseUI.h"
#import "CCBReader.h"

@implementation GameUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[GameUI alloc] init];
    }
    return shared;
}
-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"GameUI.ccbi";
        priority = Z_GAMEUI;
    }
    
    return self;
}

-(void) pauseGame:(id)sender
{
    [GAMELAYER pauseGame];
    [[PauseUI shared] createUI];
}

-(void) testItem1:(id)sender
{
    DLog(@"item1");
}
-(void) testItem2:(id)sender
{
    DLog(@"item2");
}
-(void) testItem3:(id)sender
{
    DLog(@"item3");
}

-(void) fadeOut
{
    [animationManager runAnimationsForSequenceNamed:@"Fade Out"];
}

-(void) updateDistance:(int)distance
{
    if (UIScoreText != nil)
    {
        [UIScoreText setString:[NSString stringWithFormat:@"%d", distance]];
    }
}

@end

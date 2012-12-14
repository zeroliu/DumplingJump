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
#import "HeroManager.h"
#import "BoardManager.h"
#import "BackgroundController.h"
#import "GameModel.h"
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

//Get called by cocosbuilder
-(void) bombClicked:(id)sender
{
    //bomb, will blow everything away
    [[[HeroManager shared] getHero] bombPowerup];
}

-(void) testItem2:(id)sender
{
    //reborn, count down a certain amount of time. revive when you die
    [[[HeroManager shared] getHero] rebornPowerup];
}

-(void) magnetClicked:(id)sender
{
    [[[HeroManager shared] getHero] absorbPowerup];
    /*
    //Rocket, dash with the board for a certain amount of time
    [[[HeroManager shared] getHero] rocketPowerup];
    [[[BoardManager shared] getBoard] rocketPowerup];
    //Speed up scrolling speed
    [[BackgroundController shared] speedUpWithScale:6 interval:[[POWERUP_DATA objectForKey:@"rocket"] floatValue]];
    
    //Increase distance calculation speed
     */
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

-(void) updateStar:(int)starNum
{
    if (UIStarText != nil)
    {
        [UIStarText setString:[NSString stringWithFormat:@"%d", starNum]];
    }
}

@end

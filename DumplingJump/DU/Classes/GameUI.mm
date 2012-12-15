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
#import "LevelManager.h"
#import "BackgroundController.h"
#import "GameModel.h"
@interface GameUI()
{
    id showMessageAction;
}
@end

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
    //[[LevelManager shared] switchToNextLevelEffect];
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

-(void) resetUI
{
    if (showMessageAction != nil)
    {
        [GAMELAYER stopAction:showMessageAction];
        clearMessage.position = ccp([[CCDirector sharedDirector] winSize].width/2, -100);
        showMessageAction = nil;
    }
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

-(void) showStageClearMessageWithDistance
{
    if (showMessageAction != nil)
    {
        [clearMessage stopAction:showMessageAction];
        showMessageAction = nil;
    }
    
    //Delay the animation for sync with board pushing animation
    id delayBeforeStart = [CCDelayTime actionWithDuration:1];
    
    //Update distance text
    int displayDistance = (int)((GameLayer *)GAMELAYER).model.distance / 10 * 10;
    [distanceNum setString:[NSString stringWithFormat:@"%dm", displayDistance]];
    
    //Move the message up to the bottom of the screen
    id moveUp = [CCMoveTo actionWithDuration:0.5 position:ccp([[CCDirector sharedDirector] winSize].width/2, 140)];
    
    //Wait for certain seconds
    id delay = [CCDelayTime actionWithDuration:3];
    
    //Move the message down
    id moveDown = [CCMoveTo actionWithDuration:0.5 position:ccp([[CCDirector sharedDirector] winSize].width/2, -100)];
    id moveDownEase = [CCEaseBackIn actionWithAction:moveDown];
    
    [clearMessage runAction:[CCSequence actions:delayBeforeStart, moveUp, delay, moveDownEase, nil]];
}

@end

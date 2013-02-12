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
    BOOL _isShowingRebornButton;
}

//Dictionary used to match the button names with button green bars
@property (nonatomic, retain) NSMutableDictionary *buttonsDictionary;
//Dictionary used to save button status
@property (nonatomic, retain) NSMutableDictionary *buttonstatusDictionary;

@end

@implementation GameUI
@synthesize buttonsDictionary = _buttonsDictionary, buttonstatusDictionary = _buttonstatusDictionary;

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
        _isShowingRebornButton = NO;
    }
    
    return self;
}

- (void) createUI
{
    [super createUI];
    [self adjustUIPosition];
    [self initButtonDictionary];
}

- (void) adjustUIPosition
{
    [self adjustUI:UIScoreText offset:BLACK_HEIGHT];
    [self adjustUI:UIStarText offset:BLACK_HEIGHT];
    [self adjustUI:starScoreIcon offset:BLACK_HEIGHT];
    [self adjustUI:bombButtonHolder offset:BLACK_HEIGHT];
    [self adjustUI:magnetButtonHolder offset:BLACK_HEIGHT];
    [self adjustUI:pauseButton offset:BLACK_HEIGHT];
//    DLog(@"%g,%g", pauseButton.position.x, pauseButton.position.y);
    
}

- (void) adjustUI:(CCNode *)element offset:(float)theOffset
{
    float x = element.position.x;
    float y = element.position.y;
    
    [element setPosition:ccp(x, y + theOffset)];
}

-(void) initButtonDictionary
{
    if (_buttonsDictionary != nil)
    {
        [_buttonsDictionary release];
        _buttonsDictionary = nil;
    }
    
    if (_buttonstatusDictionary != nil)
    {
        [_buttonstatusDictionary release];
        _buttonstatusDictionary = nil;
    }
    
    _buttonsDictionary = [[NSMutableDictionary alloc] init];
    _buttonstatusDictionary = [[NSMutableDictionary alloc] init];
    [_buttonsDictionary setValue:bombButtonHolder forKey:@"bomb"];
    [_buttonstatusDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"bomb"];
    [_buttonsDictionary setValue:magnetButtonHolder forKey:@"magnet"];
    [_buttonstatusDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"magnet"];
}

-(void) pauseUI
{
    for (NSString *buttonName in [self.buttonsDictionary allKeys])
    {
        [[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:1] pauseSchedulerAndActions];
    }
}
-(void) resumeUI
{
    for (NSString *buttonName in [self.buttonsDictionary allKeys])
    {
        [[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:1] resumeSchedulerAndActions];
    }
}

-(void) setButtonsEnabled: (BOOL)enabled
{
    for (NSString *buttonName in [self.buttonsDictionary allKeys])
    {
        [((CCControlButton *)[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:0]) setEnabled: enabled];
    }
    pauseButton.isEnabled = enabled;
}

-(void) pauseGame:(id)sender
{
    [[AudioManager shared] setBackgroundMusicVolume:0.2];
    [GAMELAYER pauseGame];
    [[PauseUI shared] createUI];
    [self setButtonsEnabled:NO];
}

//Get called by cocosbuilder
-(void) bombClicked:(id)sender
{
    if ([[self.buttonstatusDictionary objectForKey:@"bomb"] boolValue])
    {
        //bomb, will blow everything away
        [[[HeroManager shared] getHero] bombPowerup];
        [self cooldownButtonBarWithName:@"bomb"];
    }
}

-(void) magnetClicked:(id)sender
{
    if ([[self.buttonstatusDictionary objectForKey:@"magnet"] boolValue])
    {
        [[[HeroManager shared] getHero] absorbPowerup];
        [self cooldownButtonBarWithName:@"magnet"];
    }
}

-(void) rebornClicked:(id)sender
{
    DLog(@"reborn button clicked");
    
    int rebornTime = [[POWERUP_DATA objectForKey:@"reborn"] intValue];
    [POWERUP_DATA setObject:[NSNumber numberWithInt:(rebornTime - 1)] forKey:@"reborn"];
    
    [self hideRebornButton];
    [self setButtonsEnabled:YES];
    [[[Hub shared] gameLayer] resumeGame];
    [[[HeroManager shared] getHero] reborn];
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
    
    [self resetAllButtonBar];
    [self setButtonsEnabled:YES];
}

-(void) updateScore:(int)score
{
    if (UIScoreText != nil)
    {
        [UIScoreText setString:[NSString stringWithFormat:@"%d", (int)score]];
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
        [showMessageAction release];
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
    
    showMessageAction = [[CCSequence actions:delayBeforeStart, moveUp, delay, moveDownEase, nil] retain];
    
    [clearMessage runAction:showMessageAction];
}

-(void) showRebornButton
{
    //Disable all buttons
    [self setButtonsEnabled:NO];
    
    [UIMask stopAllActions];
    [rebornButtonHolder stopAllActions];
    [rebornBar stopAllActions];
    
    //Update reborn quantity number
    
    [rebornQuantity setString:[NSString stringWithFormat:@"%d",[[POWERUP_DATA objectForKey:@"reborn"] intValue]]];
//    
    //Reset button
    rebornBar.scaleX = 1;
    
    //Mask fadein
    //id showMask = [CCFadeTo actionWithDuration:0.2 opacity:255];
    
    //Reborn button fly in from the bottom
    id rebornFlyin = [CCMoveTo actionWithDuration:0.2 position:ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2)];
    
    float rebornCountdown = 3;
    //Start countdown animation
    id countdownAnimation = [CCScaleTo actionWithDuration:rebornCountdown scaleX:0 scaleY:rebornBar.scaleY];
    //Start countdown system
    id countdownSystem = [CCDelayTime actionWithDuration:rebornCountdown];
    
    id noButtonPressedConsequence = [CCCallBlock actionWithBlock:^{
        [self beforeGameover];
    }];
    
    //[UIMask runAction:showMask];
    id sequence = [CCSequence actions:[CCEaseExponentialOut actionWithAction:rebornFlyin], countdownSystem, noButtonPressedConsequence, nil];
    
    [rebornButtonHolder runAction:sequence];
    [rebornBar runAction:countdownAnimation];
}

-(void) hideRebornButton
{
    [UIMask stopAllActions];
    [rebornButtonHolder stopAllActions];
    [rebornBar stopAllActions];
    
    rebornButtonHolder.position = ccp([[CCDirector sharedDirector] winSize].width/2, -100);
}

-(void) beforeGameover
{
    [self hideRebornButton];
    [[[Hub shared] gameLayer] gameOver];
}

//Reset all the button bars to full
-(void) resetAllButtonBar
{
    for (NSString *buttonName in [self.buttonsDictionary allKeys])
    {
        [self resetButtonBarWithName:buttonName];
    }
}

//Reset a certain button bar to full
-(void) resetButtonBarWithName:(NSString *)buttonName
{
    [[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:1] stopAllActions];
    [[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:1] setScale:1];
    [self.buttonstatusDictionary setValue:[NSNumber numberWithBool:YES] forKey:buttonName];
}

//Cool down a button
-(void) cooldownButtonBarWithName:(NSString *)buttonName
{
    CCSprite *myButton = (CCSprite *)[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:1];
    
    //Change button status
    [self.buttonstatusDictionary setValue:[NSNumber numberWithBool:NO] forKey:buttonName];
    //Change scale to 0
    [myButton setScaleY:0];
    //Slowly increase the scale to 1
    //TODO: change time to button specific time
    id cooldownAnimation = [CCScaleTo actionWithDuration:20 scale:1];
    //when finish, play finish animation
    id finishAnimation = [CCCallBlock actionWithBlock:^{
        CCSprite *whiteEffect = (CCSprite *)[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:2];
        [whiteEffect runAction: [CCFadeIn actionWithDuration:0.2]];
    }];
    id finishAnimationWait = [CCDelayTime actionWithDuration:0.2];

    id recoverAnimation = [CCCallBlock actionWithBlock:^{
        CCSprite *whiteEffect = (CCSprite *)[[self.buttonsDictionary objectForKey:buttonName] getChildByTag:2];
        [whiteEffect runAction: [CCFadeOut actionWithDuration:0.2]];
    }];
    id recoverAnimationWait = [CCDelayTime actionWithDuration:0.2];
    
    //reset the button
    id cooldownFinishAction = [CCCallBlock actionWithBlock:^{
        [self resetButtonBarWithName:buttonName];
    }];
    
    [myButton runAction:[CCSequence actions:cooldownAnimation, finishAnimation,finishAnimationWait, recoverAnimation, recoverAnimationWait, cooldownFinishAction, nil]];
}

- (void)dealloc
{
    [_buttonsDictionary release];
    _buttonsDictionary = nil;
    [_buttonstatusDictionary release];
    _buttonstatusDictionary = nil;
    if (showMessageAction!=nil)
    {
        [showMessageAction release];
        showMessageAction = nil;
    }
    [super dealloc];
}

@end

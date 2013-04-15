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
#import "Constants.h"

NSString *const distancePopup = @"DistancePopup";
NSString *const achievementPopup = @"achievementPopup";

@interface GameUI()
{
    id showMessageAction;
    BOOL _isShowingRebornButton;
    BOOL _isShowingDisplayQueue;
    NSMutableArray *displayQueue;
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
        _isShowingDisplayQueue = NO;
        displayQueue = [[NSMutableArray alloc] init];
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
    [self adjustUI:shieldButtonHolder offset:BLACK_HEIGHT];
    [self adjustUI:magnetButtonHolder offset:BLACK_HEIGHT];
    [self adjustUI:pauseButton offset:BLACK_HEIGHT];
    
    int buttonOffset = 0;
    
    if ([[USERDATA objectForKey:@"MAGNET"] intValue] >= 0)
    {
        [magnetButtonHolder setPosition:ccp(288 - 64 * buttonOffset, magnetButtonHolder.position.y)];
        buttonOffset ++;
    }
    else
    {
        [magnetButtonHolder setPosition:ccp([CCDirector sharedDirector].winSize.width + 100, magnetButtonHolder.position.y)];
    }
    
    if ([[USERDATA objectForKey:@"SHELTER"] intValue] >= 0)
    {
        [shieldButtonHolder setPosition:ccp(288 - 64 * buttonOffset, shieldButtonHolder.position.y)];
        buttonOffset ++;
    }
    else
    {
        [shieldButtonHolder setPosition:ccp([CCDirector sharedDirector].winSize.width + 100, shieldButtonHolder.position.y)];
    }
    
}

- (void) adjustUI:(CCNode *)element offset:(float)theOffset
{
    float x = element.position.x;
    float y = element.position.y;
    
    [element setPosition:ccp(x, y + theOffset)];
}

-(void) removeMask
{
    if (mask != nil)
    {
        [mask removeFromParentAndCleanup:NO];
        [mask release];
        mask = nil;
    }
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
    [_buttonsDictionary setValue:shieldButtonHolder forKey:@"SHELTER"];
    [_buttonstatusDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"SHELTER"];
    [_buttonsDictionary setValue:magnetButtonHolder forKey:@"MAGNET"];
    [_buttonstatusDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"MAGNET"];
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
-(void) shieldClicked:(id)sender
{
    if ([[self.buttonstatusDictionary objectForKey:@"SHELTER"] boolValue])
    {
        //bomb, will blow everything away
        [[[HeroManager shared] getHero] shieldPowerup];
        [self cooldownButtonBarWithName:@"SHELTER"];
    }
}

-(void) magnetClicked:(id)sender
{
    if ([[self.buttonstatusDictionary objectForKey:@"MAGNET"] boolValue])
    {
        [[[HeroManager shared] getHero] absorbPowerup];
        [self cooldownButtonBarWithName:@"MAGNET"];
    }
}

-(void) rebornClicked:(id)sender
{
    DLog(@"reborn button clicked");
    
    int rebornTime = [[USERDATA objectForKey:@"reborn"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:(rebornTime - 1)] forKey:@"reborn"];
    
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
    _isShowingDisplayQueue = NO;
    _isShowingRebornButton = NO;
    
    [clearMessage stopAllActions];
    clearMessage.position = ccp([[CCDirector sharedDirector] winSize].width/2, -100);
    [achievementUnlockHolder stopAllActions];
    achievementUnlockHolder.position = ccp([[CCDirector sharedDirector] winSize].width/2, -100);
    showMessageAction = nil;
    
    [displayQueue removeAllObjects];
    
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

-(void) updateStar:(float)starNum
{
    if (UIStarText != nil)
    {
        [UIStarText setString:[NSString stringWithFormat:@"%d", (int)starNum]];
    }
}

-(void) addAchievementUnlockMessageWithName:(NSString *)name
{
    [displayQueue addObject:[NSString stringWithFormat:@"%@;%@", achievementPopup, name]];
    [self dequeue];
}

-(void) addStageClearMessageWithDistance:(int) distance;
{
    [displayQueue addObject:[NSString stringWithFormat:@"%@;%d", distancePopup, distance]];
    [self dequeue];
}

-(void) showAchievementUnlockMessageWithName:(NSString *)name
{
    if (showMessageAction != nil)
    {
        [clearMessage stopAction:showMessageAction];
        [showMessageAction release];
        showMessageAction = nil;
    }

    //Update achievement name label
    [unlockAchievementName setString:name];
    
    //Move the message up to the bottom of the screen
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:ccp([[CCDirector sharedDirector] winSize].width/2, 100)];
    
    //Wait for certain seconds
    id delay = [CCDelayTime actionWithDuration:2.5];
    
    //Move the message down
    id moveDown = [CCMoveTo actionWithDuration:0.2 position:ccp([[CCDirector sharedDirector] winSize].width/2, -100)];
    id moveDownEase = [CCEaseBackIn actionWithAction:moveDown];
    id endFunction = [CCCallBlock actionWithBlock:^{
        _isShowingDisplayQueue = NO;
        [self dequeue];
    }];
    showMessageAction = [[CCSequence actions:moveUp, delay, moveDownEase, endFunction, nil] retain];
    
    [achievementUnlockHolder runAction:showMessageAction];
}

-(void) showStageClearMessageWithDistance:(int) distance
{
    if (showMessageAction != nil)
    {
        [clearMessage stopAction:showMessageAction];
        [showMessageAction release];
        showMessageAction = nil;
    }
    
    //Update distance text
    [distanceNum setString:[NSString stringWithFormat:@"%dm", distance]];
    
    //Move the message up to the bottom of the screen
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:ccp([[CCDirector sharedDirector] winSize].width/2, 100)];
    
    //Wait for certain seconds
    id delay = [CCDelayTime actionWithDuration:1.5];
    
    //Move the message down
    id moveDown = [CCMoveTo actionWithDuration:0.2 position:ccp([[CCDirector sharedDirector] winSize].width/2, -100)];
    id moveDownEase = [CCEaseBackIn actionWithAction:moveDown];
    id endFunction = [CCCallBlock actionWithBlock:^{
        _isShowingDisplayQueue = NO;
        [self dequeue];
    }];
    showMessageAction = [[CCSequence actions:moveUp, delay, moveDownEase, endFunction, nil] retain];
    
    [clearMessage runAction:showMessageAction];
}

-(void) dequeue
{
    if (!_isShowingDisplayQueue && [displayQueue count] > 0)
    {
        _isShowingDisplayQueue = YES;
        NSString *command = [[displayQueue objectAtIndex:0] retain];
        [displayQueue removeObjectAtIndex:0];
        
        if ([command rangeOfString:distancePopup].location != NSNotFound)
        {
            NSArray *instructions = [command componentsSeparatedByString:@";"];
            int distance = [[instructions objectAtIndex:1] intValue];
            [self showStageClearMessageWithDistance:distance];
        }
        else if ([command rangeOfString:achievementPopup].location != NSNotFound)
        {
            NSArray *instructions = [command componentsSeparatedByString:@";"];
            NSString *name = [instructions objectAtIndex:1];
            [self showAchievementUnlockMessageWithName:name];
        }
        [command release];
    }
}

- (void) createMask
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    mask = [[CCSprite spriteWithSpriteFrameName:@"UI_other_mask.png"] retain];
    mask.anchorPoint = ccp(0.5,0.5);
    mask.position = ccp(winSize.width/2, winSize.height/2);
    mask.zOrder = Z_GAME_MASK;
    mask.opacity = 0;
    [mask runAction:[CCFadeTo actionWithDuration:0.1 opacity:90]];
    [GAMELAYER addChild:mask];
}

-(void) showRebornButton
{
    [self createMask];
    
    //Disable all buttons
    [self setButtonsEnabled:NO];
    
    [UIMask stopAllActions];
    [rebornButtonHolder stopAllActions];
    [rebornBar stopAllActions];
    
    //Update reborn quantity number
    
    [rebornQuantity setString:[NSString stringWithFormat:@"%d",[[USERDATA objectForKey:@"reborn"] intValue]]];
    
    //Reset button
    rebornBar.scaleX = 1;
    
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
    [self removeMask];
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
    id cooldownAnimation = [CCScaleTo actionWithDuration:[[POWERUP_DATA objectForKey:buttonName] floatValue] scale:1];
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

-(void) updateDistanceSign:(int)distance
{
    [self addStageClearMessageWithDistance:GAMEMODEL.distance / 10 * 10];
}

-(CGPoint) getStarDestination
{
    return starScoreIcon.position;
}

-(void) scaleStarUI
{
    [starScoreIcon stopAllActions];
    id increaseSize = [CCScaleTo actionWithDuration:0.05 scale:1.4];
    id reduceSize = [CCScaleTo actionWithDuration:0.2 scale:1];
    [starScoreIcon runAction:[CCSequence actions:increaseSize, reduceSize, nil]];
}


- (void)dealloc
{
    [displayQueue release];
    [_buttonsDictionary release];
    _buttonsDictionary = nil;
    [_buttonstatusDictionary release];
    _buttonstatusDictionary = nil;
    if (showMessageAction!=nil)
    {
        [showMessageAction release];
        showMessageAction = nil;
    }
    [mask release];
    mask = nil;
    [super dealloc];
}

@end

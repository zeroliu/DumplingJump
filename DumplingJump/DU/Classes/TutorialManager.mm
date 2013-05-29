//
//  TutorialManager.mm
//  CastleRider
//
//  Created by zero.liu on 5/26/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "TutorialManager.h"
#import "TutorialUI.h"
#import "Common.h"
#import "HeroManager.h"
#import "Hero.h"
#import "LevelManager.h"

@interface TutorialManager()
{
    int _subIndex;
    int _counter;
    CCLabelBMFont *_tutorialLabel;
    NSArray *_awesomeWords;
}

@end

@implementation TutorialManager

+ (id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[TutorialManager alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        //Create text label on GameLayer
        _tutorialLabel = [[CCLabelBMFont labelWithString:@"" fntFile:@"ERAS_white_black.fnt"] retain];
//        _tutorialLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Eras Bold ITC" fontSize:30] retain];
        _tutorialLabel.anchorPoint = ccp(0.5,0.5);
        _tutorialLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height + BLACK_HEIGHT - 50);
        
        //Generate awesome words
        _awesomeWords = [[NSArray alloc] initWithObjects:@"Awesome!",@"Great!",@"Good Job!",@"Nice!",@"Super!",@"Marvelous!",@"Fantastic!",@"Terrific!", nil];
    }
    
    return self;
}
    
- (void) startMoveTutorial
{
    [_tutorialLabel removeFromParentAndCleanup:NO];
    [GAMELAYER addChild:_tutorialLabel z:Z_TUTORIALUI - 1];
    
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Play move tutorial animation
    [[TutorialUI shared] playTutorialAnimation:@"UI_tutorial_sway"];
    
    //Disable jump
    [[HEROMANAGER getHero] jumpEnabled:NO];
    
    //Set description
    [[TutorialUI shared] updateTipWithNumber:1 description:@"Tilt to move"];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show move tutorial text
        [self showText:@"Move LEFT"];
        
        //Start checking movement
        [MESSAGECENTER addObserver:self selector:@selector(checkMove:) name:NOTIFICATION_MOVE object:nil];
    }];
}

- (void) startJumpTutorial
{
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Play jump tutorial animation
    [[TutorialUI shared] playTutorialAnimation:@"UI_tutorial_tap"];
    
    //Enable jump
    [[HEROMANAGER getHero] jumpEnabled:YES];
    
    //Set description
    [[TutorialUI shared] updateTipWithNumber:2 description:@"Tap to jump"];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show jump tutorial text
        [self showText:@"Jump 5 times"];
        
        //Start checking Jump
        [MESSAGECENTER addObserver:self selector:@selector(checkJump:) name:NOTIFICATION_JUMP object:nil];
    }];
}

- (void) startPowerupTutorial
{
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Show powerup tutorial image
    [[TutorialUI shared] changeToImage:@"UI_tutorial_powerups.png"];
    
    //Set description
    [[TutorialUI shared] updateTipWithNumber:3 description:@"Get powerups"];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show powerup tutorial text
        [self showText:@"Get the sword"];
        
        [self dropSword];
        
        //Start checking powerup
        [MESSAGECENTER addObserver:self selector:@selector(checkPowerup:) name:NOTIFICATION_MAGIC object:nil];
    }];
}

- (void) startAddthingTutorial
{
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Show powerup tutorial image
    [[TutorialUI shared] changeToImage:@"UI_tutorial_addthings.png"];
    
    //Set description
    [[TutorialUI shared] updateTipWithNumber:4 description:@"Dodge objects"];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show powerup tutorial text
        [self showText:@"Don't get hurt"];
        
        [self dropAddthings];
        
        //Start checking addthing
        [MESSAGECENTER addObserver:self selector:@selector(hitByAddthing) name:NOTIFICATION_TOUCH_ADDTHING object:nil];
    }];
}

- (void) startBombTutorial
{
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Show powerup tutorial image
    [[TutorialUI shared] playTutorialAnimation:@"UI_tutorial_bomb"];
    
    //Set description
    [[TutorialUI shared] updateTipWithNumber:5 description:@"Push bombs"];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show powerup tutorial text
        [self showText:@"Push the bomb\noff the platform"];
        
        [self dropBomb];
        
        //Start checking addthing
        [MESSAGECENTER addObserver:self selector:@selector(hitByBomb) name:NOTIFICATION_BOMB_EXPLODE object:nil];
    }];
}

#pragma mark - Private
- (void) dropSword
{
    //Drop a sword
    [[LevelManager shared] dropAddthingWithName:@"MAGIC" atSlot:4];
    
    //Wait for 5 seconds
    id delay = [CCDelayTime actionWithDuration:5];
    
    //Redrop again
    id dropFunction = [CCCallFunc actionWithTarget:self selector:@selector(dropSword)];
    
    [GAMELAYER stopActionByTag:TAG_TUTORIAL_DROP_SWORD];
    
    CCSequence *sequences = [CCSequence actions:delay, dropFunction, nil];
    sequences.tag = TAG_TUTORIAL_DROP_SWORD;
    [GAMELAYER runAction:sequences];
}

- (void) dropAddthings
{
    //Drop arrows
    id dropArrow1 = [CCCallBlock actionWithBlock:^{
        [[LevelManager shared] dropAddthingWithName:@"ARROW" atSlot:3 warning:0.7];
    }];
    
    id dropArrow2 = [CCCallBlock actionWithBlock:^{
        [[LevelManager shared] dropAddthingWithName:@"ARROW" atSlot:6 warning:0.7];
    }];
    
    id dropArrow3 = [CCCallBlock actionWithBlock:^{
        [[LevelManager shared] dropAddthingWithName:@"ARROW" atSlot:2 warning:0.7];
    }];
    
    id dropArrow4 = [CCCallBlock actionWithBlock:^{
        [[LevelManager shared] dropAddthingWithName:@"ARROW" atSlot:4 warning:0.7];
    }];
    
    id delay0 = [CCDelayTime actionWithDuration:1];
    id delay1 = [CCDelayTime actionWithDuration:1];
    id delay2 = [CCDelayTime actionWithDuration:1];
    id delay3 = [CCDelayTime actionWithDuration:1];
    id delay4 = [CCDelayTime actionWithDuration:3];
    
    //if succeeded dodging all arrows
    //Move to next step
    id winBlock = [CCCallBlock actionWithBlock:^{
        [self showGoodJob];
        [self hideText];
        [MESSAGECENTER removeObserver:self name:NOTIFICATION_TOUCH_ADDTHING object:nil];
        [self performSelector:@selector(startBombTutorial) withObject:nil afterDelay:2];
    }];
    
    CCSequence *sequences = [CCSequence actions:delay0, dropArrow1, delay1, dropArrow2, delay2, dropArrow3, delay3, dropArrow4, delay4, winBlock, nil];
    sequences.tag = TAG_TUTORIAL_DROP_ARROW;
    [GAMELAYER runAction:sequences];
}

- (void) dropBomb
{
    [[LevelManager shared] dropAddthingWithName:@"POWDER" atSlot:3];
    id delay = [CCDelayTime actionWithDuration:6];
    
    //if still alive after the bomb explodes
    //Move to next step
    id winBlock = [CCCallBlock actionWithBlock:^{
        [self showGoodJob];
        [self hideText];
        [MESSAGECENTER removeObserver:self name:NOTIFICATION_BOMB_EXPLODE object:nil];
        [GAMELAYER performSelector:@selector(gameOver) withObject:nil afterDelay:2];
    }];
    
    CCSequence *sequences = [CCSequence actions:delay, winBlock, nil];
    sequences.tag = TAG_TUTORIAL_DROP_BOMB;
    [GAMELAYER runAction:sequences];
}

- (void) showText:(NSString *)text
{
    [_tutorialLabel stopAllActions];
    [_tutorialLabel setString:text];
    
    //Init param for animation
    _tutorialLabel.opacity = 0;
    _tutorialLabel.scale = 1.5;
    
    id scaleDown = [CCScaleTo actionWithDuration:0.15 scale:1];
    id fadeIn = [CCFadeIn actionWithDuration:0.15];
    
    [_tutorialLabel runAction:scaleDown];
    [_tutorialLabel runAction:fadeIn];
}

- (void) hideText
{
    id scaleUp = [CCScaleTo actionWithDuration:0.15 scale:1.5];
    id fadeOut = [CCFadeOut actionWithDuration:0.15];
    
    [_tutorialLabel runAction:scaleUp];
    [_tutorialLabel runAction:fadeOut];
}

- (void) showGoodJob
{
    NSString *word = [_awesomeWords objectAtIndex:randomInt(0, [_awesomeWords count])];
    CCLabelTTF *goodJobLabel = [CCLabelTTF labelWithString:word fontName:@"Eras Bold ITC" fontSize:22];
    goodJobLabel.anchorPoint = ccp(0.5,0.5);
    goodJobLabel.position = ccpAdd(((Hero *)[HEROMANAGER getHero]).sprite.position, ccp(0, 10));
    goodJobLabel.color = ccYELLOW;
    goodJobLabel.scale = 0.01;
    goodJobLabel.opacity = 0;
    [GAMELAYER addChild:goodJobLabel z:Z_TUTORIALUI - 1];
    
    id moveUp = [CCMoveBy actionWithDuration:0.8 position:ccp(0, 100)];
    id scaleUp = [CCScaleTo actionWithDuration:0.2 scale:1];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id selfDestruction = [CCCallBlock actionWithBlock:^{
        [goodJobLabel removeFromParentAndCleanup:NO];
    }];
    
    [goodJobLabel runAction:[CCSequence actions:moveUp, fadeOut, selfDestruction, nil]];
    [goodJobLabel runAction:scaleUp];
    [goodJobLabel runAction:fadeIn];
    
    //make hero smile
    [[HEROMANAGER getHero] smileWithDuration:1.2];
}


#pragma mark - Notification callback
- (void) checkMove:(NSNotification *)notification
{
    float value = [[notification.userInfo objectForKey:@"num"] floatValue];
    int offset = -1; //Defaut move right
    //decide which direction to check according to subIndex
    if (_subIndex % 2 == 0)
    {
        offset = 1; //move left
    }

    if (value*offset < 0)
    {
        //if direction is correct, and it is big enough! increase counter
        if (ABS(value) > 3)
        {
            _counter ++;
        }
        
        if (_counter > 20)
        {
            //current sub-phase succeed, move to next phase
            _subIndex ++;
            _counter = 0;
            
            [self showGoodJob];
            
            if (_subIndex > 4)
            {
                //current tutorial succeed, move to next step
                [MESSAGECENTER removeObserver:self name:NOTIFICATION_MOVE object:nil];
                [self hideText];
                [self performSelector:@selector(startJumpTutorial) withObject:nil afterDelay:1];
            }
            else
            {
                if (_subIndex % 2 == 0)
                {
                    [self showText:@"Move LEFT"];
                }
                else
                {
                    [self showText:@"Move RIGHT"];
                }
            }
        }
    }
    else
    {
        _counter = 0;
    }
}

- (void) checkJump:(NSNotification *)notification
{
    _counter ++;
    [self showGoodJob];
    if (_counter < 4)
    {
        [self showText:[NSString stringWithFormat:@"Jump %d times", 5-_counter]];
    }
    else if (_counter == 4)
    {
        [self showText:@"One more time!"];
    }
    else if (_counter > 4)
    {
        [self hideText];
        [MESSAGECENTER removeObserver:self name:NOTIFICATION_JUMP object:nil];
        [self performSelector:@selector(startPowerupTutorial) withObject:nil afterDelay:1];
    }
}

- (void) checkPowerup:(NSNotification *)notification
{
    _counter ++;
    [self showGoodJob];
    [GAMELAYER stopActionByTag:TAG_TUTORIAL_DROP_SWORD];
    [self hideText];
    [MESSAGECENTER removeObserver:self name:NOTIFICATION_MAGIC object:nil];
    [self performSelector:@selector(startAddthingTutorial) withObject:nil afterDelay:5];
}

- (void) hitByAddthing
{
    [GAMELAYER stopActionByTag:TAG_TUTORIAL_DROP_ARROW];
    [self performSelector:@selector(dropAddthings) withObject:nil afterDelay:4];
}

- (void) hitByBomb
{
    [GAMELAYER stopActionByTag:TAG_TUTORIAL_DROP_BOMB];
    [self performSelector:@selector(dropBomb) withObject:nil afterDelay:4];
}

- (void) dealloc
{
    [_tutorialLabel release];
    _tutorialLabel = nil;
    [_awesomeWords release];
    _awesomeWords = nil;
    [super dealloc];
}

@end

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

@interface TutorialManager()
{
    int _subIndex;
    int _counter;
    CCLabelTTF *_tutorialLabel;
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
        _tutorialLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Eras Bold ITC" fontSize:30] retain];
        _tutorialLabel.anchorPoint = ccp(0.5,0.5);
        _tutorialLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height + BLACK_HEIGHT - 50);
        [GAMELAYER addChild:_tutorialLabel z:Z_TUTORIALUI - 1];
    }
    
    return self;
}
    
- (void) startMoveTutorial
{
    _subIndex = 0;
    _counter = 0;
    
    //Pause game
    [GAMELAYER pauseGame];
    
    //Play move tutorial animation
    [[TutorialUI shared] playTutorialAnimation:@"UI_tutorial_sway"];
    
    //Disable jump
    [[HEROMANAGER getHero] jumpEnabled:NO];
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show move tutorial text
        [_tutorialLabel setString:@"Move LEFT"];
        
        //Start checking movement
        [MESSAGECENTER addObserver:self selector:@selector(checkMove:) name:NOTIFICATION_MOVE object:nil];
    }];
}

#pragma mark - private
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
    
    //Show instruction
    [[TutorialUI shared] showUIwithCallback:^{
        [GAMELAYER resumeGame];
        
        //Show jump tutorial text
        [_tutorialLabel setString:@"Jump 10 times"];
        
        //Start checking Jump
//        [MESSAGECENTER addObserver:self selector:@selector(checkMove:) name:NOTIFICATION_MOVE object:nil];
    }];
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
            
            if (_subIndex % 2 == 0)
            {
                [_tutorialLabel setString:@"Move LEFT"];
            }
            else
            {
                [_tutorialLabel setString:@"Move RIGHT"];
            }
            
            if (_subIndex > 5)
            {
                //current tutorial succeed, move to next step
                [MESSAGECENTER removeObserver:self name:NOTIFICATION_MOVE object:nil];
                [self startJumpTutorial];
            }
        }
    }
    else
    {
        _counter = 0;
    }
    
}

- (void) dealloc
{
    [_tutorialLabel release];
    _tutorialLabel = nil;
    [super dealloc];
}

@end

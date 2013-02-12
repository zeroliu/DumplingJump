//
//  MainMenu.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//
#import "Constants.h"
#import "MainMenu.h"
#import "GameLayer.h"
#import "CCBReader.h"
#import "DUScrollPageView.h"
#import "DUTableView.h"
#import "EquipmentData.h"
#import "DUButtonFactory.h"
#import <UIKit/UIKit.h>
typedef enum {
    MainMenuStateHome,
    MainMenuStateMission,
    MainMenuStateEquipment
} MainMenuState;

@interface MainMenu()
{
    MainMenuState state;
    DUScrollPageView *achievementScrollView;
    CCSprite *_titleHero;
}
@end

@implementation MainMenu

- (id) init
{
    if (self = [super init])
    {
        winSize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}

- (void) didLoadFromCCB
{
    //Load EquipmentData if first launch
    [EquipmentData shared];
    
    animationManager = self.userObject;
    state = MainMenuStateHome;
    
    //Create title hero
    [self createTitleHero];
    
    //Create main menu buttons
    [self createMainMenuButtons];
    
    //Create achievement view
    [self createAchievementView];
    
    //Create equipment view
    [self createEquipmentView];
    
    //Hide unused buttons
    [self setEquipmentButtonsEnabled:NO];

    //Create mask
    [self createMask];

    //Hide mask
    mask.opacity = 0;
    
    //Disable the achievement scroll view
    achievementScrollView.isTouchEnabled = NO;
    
    //Load main menu background music
    [[AudioManager shared] preloadBackgroundMusic:@"Music_MainMenu.mp3"];
    [[AudioManager shared] playBackgroundMusic:@"Music_MainMenu.mp3" loop:YES];
}

#pragma mark -
#pragma Creation

- (void) createMask
{
    mask = [[CCSprite spriteWithSpriteFrameName:@"UI_other_mask.png"] retain];
    mask.anchorPoint = ccp(0.5,0.5);
    mask.position = ccp(winSize.width/2, winSize.height/2);
    mask.zOrder = Z_MASK;
    
//    mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UI_other_mask.png"]];
//    mask.center = ccp(winSize.width/2, winSize.height/2);
//    mask.layer.zPosition = Z_MASK;
//    [VIEW addSubview:mask];
    [self addChild:mask];
}

- (void) createMainMenuButtons
{
    playButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width/2.0, winSize.height/2.0) image:@"UI_title_play.png"] retain];
    playButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:playButton];
    [playButton addTarget:self action:@selector(showEquipment) forControlEvents:UIControlEventTouchUpInside];
    
    achievementButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width/2.0, playButton.frame.origin.y + playButton.frame.size.height + 50) image:@"UI_title_mission.png"] retain];
    achievementButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:achievementButton];
    [achievementButton addTarget:self action:@selector(showAchievement) forControlEvents:UIControlEventTouchUpInside];
    
    settingButton = [[DUButtonFactory createButtonWithPosition:ccp(45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_title_sytem.png"] retain];
    settingButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:settingButton];
    
    gameCenterButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width - 45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_title_ranking.png"] retain];
    gameCenterButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:gameCenterButton];
}

- (void) createEquipmentView
{
    backButton = [[DUButtonFactory createButtonWithPosition:ccp(45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_other_back.png"] retain];
    backButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    storeButton = [[DUButtonFactory createButtonWithPosition:ccp(backButton.center.x + backButton.frame.size.width+6, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_equip_star.png"] retain];
    storeButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:storeButton];
    
    continueButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width - 50, winSize.height - 46 - BLACK_HEIGHT) image:@"UI_other_play.png"] retain];
    [VIEW addSubview:continueButton];
    continueButton.layer.zPosition = Z_BUTTONS;
    [continueButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
}

- (void) createAchievementView
{
    achievementScrollView = [[DUScrollPageView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^
                     {
                         CCNode *sampleNode = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                         return sampleNode;
                     } num:8 padding:0 bulletNormalSprite:@"UI_mission_pages_off.png" bulletSelectedSprite:@"UI_mission_pages_on.png"];
    
    achievementScrollView.position = ccp(0,BLACK_HEIGHT);
    [achievementHolder addChild:achievementScrollView];
    achievementHolder.zOrder = Z_SECONDARY_UI;
}

- (void) createTitleHero
{
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"sheetObjects.plist"]];
    
    if (_titleHero != nil)
    {
        [_titleHero removeFromParentAndCleanup:NO];
        _titleHero = nil;
    }
    
    _titleHero = [CCSprite spriteWithSpriteFrameName:@"H_hero_1.png"];
    _titleHero.scale = 1.3;
    _titleHero.position = CGPointZero;
    
    //Build hero animation
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=6; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"H_magic_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id heroAnim = [CCAnimation animationWithSpriteFrames :frameArray delay:0.12];
    
    if (heroAnim != nil)
    {
        id heroAnimate = [CCAnimate actionWithAnimation:heroAnim];
        [_titleHero stopAllActions];
        [_titleHero runAction:[CCRepeatForever actionWithAction:heroAnimate]];
    }
    
    [titleHeroHolder addChild:_titleHero z:1];
}

#pragma mark -
#pragma Animation

//Show achievement view
- (void) showAchievement
{
    //Change state
    state = MainMenuStateMission;
    
    //Enable touch
    achievementScrollView.isTouchEnabled = YES;
    [UIView animateWithDuration:0.1
            animations:^
             {
                 //Hide all the buttons on main menu
                 [self setMainMenuButtonsEnabled:NO];
             }
                             completion:^(BOOL finished)
             {
                 if (finished)
                 {
                     [self showAchievementAnim];
                 }
             }
    ];
}

- (void) showAchievementAnim
{
    //Scroll down the achievement view
    [animationManager runAnimationsForSequenceNamed:@"Show Achievement"];
    
    //Show back button
    [UIView animateWithDuration:0.1
            animations:^
             {
                 [self setAchievementButtonsEnabled:YES];
             }
    ];
    [self setMaskVisibility:YES];
}

- (void) showEquipment
{
    state = MainMenuStateEquipment;
    [UIView animateWithDuration:0.1
            animations:^
            {
                //Hide all the buttons on main menu
                [self setMainMenuButtonsEnabled:NO];
            }
            completion:^(BOOL finished)
            {
                if (finished)
                {
                    [self showEquipmentAnim];
                }
            }
     ];
    
    
    //[self setMainMenuButtonsEnabled:NO];
    //[self scheduleOnce:@selector(showEquipmentBody) delay:0.1];
}

- (void) showEquipmentAnim
{
    //Show Equipment buttons
    [UIView animateWithDuration:0.1
            animations:^
            {
                [self setEquipmentButtonsEnabled:YES];
            }
     ];
    [self setMaskVisibility:YES];
}

- (void) startGame
{
    [playButton removeFromSuperview];
    [achievementButton removeFromSuperview];
    [settingButton removeFromSuperview];
    [gameCenterButton removeFromSuperview];
    [backButton removeFromSuperview];
    [storeButton removeFromSuperview];
    [continueButton removeFromSuperview];
    
    //[animationManager runAnimationsForSequenceNamed:@"Hide Equipment"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]]];
    [[AudioManager shared] fadeOutBackgroundMusic];
}

- (void) gotoStore
{
    NSLog(@"goto store");
    
    [[EquipmentData shared] saveEquipmentData];
}

- (void) back
{
    [UIView animateWithDuration:0.1
            animations:^
            {
                [self setMaskVisibility:NO];
                if (state == MainMenuStateEquipment)
                {
                    [self setEquipmentButtonsEnabled:NO];
                }
                else if (state == MainMenuStateMission)
                {
                    //        [backButton setEnabled:NO];
                    //        [backButton runAction:[CCFadeTo actionWithDuration:0.05 opacity:0]];
                    //        achievementScrollView.isTouchEnabled = NO;
                    //        [self scheduleOnce:@selector(hideAchievementBody) delay:0.1];
                    [self setAchievementButtonsEnabled:NO];
                    achievementScrollView.isTouchEnabled = NO;
                    [animationManager runAnimationsForSequenceNamed:@"Hide Achievement"];
                }
            }
            completion:^(BOOL finished)
            {
                state = MainMenuStateHome;
//                GAMELAYER runAction:[cccallfun]
                [self backToMainMenu];
            }
    ];
}

- (void) hideEquipmentBody
{
    [animationManager runAnimationsForSequenceNamed:@"Hide Equipment"];
}

- (void) backToMainMenu
{
    [UIView animateWithDuration:0.1
            animations:^
             {
                 [self setMainMenuButtonsEnabled:YES];
             }
    ];

//    [self setMainMenuButtonsEnabled:YES];
//    [self scheduleOnce:@selector(playTitleScreenAnimation) delay:0.2];
}

- (void) playTitleScreenAnimation
{
    [animationManager runAnimationsForSequenceNamed:@"Default Timeline" tweenDuration:0.2];
}

- (void) hideAchievementBody
{
    [animationManager runAnimationsForSequenceNamed:@"Hide Achievement"];
}



- (void) setMainMenuButtonsEnabled:(BOOL)isEnabled
{
    [playButton setEnabled:isEnabled];
    [achievementButton setEnabled:isEnabled];
    [settingButton setEnabled:isEnabled];
    [gameCenterButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
//    
    playButton.alpha = opacity;
    achievementButton.alpha = opacity;
    settingButton.alpha = opacity;
    gameCenterButton.alpha = opacity;
    
//    [playButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
//    [achievementButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
//    [settingButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
//    [gameCenterButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
}

- (void) setEquipmentButtonsEnabled:(BOOL)isEnabled
{
    [storeButton setEnabled:isEnabled];
    [backButton setEnabled:isEnabled];
    [continueButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    storeButton.alpha = opacity;
    backButton.alpha = opacity;
    continueButton.alpha = opacity;
}

- (void) setAchievementButtonsEnabled:(BOOL)isEnabled
{
    [backButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    backButton.alpha = opacity;
}

- (void) setMaskVisibility:(BOOL)isVisible
{
    int opacity = 0;
    if (isVisible)
    {
        opacity = 255;
    }
    
    [mask runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
}

- (void)dealloc
{
    [playButton release];
    [achievementButton release];
    [settingButton release];
    [gameCenterButton release];
    
    [backButton release];
    [storeButton release];
    [continueButton release];
    
    [mask release];
    
    [achievementHolder removeAllChildrenWithCleanup:YES];
    [achievementScrollView release];
    [super dealloc];
}
@end

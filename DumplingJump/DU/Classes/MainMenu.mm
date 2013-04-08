//
//  MainMenu.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//
#import "Common.h"
#import "MainMenu.h"
#import "GameLayer.h"
#import "CCBReader.h"
#import "DUScrollPageView.h"
#import "DUTableView.h"
#import "EquipmentData.h"
#import "DUButtonFactory.h"
#import "MissionNode.h"
#import "AchievementData.h"
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
    //Load UserData
    [UserData shared];
    
    //Load EquipmentData if first launch
    [EquipmentData shared];
    
    //Load world data
    [WorldData shared];
    
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
    
    //Create mask
    [self createMask];
    
    //Hide mask
    mask.opacity = 0;
    
    //Disable the achievement scroll view
    achievementScrollView.isTouchEnabled = NO;
    
    //Load main menu background music
    [[AudioManager shared] preloadBackgroundMusic:@"Music_MainMenu.mp3"];
    [[AudioManager shared] playBackgroundMusic:@"Music_MainMenu.mp3" loop:YES];
    
    //DEBUG
    if ([[[[WorldData shared] loadDataWithAttributName:@"debug"] objectForKey:@"showMeTheMoneyEnabled"] boolValue])
    {
        [self createShowMeTheMoneyButton];
    }
    
}


#pragma mark -
#pragma Creation

- (void) createShowMeTheMoneyButton
{
    CCMenuItemFont *button = [CCMenuItemFont itemWithString:@"Add money" block:^(id sender) {
        int currentStar = [[USERDATA objectForKey:@"star"] intValue];
        [USERDATA setObject:[NSNumber numberWithInt:currentStar+1000] forKey:@"star"];
    }];
    button.position = ccp(200, [CCDirector sharedDirector].winSize.height - 50 - BLACK_HEIGHT);
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
}

- (void) createMask
{
    mask = [[CCSprite spriteWithSpriteFrameName:@"UI_other_mask.png"] retain];
    mask.anchorPoint = ccp(0.5,0.5);
    mask.position = ccp(winSize.width/2, winSize.height/2);
    mask.zOrder = Z_MASK;
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
    equipmentViewController = [[EquipmentViewController alloc] initWithDelegate:self];
    equipmentView = [[[NSBundle mainBundle] loadNibNamed:@"EquipmentView" owner:equipmentViewController options:nil] objectAtIndex:0];
    equipmentView.center = ccp(winSize.width/2, winSize.height/2);
    equipmentView.layer.zPosition = Z_SECONDARY_UI;
    
    [equipmentView setHidden:YES];
    [VIEW addSubview:equipmentView];
    
    [equipmentViewController hideEquipmentView];
}

- (void) createAchievementView
{
    achievementScrollView = [[DUScrollPageView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^(int num)
                     {
                         MissionNode *sampleNode = (MissionNode *)[CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                         
                         if (num+1 <= [[USERDATA objectForKey:@"achievementGroup"] intValue])
                         {
                             [sampleNode drawWithAchievementDataWithGroupID:num+1];
                         }
                         else
                         {
                             [sampleNode drawWithUnknown:num+1];
                         }
                         return (CCNode *)sampleNode;
                     } num:[[AchievementData shared] getMaxGroupNumber] padding:0 bulletNormalSprite:@"UI_mission_pages_off.png" bulletSelectedSprite:@"UI_mission_pages_on.png"];
    
    achievementScrollView.position = ccp(0,BLACK_HEIGHT);
    [achievementHolder addChild:achievementScrollView];
    achievementHolder.zOrder = Z_SECONDARY_UI;
    [achievementScrollView scrollToPage:[[USERDATA objectForKey:@"achievementGroup"] intValue] -1];
    backButton = [[DUButtonFactory createButtonWithPosition:ccp(45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_other_back.png"] retain];
    backButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setEnabled:NO];
    [backButton setAlpha:0];
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

    [self setMaskVisibility:YES];
    [equipmentView setHidden:NO];
    [equipmentViewController showEquipmentView];
    //TODO: get star number from user data
    [equipmentViewController updateStarNum:[[USERDATA objectForKey:@"star"] intValue]];
    state = MainMenuStateEquipment;
    [UIView animateWithDuration:0.1
            animations:^
            {
                [self setMainMenuButtonsEnabled:NO];
            }
     ];

}

- (void) startGame
{
    [equipmentView removeFromSuperview];
    [playButton removeFromSuperview];
    [achievementButton removeFromSuperview];
    [settingButton removeFromSuperview];
    [gameCenterButton removeFromSuperview];
    [backButton removeFromSuperview];
    [mask removeFromParentAndCleanup:NO];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]]];
    [[AudioManager shared] fadeOutBackgroundMusic];
}

- (void) gotoStore
{
    NSLog(@"goto store");
    //[[EquipmentData shared] saveEquipmentData];
}

//Back button on the main menu got hit
- (void) back
{
    [self setMaskVisibility:NO];
    [UIView animateWithDuration:0.1
            animations:^
            {
                if (state == MainMenuStateMission)
                {
                    [self setAchievementButtonsEnabled:NO];
                    achievementScrollView.isTouchEnabled = NO;
                    [animationManager runAnimationsForSequenceNamed:@"Hide Achievement"];
                }
            }
            completion:^(BOOL finished)
            {
                state = MainMenuStateHome;
                [self backToMainMenu];
            }
    ];
}

- (void) backToMainMenu
{
    [UIView animateWithDuration:0.1
            animations:^
             {
                 [self setMainMenuButtonsEnabled:YES];
             }
    ];
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

    playButton.alpha = opacity;
    achievementButton.alpha = opacity;
    settingButton.alpha = opacity;
    gameCenterButton.alpha = opacity;
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

- (void) didEquipmentViewBack
{
    state = MainMenuStateHome;
    [equipmentView setHidden:YES];
    [self backToMainMenu];
}

- (void) didEquipmentViewContinue
{
    [equipmentView setHidden:YES];
    [self startGame];
}

- (void) didHideEquipmentViewAnimStart
{
    [self setMaskVisibility:NO];
}

- (void)dealloc
{
    [playButton release];
    [achievementButton release];
    [settingButton release];
    [gameCenterButton release];
    [backButton release];
    [mask release];
    
    [achievementHolder removeAllChildrenWithCleanup:YES];
    [achievementScrollView release];
    
    [equipmentViewController release];
    [super dealloc];
}
@end

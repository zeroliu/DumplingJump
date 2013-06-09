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
#import "OptionUI.h"
#import <UIKit/UIKit.h>
#import "BuyMoreStarViewController.h"
#import "GCHelper.h"

#define TAG_HERO_ANIM 10

typedef enum {
    MainMenuStateHome,
    MainMenuStateMission,
    MainMenuStateEquipment,
    MainMenuStateOption
} MainMenuState;

@interface MainMenu() 
{
    MainMenuState state;
    DUScrollPageView *achievementScrollView;
    CCSprite *_titleHero;
    int _currentAnimNum;
    NSArray *_animationList;
}
@end

@implementation MainMenu

- (id) init
{
    if (self = [super init])
    {
        winSize = [[CCDirector sharedDirector] winSize];
        _animationList = [[NSArray alloc] initWithObjects:@"happy",@"magic",@"spring",@"shelter", nil];
        _currentAnimNum = 0;
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
    
    //Create option view
    [self createOptionView];
    
    //Create equipment view
//    [self createEquipmentView];
    
    //Create mask
    [self createMask];
    
    //Hide mask
    mask.opacity = 0;
    
    //Disable the achievement scroll view
    achievementScrollView.isTouchEnabled = NO;
    
    //Load main menu background music
    [[AudioManager shared] preloadBackgroundMusic:@"Music_MainMenu.mp3"];
    [[AudioManager shared] playBackgroundMusic:@"Music_MainMenu.mp3" loop:YES];
    [[AudioManager shared] setBackgroundMusicVolume:1];
    
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
    mask.scale = 15;
    mask.position = ccp(winSize.width/2, winSize.height/2);
    mask.zOrder = Z_MASK;
    [self addChild:mask];
}

- (void) createMainMenuButtons
{
    playButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width/2.0, winSize.height/2.0) image:@"UI_title_play.png"] retain];
    playButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:playButton];
    [playButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    
    achievementButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width/2.0, playButton.frame.origin.y + playButton.frame.size.height + 50) image:@"UI_title_mission.png"] retain];
    achievementButton.frame.size = CGSizeMake(80, 74);
    achievementButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:achievementButton];
    [achievementButton addTarget:self action:@selector(showAchievement) forControlEvents:UIControlEventTouchUpInside];
    
    settingButton = [[DUButtonFactory createButtonWithPosition:ccp(45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_title_sytem.png"] retain];
    settingButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:settingButton];
    [settingButton addTarget:self action:@selector(showOption) forControlEvents:UIControlEventTouchUpInside];
    
    gameCenterButton = [[DUButtonFactory createButtonWithPosition:ccp(winSize.width - 45, winSize.height - 40 - BLACK_HEIGHT) image:@"UI_title_ranking.png"] retain];
    gameCenterButton.layer.zPosition = Z_BUTTONS;
    [VIEW addSubview:gameCenterButton];
    [gameCenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchUpInside];
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

- (void) createOptionView
{
    [[OptionUI shared] createUIwithParent:self];
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
    
    [titleHeroHolder addChild:_titleHero z:1];
    
    [self playHeroAnimation];
    [self moveHero];
}

- (void) moveHero
{
    //Default move to left
    int destination = 0;
    if (_titleHero.position.x < winSize.width/2)
    {
        //move to right
        destination = 170;
    }
    
    id delay = [CCDelayTime actionWithDuration:5];
    id moveHero = [CCMoveTo actionWithDuration:2 position:ccp(destination, _titleHero.position.y)];
    id changeStatus = [CCCallFunc actionWithTarget:self selector:@selector(playHeroAnimation)];
    id callAgain = [CCCallFunc actionWithTarget:self selector:@selector(moveHero)];
    
    [_titleHero runAction:[CCSequence actions:changeStatus, delay, moveHero, callAgain, nil]];
}

- (void) playHeroAnimation
{
    //add effect
    CCSprite *effect = [CCSprite spriteWithSpriteFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"E_powerup_1.png"]];
    [titleHeroHolder addChild:effect z:2];
    effect.position = _titleHero.position;
    
    NSMutableArray *effectFrameArray = [NSMutableArray array];
    for (int i=1; i<=7; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"E_powerup_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [effectFrameArray addObject:frameObject];
    }
    
    id effectAnim = [CCAnimation animationWithSpriteFrames:effectFrameArray delay:0.12];
    CCAnimate *effectAnimate = [CCAnimate actionWithAnimation:effectAnim];
    id removeSelf = [CCCallBlock actionWithBlock:^{
        [effect removeFromParentAndCleanup:NO];
    }];
    [effect runAction:[CCSequence actions:effectAnimate, removeSelf, nil]];
    
    NSString *animationName = [_animationList objectAtIndex:_currentAnimNum];
    
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=6; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"H_%@_%d.png",animationName,i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id heroAnim = [CCAnimation animationWithSpriteFrames:frameArray delay:0.12];
    
    if (heroAnim != nil)
    {
        [_titleHero stopActionByTag:TAG_HERO_ANIM];
        CCAnimate *heroAnimate = [CCAnimate actionWithAnimation:heroAnim];
        CCRepeatForever *heroAnimateRepeat = [CCRepeatForever actionWithAction:heroAnimate];
        heroAnimateRepeat.tag = TAG_HERO_ANIM;
        [_titleHero runAction:heroAnimateRepeat];
    }
    
    _currentAnimNum = (_currentAnimNum + 1) % [_animationList count];
}

#pragma mark -
#pragma Animation

//Show achievement view
- (void) showAchievement
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    
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

- (void) showOption
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    
    //Change state
    state = MainMenuStateOption;
    
    [UIView animateWithDuration:0.1
                     animations:^
     {
         //Hide all the buttons on main menu
         [self setMainMenuButtonsEnabled:NO];
         [self setMaskVisibility:YES];
     }
                     completion:^(BOOL finished)
     {
         if (finished)
         {
             [self setOptionButtonsEnabled:YES];
             [[OptionUI shared] showUI];
         }
     }
     ];
}

- (void) showGameCenter
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    if ([GCHelper sharedInstance].gameCenterAvailable)
    {        
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        if (leaderboardController != nil)
        {
            [self setMainMenuButtonsEnabled:NO];
            leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
            leaderboardController.leaderboardDelegate = self;
            
            [[CCDirector sharedDirector] presentModalViewController: leaderboardController animated:YES];
        }
    }
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self setMainMenuButtonsEnabled:YES];
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated: YES];
    [viewController release];
}

- (void) startGame
{
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
    [equipmentView removeFromSuperview];
    [playButton removeFromSuperview];
    [achievementButton removeFromSuperview];
    [settingButton removeFromSuperview];
    [gameCenterButton removeFromSuperview];
    [backButton removeFromSuperview];
    [continueButton removeFromSuperview];
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
    [[AudioManager shared] playSFX:@"sfx_UI_menuButton.mp3"];
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
                else if (state == MainMenuStateOption)
                {
                    [self setOptionButtonsEnabled:NO];
                    [[OptionUI shared] hideUI];
                    [self setMaskVisibility:NO];
                }
            }
            completion:^(BOOL finished)
            {
                state = MainMenuStateHome;
                [self backToMainMenu];
            }
    ];
}

//- (void) didTapContinueButton
//{    
//    [self setMaskVisibility:NO];
//    [UIView animateWithDuration:0.3
//                     animations:^
//                     {
//                         if (state == MainMenuStateMission)
//                         {
//                             [self setAchievementButtonsEnabled:NO];
//                             achievementScrollView.isTouchEnabled = NO;
//                             [animationManager runAnimationsForSequenceNamed:@"Hide Achievement"];
//                         }
//                     }
//                     completion:^(BOOL finished)
//                     {
//                         state = MainMenuStateHome;
//                         [self startGame];
//                     }
//    ];
//
//}

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
    [continueButton setEnabled:isEnabled];
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 1;
    }
    
    backButton.alpha = opacity;
    continueButton.alpha = opacity;
}

- (void) setOptionButtonsEnabled:(BOOL)isEnabled
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
    [continueButton release];
    [mask release];
    
    [achievementHolder removeAllChildrenWithCleanup:YES];
    [achievementScrollView release];
    
    [equipmentViewController release];
    
    [_animationList release];
    _animationList = nil;
    [super dealloc];
}
@end

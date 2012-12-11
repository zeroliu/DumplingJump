//
//  MainMenu.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "MainMenu.h"
#import "GameLayer.h"
#import "CCBReader.h"
#import "DUScrollPageView.h"
#import "EquipmentData.h"
typedef enum {
    MainMenuStateHome,
    MainMenuStateMission,
    MainMenuStateEquipment
} MainMenuState;

@interface MainMenu()
{
    MainMenuState state;
    DUScrollPageView *achievementScrollView;
}
@end

@implementation MainMenu

- (void) didLoadFromCCB
{
    //Load EquipmentData if first launch
    [EquipmentData shared];
    [self createEquipmentView];
    [self createTableView];
    animationManager = self.userObject;
    state = MainMenuStateHome;
    
    //Hide unused buttons
    [backButton setOpacity:0];
    [storeButton setOpacity:0];
    [continueButton setOpacity:0];
    
    [backButton setEnabled:NO];
    [storeButton setEnabled:NO];
    [continueButton setEnabled:NO];
    
    //Disable the achievement scroll view
    achievementScrollView.isTouchEnabled = NO;
}

-(void) createEquipmentView
{
    achievementScrollView = [[DUScrollPageView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^
                     {
                         CCNode *sampleNode = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                         return sampleNode;
                     } num:8 padding:0 bulletNormalSprite:@"UI_mission_pages_off.png" bulletSelectedSprite:@"UI_mission_pages_on.png"];
    
    achievementScrollView.position = ccp(0,0);
    [achievementHolder addChild:achievementScrollView];
}

-(void) createTableView
{
    /*
    DUScrollPageView *testview = [[DUScrollPageView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^
                             {
                                 CCNode *sampleNode = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                                 return sampleNode;
                             } num:8 padding:0 bulletNormalSprite:@"UI_mission_pages_off.png" bulletSelectedSprite:@"UI_mission_pages_on.png"];
    
    testview.position = ccp(0,0);
    [tableViewHolder addChild:testview];
     */
}

-(void) showEquipment
{
    state = MainMenuStateEquipment;
    //Hide all the buttons on main menu
    [self setMainMenuButtonsEnabled:NO];
    [self scheduleOnce:@selector(showEquipmentBody) delay:0.1];
}

-(void) showEquipmentBody
{
    //Scroll down the achievement view
    [animationManager runAnimationsForSequenceNamed:@"Show Equipment"];
    //Show Equipment buttons
    [self setEquipmentButtonsEnabled:YES];
}

-(void) startGame
{
    [animationManager runAnimationsForSequenceNamed:@"Hide Equipment"];
    NSLog(@"game start");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]]];
}

-(void) gotoStore
{
    NSLog(@"goto store");
    
    [[EquipmentData shared] saveEquipmentData];
}

-(void) back
{
    if (state == MainMenuStateMission)
    {
        [backButton setEnabled:NO];
        [backButton runAction:[CCFadeTo actionWithDuration:0.05 opacity:0]];
        achievementScrollView.isTouchEnabled = NO;
        [self scheduleOnce:@selector(hideAchievementBody) delay:0.1];
    } else if (state == MainMenuStateEquipment)
    {
        [self setEquipmentButtonsEnabled:NO];
        [self scheduleOnce:@selector(hideEquipmentBody) delay:0.1];
    }
    
    state = MainMenuStateHome;
    [self scheduleOnce:@selector(backToMainMenu) delay:0.1];
}

-(void) hideEquipmentBody
{
    [animationManager runAnimationsForSequenceNamed:@"Hide Equipment"];
}

-(void) backToMainMenu
{
    [self setMainMenuButtonsEnabled:YES];
    [self scheduleOnce:@selector(playTitleScreenAnimation) delay:0.2];
}

-(void) playTitleScreenAnimation
{
    [animationManager runAnimationsForSequenceNamed:@"Default Timeline" tweenDuration:0.2];
}

-(void) hideAchievementBody
{
    [animationManager runAnimationsForSequenceNamed:@"Hide Achievement"];
}

//Show achievement view
-(void) showAchievement
{
    //Change state
    state = MainMenuStateMission;
    //Hide all the buttons on main menu
    [self setMainMenuButtonsEnabled:NO];
    [self scheduleOnce:@selector(showAchievementBody) delay:0.1];
    //Enable touch
    achievementScrollView.isTouchEnabled = YES;
}

-(void) showAchievementBody
{
    //Scroll down the achievement view
    [animationManager runAnimationsForSequenceNamed:@"Show Achievement"];
    //Show back button
    [backButton setEnabled:YES];
    [backButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:255]];
}

-(void) setMainMenuButtonsEnabled:(BOOL)isEnabled
{
    [playButton setEnabled:isEnabled];
    [achievementButton setEnabled:isEnabled];
    [settingButton setEnabled:isEnabled];
    [gameCenterButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 255;
    }
    
    [playButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
    [achievementButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
    [settingButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
    [gameCenterButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
}

-(void) setEquipmentButtonsEnabled:(BOOL)isEnabled
{
    [storeButton setEnabled:isEnabled];
    [backButton setEnabled:isEnabled];
    [continueButton setEnabled:isEnabled];
    
    int opacity = 0;
    if (isEnabled)
    {
        opacity = 255;
    }
    
    [storeButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
    [backButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
    [continueButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:opacity]];
}

- (void)dealloc
{
    [achievementHolder removeAllChildrenWithCleanup:YES];
    [achievementScrollView release];
    [super dealloc];
}
@end

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

typedef enum {
    MainMenuStateHome,
    MainMenuStateMission,
    MainMenuStateEquipment
} MainMenuState;

@interface MainMenu()
{
    MainMenuState state;
}
@end

@implementation MainMenu

- (void) didLoadFromCCB
{
    [self createScrollPageControlView];
    animationManager = self.userObject;
    state = MainMenuStateHome;
    
    //Hide unused buttons
    [backButton setOpacity:0];
}

-(void) createScrollPageControlView
{
    DUScrollPageView *scrollView = [[DUScrollPageView alloc] initWithViewSize:[[CCDirector sharedDirector]winSize] viewBlock:^
                     {
                         CCNode *sampleNode = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
                         return sampleNode;
                     } num:8 padding:0 bulletNormalSprite:@"UI_mission_pages_off.png" bulletSelectedSprite:@"UI_mission_pages_on.png"];
    
    scrollView.position = ccp(0,0);
    [objectHolder addChild:scrollView];
}

-(void) gameStart
{
    NSLog(@"game start");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer scene]]];
}

-(void) back
{
    if (state == MainMenuStateMission)
    {
        [backButton setEnabled:NO];
        [backButton runAction:[CCFadeTo actionWithDuration:0.05 opacity:0]];
        [self scheduleOnce:@selector(hideMissionBody) delay:0.05];
    }
    
    state = MainMenuStateHome;
    [self scheduleOnce:@selector(backToMainMenu) delay:0.1];
}

-(void) backToMainMenu
{
    [self setMainMenuButtonsEnabled:YES];
}

-(void) hideMissionBody
{
    [animationManager runAnimationsForSequenceNamed:@"Achievement scroll up"];
}

//Show achievement view
-(void) showAchievement
{
    //Change state
    state = MainMenuStateMission;
    //Hide all the buttons on main menu
    [self setMainMenuButtonsEnabled:NO];
    [self scheduleOnce:@selector(showAchievementBody) delay:0.1];
}

-(void) showAchievementBody
{
    //Scroll down the achievement view
    [animationManager runAnimationsForSequenceNamed:@"Achievement scroll down"];
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
    
    int scale = 0;
    
    if (isEnabled)
    {
        scale = 255;
    }
    
    [playButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:scale]];
    [achievementButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:scale]];
    [settingButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:scale]];
    [gameCenterButton runAction:[CCFadeTo actionWithDuration:0.1 opacity:scale]];
}
@end

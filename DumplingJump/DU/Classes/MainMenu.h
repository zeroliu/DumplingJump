//
//  MainMenu.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"
#import "CCControlButton.h"
#import "CCBAnimationManager.h"
#import "EquipmentViewController.h"
#import <GameKit/GameKit.h>

@interface MainMenu : CCLayer <EquipmentViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CGSize winSize;
    CCNode *achievementHolder;
    
    //Main Menu buttons
    UIButton *playButton;
    UIButton *achievementButton;
    UIButton *settingButton;
    UIButton *gameCenterButton;
    UIButton *backButton;
    UIButton *continueButton;
    
    //Mask
    CCSprite *mask;
    
    CCNode *equipmentViewHolder;
    CCNode *titleHeroHolder;
    
    CCSprite *equipmentBoard;
    CCLabelTTF *starNum;
    
    CCBAnimationManager *animationManager;
    EquipmentViewController *equipmentViewController;
    UIView *equipmentView;
}
@end

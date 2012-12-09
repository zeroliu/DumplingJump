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
@interface MainMenu : CCLayer
{
    CCNode *achievementHolder;
    CCControlButton *playButton;
    CCControlButton *achievementButton;
    CCControlButton *settingButton;
    CCControlButton *gameCenterButton;
    CCControlButton *backButton;
    
    CCControlButton *storeButton;
    CCControlButton *continueButton;
    CCBAnimationManager *animationManager;
}
@end

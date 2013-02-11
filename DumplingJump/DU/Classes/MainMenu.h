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
    CGSize winSize;
    CCNode *achievementHolder;
    
    //Main Menu buttons
    UIButton *playButton;
    UIButton *achievementButton;
    UIButton *settingButton;
    UIButton *gameCenterButton;
    
    //Equipment View buttons
    UIButton *backButton;
    UIButton *storeButton;
    UIButton *continueButton;
    
    //Mask
    UIImageView *mask;
    
    CCNode *equipmentViewHolder;
    CCNode *titleHeroHolder;
    
    CCSprite *equipmentBoard;
    CCLabelTTF *starNum;
    
    CCBAnimationManager *animationManager;
}
@end

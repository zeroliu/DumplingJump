//
//  GameUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
@interface GameUI : DUUI
{
    CCLabelBMFont *UIScoreText;
    CCLabelBMFont *UIStarText;
    CCSprite *starScoreIcon;
    CCLabelBMFont *meterIcon;
    
    CCNode *clearMessage;
    CCLabelBMFont *distanceNum;
    
    CCNode *shieldButtonHolder; //0->CCControlButton, 1->green, 2->white effect
    CCNode *magnetButtonHolder;
    CCSprite *UIMask;

    //Reborn button
    CCControlButton *rebornButton;
    CCSprite *rebornBar;
    CCNode *rebornButtonHolder;
    CCLabelBMFont *rebornCostLabel;
    
    //Headstart button
    CCControlButton *headStartButton;
    CCSprite *headstartBar;
    CCNode *headstartButtonHolder;
    CCLabelBMFont *headstartCostLabel;
    
    CCControlButton *pauseButton;
    CCSprite *mask;
    
    CCLabelTTF *unlockAchievementName;
    CCNode *achievementUnlockHolder;
}

+(id) shared;
-(void) fadeOut;
-(void) resetUI;
-(void) updateDistance:(int)distance;
-(void) updateStar:(float)starNum;
-(void) addStageClearMessageWithDistance:(int) distance;
-(void) addAchievementUnlockMessageWithName:(NSString *)name;
-(void) showRebornButton;
-(void) pauseUI;
-(void) resumeUI;
-(void) createMask;
-(void) removeMask;
-(void) fadeInUI;
-(void) setButtonsEnabled: (BOOL)enabled;
//Reset all the button bars to full
-(void) resetAllButtonBar;
//Reset a certain button bar to full
-(void) resetButtonBarWithName:(NSString *)buttonName;
//Cool down a button
-(void) cooldownButtonBarWithName:(NSString *)buttonName;
-(void) updateDistanceSign:(int)distance;
-(CGPoint) getStarDestination;
-(void) scaleStarUI;
-(void) refreshButtons;
-(void) showHeadstartButton;
@end

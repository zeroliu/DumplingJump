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
    CCLabelTTF *UIScoreText;
    CCLabelTTF *UIStarText;
    CCNode *clearMessage;
    CCLabelTTF *distanceNum;
    CCNode *bombButtonHolder; //0->CCControlButton, 1->green, 2->white effect
    CCNode *magnetButtonHolder;
    CCSprite *UIMask;
    CCSprite *rebornBar;
    CCNode *rebornButtonHolder;
    CCLabelTTF *rebornQuantity;
    CCMenuItem *pauseButton;
}

+(id) shared;
-(void) fadeOut;
-(void) resetUI;
-(void) updateDistance:(int)distance;
-(void) updateStar:(int)starNum;
-(void) showStageClearMessageWithDistance;
-(void) showRebornButton;
-(void) pauseUI;
-(void) resumeUI;
-(void) setButtonsEnabled: (BOOL)enabled;
//Reset all the button bars to full
-(void) resetAllButtonBar;
//Reset a certain button bar to full
-(void) resetButtonBarWithName:(NSString *)buttonName;
//Cool down a button
-(void) cooldownButtonBarWithName:(NSString *)buttonName;
@end

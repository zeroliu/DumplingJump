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
    CCSprite *starScoreIcon;
    CCNode *clearMessage;
    CCLabelTTF *distanceNum;
    CCNode *shieldButtonHolder; //0->CCControlButton, 1->green, 2->white effect
    CCNode *magnetButtonHolder;
    CCSprite *UIMask;
    CCSprite *rebornBar;
    CCNode *rebornButtonHolder;
    CCLabelTTF *rebornQuantity;
    CCMenuItem *pauseButton;
    CCSprite *mask;
}

+(id) shared;
-(void) fadeOut;
-(void) resetUI;
-(void) updateScore:(int)score;
-(void) updateStar:(int)starNum;
-(void) showStageClearMessageWithDistance;
-(void) showRebornButton;
-(void) pauseUI;
-(void) resumeUI;
-(void) removeMask;
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
@end

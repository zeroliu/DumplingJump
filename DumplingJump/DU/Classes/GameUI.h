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
    
    CCSprite *UIMask;
    CCSprite *rebornBar;
    CCNode *rebornButtonHolder;
}
+(id) shared;
-(void) fadeOut;
-(void) resetUI;
-(void) updateDistance:(int)distance;
-(void) updateStar:(int)starNum;
-(void) showStageClearMessageWithDistance;
-(void) showRebornButton;
@end

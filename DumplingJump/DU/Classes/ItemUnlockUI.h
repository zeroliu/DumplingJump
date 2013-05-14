//
//  ItemUnlockUI
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "MissionNode.h"

@interface ItemUnlockUI : DUUI
{
    CGSize winsize;
    
    CCLabelTTF *multiplierNum;
    CCLabelTTF *onMedalMultiplierText;
    CCLabelTTF *starText;
    CCSprite *starIcon;
    CCNode *nodeHolder;
    CCControlButton *forwardButton;
    CGFloat _starNum;
    CGFloat targetStarNum;
}
@property (nonatomic, assign) CGFloat starNum;
+(id) shared;

@end

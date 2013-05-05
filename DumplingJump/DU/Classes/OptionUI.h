//
//  OptionUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUUI.h"
@interface OptionUI : DUUI
{
    CCControlButton *musicToggle;
    CCControlButton *soundToggle;
    CCControlButton *tutorialToggle;
    
    CCSprite *canvas;
    CCSprite *bottom;
}
+(id) shared;
-(void) showUI;
-(void) hideUI;
@end

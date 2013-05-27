//
//  TutorialUI
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUUI.h"
@interface TutorialUI : DUUI
{
    CCSprite *canvas;
    CCSprite *bottom;
    CCSprite *animationHolder;
    CCControlButton *forwardButton;
    CCLabelTTF *tipNumLabel;
    CCLabelTTF *tipLabel;
}
+(id) shared;
-(void) showUI;
-(void) hideUI;
-(void) showUIwithCallback:(void(^)())callbackBlock;
-(void) playTutorialAnimation:(NSString *)animName;
-(void) changeToImage:(NSString *)imageName;
-(void) updateTipWithNumber:(int)num description:(NSString *)text;
@end

//
//  DeadUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
@interface DeadUI : DUUI
{
    CCLabelTTF *scoreText;
    CCLabelTTF *starText;
    CCLabelTTF *totalStarText;
    CCLabelTTF *distanceText;
    CCLabelTTF *multiplierText;
}
+(id) shared;
-(void) updateUIDataWithScore:(int)score Star:(int)star TotalStar:(int)totalStar Distance:(int)distance Multiplier:(int)multiplier IsHighScore:(BOOL)isHighScore;
@end

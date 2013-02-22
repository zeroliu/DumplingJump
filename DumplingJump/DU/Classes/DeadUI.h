//
//  DeadUI.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUUI.h"
#import "EquipmentViewController.h"
@interface DeadUI : DUUI <EquipmentViewControllerDelegate>
{
    EquipmentViewController *equipmentViewController;
    UIView *equipmentView;
    
    CCLabelTTF *scoreText;
    CCLabelTTF *starText;
    CCLabelTTF *totalStarText;
    CCLabelTTF *distanceText;
    CCLabelTTF *multiplierText;
}
+(id) shared;
-(void) updateUIDataWithScore:(int)score Star:(int)star TotalStar:(int)totalStar Distance:(int)distance Multiplier:(float)multiplier IsHighScore:(BOOL)isHighScore;
@end

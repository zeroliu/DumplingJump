//
//  LevelTestTool.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-24.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "Common.h"
@interface LevelTestTool : CCNode <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UITextField *levelEditor;
    NSString *levelName;
    UIView *myView;
    
    UIPickerView *myPickerView;
}
+(id) shared;
-(void) reload;
-(void) updateLevelName:(NSString *)theLevelName;
-(void) setEnable:(BOOL)isEnabled;
@end

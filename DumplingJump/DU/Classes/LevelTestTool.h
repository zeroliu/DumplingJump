//
//  LevelTestTool.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-24.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "Common.h"
@interface LevelTestTool : CCNode <UITextFieldDelegate>
{
    UITextField *levelEditor;
    NSString *levelName;
    UIView *myView;
}
+(id) shared;
-(void) reload;
-(void) updateLevelName:(NSString *)theLevelName;
@end

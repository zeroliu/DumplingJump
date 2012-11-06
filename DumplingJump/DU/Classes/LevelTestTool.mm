//
//  LevelTestTool.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-24.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "LevelTestTool.h"
#import "LevelManager.h"
@implementation LevelTestTool

+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[LevelTestTool alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self reload];
    }
    
    return self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
   if (textField == levelEditor)
   {
       [levelEditor endEditing:YES];
       levelNum = [levelEditor.text intValue];
       if (levelNum < [[LevelManager shared] paragraphsCount])
       {
           [[LevelManager shared] loadParagraphAtIndex:levelNum];
       }
   }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) reload
{
    myView = [[CCDirector sharedDirector] view];
    levelEditor = [[UITextField alloc] initWithFrame:CGRectMake(240, 60, 40, 40)];
    [levelEditor setText:@""];
    [levelEditor setBackgroundColor: [UIColor whiteColor]];
    //[levelEditor becomeFirstResponder];
    [levelEditor setDelegate:self];
    levelEditor.clearsOnBeginEditing = YES;
    levelEditor.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [myView addSubview:levelEditor];
    [[[[CCDirector sharedDirector] view] window] addSubview:myView];
}
@end

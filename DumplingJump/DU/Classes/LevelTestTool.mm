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
       if (levelNum <= [[LevelManager shared] paragraphsCount] && levelNum > 0)
       {
           [[LevelManager shared] loadParagraphAtIndex:(levelNum-1)];
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
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Next" target:[LevelManager shared] selector:@selector(jumpToNextLevel)];
    item.position = ccp(270, winSize.height - 300);
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    menu.position = CGPointZero;
    //[GAMELAYER addChild:menu];
    
    myView = [[CCDirector sharedDirector] view];
    levelEditor = [[UITextField alloc] initWithFrame:CGRectMake(20, 420, 40, 40)];
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

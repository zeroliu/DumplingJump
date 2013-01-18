//
//  LevelTestTool.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-24.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "LevelTestTool.h"
#import "LevelManager.h"
@interface LevelTestTool()
{
    CCMenuItemFont *levelNameDisplay;
}
@end

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
       levelName = levelEditor.text;
        [[LevelManager shared] loadParagraphWithName:levelName];
       
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
    [levelNameDisplay removeFromParentAndCleanup:NO];
    levelNameDisplay = [CCMenuItemFont itemWithString:@"LevelName"];
    levelNameDisplay.position = ccp(winSize.width, 30);
    levelNameDisplay.anchorPoint = ccp(1,0);
    [levelNameDisplay setIsEnabled:NO];
    CCMenu *menu = [CCMenu menuWithItems:levelNameDisplay, nil];
    menu.position = CGPointZero;
    [GAMELAYER addChild:menu];
    
    myView = [[CCDirector sharedDirector] view];
    levelEditor = [[UITextField alloc] initWithFrame:CGRectMake(20, 420, 40, 40)];
    [levelEditor setText:@""];
    [levelEditor setBackgroundColor: [UIColor whiteColor]];
    [levelEditor setDelegate:self];
    levelEditor.clearsOnBeginEditing = YES;
    levelEditor.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [myView addSubview:levelEditor];
    [[[[CCDirector sharedDirector] view] window] addSubview:myView];
}

-(void) updateLevelName:(NSString *)theLevelName
{
    [levelNameDisplay setString:theLevelName];
}
@end

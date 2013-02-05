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
    CCMenuItemFont *levelSelectorToggle;
    CCMenuItemFont *levelSelectorConfirm;
    CCMenuItemFont *levelSelectorStatus;
    
    NSString *levelSelected;
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
/*
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
*/
-(void) reload
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    /*
    CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Next" target:[LevelManager shared] selector:@selector(jumpToNextLevel)];
    item.position = ccp(270, winSize.height - 300);
    */
    
    levelSelectorToggle = [[CCMenuItemFont itemWithString:@"Level" target:self selector:@selector(showLevelSelector)] retain];
    levelSelectorToggle.position = ccp(0,winSize.height - 80);
    levelSelectorToggle.anchorPoint = ccp(0,1);
    
    levelSelectorConfirm = [[CCMenuItemFont itemWithString:@"OK" target:self selector:@selector(confirmLevel)] retain];
    levelSelectorConfirm.anchorPoint = ccp(0,0);
    levelSelectorConfirm.position = ccp(280, winSize.height - 340);
    [levelSelectorConfirm setIsEnabled:NO];
    levelSelectorConfirm.visible = NO;
    
    levelSelectorStatus = [[CCMenuItemFont itemWithString:@"Level Name"] retain];
    levelSelectorStatus.anchorPoint = ccp(0,0);
    levelSelectorStatus.position = ccp(0, winSize.height - 270);
    [levelSelectorStatus setIsEnabled:NO];
    levelSelectorStatus.visible = NO;
    
    [levelNameDisplay removeFromParentAndCleanup:NO];
    levelNameDisplay = [[CCMenuItemFont itemWithString:@"LevelName"] retain];
    levelNameDisplay.position = ccp(0, winSize.height - 50);
    levelNameDisplay.anchorPoint = ccp(0,1);
    [levelNameDisplay setIsEnabled:NO];
    CCMenu *menu = [CCMenu menuWithItems:levelNameDisplay, levelSelectorToggle, levelSelectorConfirm, levelSelectorStatus, nil];
    menu.position = CGPointZero;
    
    NSDictionary *debugData = [[WorldData shared] loadDataWithAttributName:@"debug"];
    if ([[debugData objectForKey:@"levelEditorEnabled"] boolValue])
    {
        [GAMELAYER addChild:menu];
    }
    myView = [[CCDirector sharedDirector] view];
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,300, 260, 100)];
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    myPickerView.showsSelectionIndicator = YES;
    [[myView window] addSubview:myPickerView];
    myPickerView.hidden = YES;
}

-(void) showLevelSelector
{
    [[[Hub shared] gameLayer] pauseGame];
    [levelSelectorToggle setIsEnabled:NO];
    myPickerView.hidden = NO;
    [levelSelectorConfirm setIsEnabled:YES];
    levelSelectorConfirm.visible = YES;
    levelSelectorStatus.visible = YES;
}

-(void) hideLevelSelector
{
    [[[Hub shared] gameLayer] resumeGame];
    [levelSelectorToggle setIsEnabled:YES];
    myPickerView.hidden = YES;
    [levelSelectorConfirm setIsEnabled:NO];
    levelSelectorConfirm.visible = NO;
    levelSelectorStatus.visible = NO;
}

-(void) confirmLevel
{
    [self hideLevelSelector];
    [[LevelManager shared] loadParagraphWithName:levelSelected];
}

-(void) updateLevelName:(NSString *)theLevelName
{
    [levelNameDisplay setString:theLevelName];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    levelSelected = [[LevelManager shared] getParagraphNameByIndex:row];
    //[myPickerView selectRow:[pickerView selectedRowInComponent:0] inComponent:component animated:YES];
    [levelSelectorStatus setString:levelSelected];
    DLog(@"get result %@", levelSelected);
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[LevelManager shared] getParagraphNameByIndex:row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[LevelManager shared] paragraphsCount];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)dealloc
{
    [levelSelected release];
    [levelSelectorToggle release];
    [levelSelectorConfirm release];
    [levelSelectorStatus release];
    [levelNameDisplay release];
    [myPickerView release];
    [super dealloc];
}
@end

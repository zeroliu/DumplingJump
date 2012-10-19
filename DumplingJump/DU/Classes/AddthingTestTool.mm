//
//  AddthingTestTool.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-14.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AddthingTestTool.h"
#import "LevelManager.h"

@interface AddthingTestTool()
{
    NSMutableArray *_addthingDropList;
    float xPosUnit;
    int repeat;
    CCMenuItem *item1;
    CCMenuItem *item2;
    CCMenuItem *item3;
    id dropingAction;
}
@end

@implementation AddthingTestTool

+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[AddthingTestTool alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        repeat = 1;
        [self initDropList];
        [self createUI];
    }
    
    return self;
}

-(void) initDropList
{
    _addthingDropList = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++)
    {
        [_addthingDropList addObject:[NSNumber numberWithBool:NO]];
    }
}

-(void) createUI
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //Create drop list buttons
    NSMutableArray *itemArray = [NSMutableArray array];
    float yPos = winSize.height - 30;
    xPosUnit = (winSize.width-5) / 10.0f;
    float itemScale = (xPosUnit - 5) / 30.0f;
    for (int i=0; i<10; i++)
    {
        CCMenuItem *_plusItem = [CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png"];
        CCMenuItem *_minusItem = [CCMenuItemImage itemWithNormalImage:@"ButtonMinus.png" selectedImage:@"ButtonMinusSel.png"];
        CCMenuItemToggle *menuItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(updateDropList:) items:_minusItem, _plusItem, nil];
        
        menuItem.scale = itemScale;
        menuItem.position = ccp(xPosUnit * i + 5 + xPosUnit/2,yPos);
        menuItem.tag = i;
        [itemArray addObject:menuItem];
    }
    //End creating drop list buttons
    
    //Create generate button
    CCMenuItemFont *generateButton = [CCMenuItemFont itemWithString:@"Generate" target:self selector:@selector(dropAddthings)];
    generateButton.position = ccp(60, 30);
    
    //Create repeat button
    item1 = [CCMenuItemImage itemWithNormalImage:@"Button1.png" selectedImage:@"Button1Sel.png"];
    item2 = [CCMenuItemImage itemWithNormalImage:@"Button2.png" selectedImage:@"Button2Sel.png"];
    item3 = [CCMenuItemImage itemWithNormalImage:@"Button3.png" selectedImage:@"Button3Sel.png"];
    CCMenuItemToggle *repeatToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(changeRepeat:) items:item1, item2, item3, nil];
    repeatToggle.position = ccp(60,60);
    repeatToggle.scale = 1.5f;
    
    //Create menu
    CCMenu *menu = [CCMenu menuWithArray:itemArray];
    [menu addChild:generateButton];
    [menu addChild:repeatToggle];
    menu.position = CGPointZero;

    [GAMELAYER addChild:menu];
}

-(void) updateDropList:(id)sender
{
    CCMenuItemToggle *item = (CCMenuItemToggle *)sender;
    
    [_addthingDropList replaceObjectAtIndex:item.tag withObject:
     [NSNumber numberWithBool:![[_addthingDropList objectAtIndex:item.tag] boolValue]]];
}

-(void) dropAddthings
{
    //[GAMELAYER stopAction:dropingAction];
    
    id func = [CCCallFunc actionWithTarget:[AddthingTestTool shared] selector:@selector(generateAddthing)];
    id delay = [CCDelayTime actionWithDuration: 1];
    id sequence = [CCSequence actions:func, delay, nil];
    
    dropingAction = [CCRepeat actionWithAction:sequence times:repeat];
    
    [GAMELAYER runAction:dropingAction];
}

-(void) generateAddthing
{
    for (int i=0; i<[_addthingDropList count]; i++)
    {
        if ([[_addthingDropList objectAtIndex:i] boolValue])
        {
            [[LevelManager shared] dropAddthingWithName:TUB atPosition:ccp(xPosUnit * i + 5 + xPosUnit/2,600)];
        }
    }
}

-(void) changeRepeat:(id)sender
{
    CCMenuItemToggle *item = (CCMenuItemToggle *)sender;
    if (item.selectedItem == item1)
    {
        repeat = 1;
    } else if (item.selectedItem == item2)
    {
        repeat = 5;
    } else
    {
        repeat = 10;
    }
    
}

-(void) dealloc
{
//    [_plusItem release];
//    _plusItem = nil;
//    [_minusItem release];
//    _minusItem = nil;
    [item1 release];
    [item2 release];
    [item3 release];
    [_addthingDropList release];
    _addthingDropList = nil;
    [super dealloc];
}

@end

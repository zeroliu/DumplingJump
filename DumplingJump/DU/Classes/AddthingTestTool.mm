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
    CCMenuItemFont *generateButton = [CCMenuItemFont itemWithString:@"Generate" target:self selector:@selector(generateAddthing:)];
    generateButton.position = ccp(60, 30);
    
    //Create menu
    CCMenu *menu = [CCMenu menuWithArray:itemArray];
    [menu addChild:generateButton];
    menu.position = CGPointZero;

    [GAMELAYER addChild:menu];
}

-(void) updateDropList:(id)sender
{
    CCMenuItemToggle *item = (CCMenuItemToggle *)sender;
    
    [_addthingDropList replaceObjectAtIndex:item.tag withObject:
     [NSNumber numberWithBool:![[_addthingDropList objectAtIndex:item.tag] boolValue]]];
    
}

-(void) generateAddthing:(id)sender
{
    for (int i=0; i<[_addthingDropList count]; i++)
    {
        if ([[_addthingDropList objectAtIndex:i] boolValue])
        {
            [[LevelManager shared] dropAddthingWithName:TUB atPosition:ccp(xPosUnit * i + 5 + xPosUnit/2,600)];
        }
    }
}

-(void) dealloc
{
//    [_plusItem release];
//    _plusItem = nil;
//    [_minusItem release];
//    _minusItem = nil;
    [_addthingDropList release];
    _addthingDropList = nil;
    [super dealloc];
}

@end

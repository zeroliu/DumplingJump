//
//  ConfigScene.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-4.
//  Copyright (c) 2012  CMU ETC. All rights reserved.
//

#import "ConfigScene.h"
#import "TextInputField.h"
#import "HeroManager.h"

@implementation ConfigScene
+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    ConfigScene *layer = [ConfigScene node];
    [scene addChild:layer];
    return scene;
}

-(void) onExit
{
    NSArray *subViews = [[[CCDirector sharedDirector] view] subviews];
    for (id view in subViews)
    {
        [view removeFromSuperview];
    }

}

-(id) init
{
    if (self = [super initWithColor:ccc4(192,192,192,125)])
    {
        [self createBackButton];
        [self createConfigButtons];
    }
    return self;
}

-(void) createBackButton
{
   // float windowHeight = [[CCDirector sharedDirector] winSize].height;
    CCMenuItemFont *returnButton = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(backToGame)];
    returnButton.position = ccp(270, 40);
    
    CCMenu *menu = [CCMenu menuWithItems:returnButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
}

-(void) createConfigButtons
{
    float height = [[CCDirector sharedDirector] winSize].height;
    //CCMenu *menu = [CCMenu menuWithArray:buttonsArray];
    [self addChild:[self createConfigBlockWithName: @"Radius" Tag:1 Size:ccp(80, 40) Position:ccp(40, height - 60) Selector:@selector(setHeroRadius:) InitValue:[NSString stringWithFormat:@"%.2f",((HeroManager*)[HeroManager shared]).heroRadius]]];
    [self addChild:[self createConfigBlockWithName: @"Mass" Tag:2 Size:ccp(80, 40) Position:ccp(120, height - 60) Selector:@selector(test:) InitValue:@"yyy"]];
    [self addChild:[self createConfigBlockWithName: @"I" Tag:3 Size:ccp(80, 40) Position:ccp(200, height - 60) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Fric" Tag:4 Size:ccp(80, 40) Position:ccp(280, height - 60) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"MaxVx" Tag:5 Size:ccp(80, 40) Position:ccp(40, height - 120) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"MaxVy" Tag:6 Size:ccp(80, 40) Position:ccp(120, height - 120) Selector:@selector(test:) InitValue:@"yyy"]];
    [self addChild:[self createConfigBlockWithName: @"Acc" Tag:7 Size:ccp(80, 40) Position:ccp(200, height - 120) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Jump" Tag:8 Size:ccp(80, 40) Position:ccp(280, height - 120) Selector:@selector(test:) InitValue:@"xxx"]];
    
    [self addChild:[self createConfigBlockWithName: @"Freque_L" Tag:9 Size:ccp(100, 40) Position:ccp(60, height - 200) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Freque_M" Tag:10 Size:ccp(100, 40) Position:ccp(160, height - 200) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Freque_R" Tag:11 Size:ccp(100, 40) Position:ccp(260, height - 200) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Damp_L" Tag:12 Size:ccp(100, 40) Position:ccp(60, height - 260) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Damp_M" Tag:13 Size:ccp(100, 40) Position:ccp(160, height - 260) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Damp_R" Tag:14 Size:ccp(100, 40) Position:ccp(260, height - 260) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Gravity" Tag:15 Size:ccp(100, 40) Position:ccp(60, height - 340) Selector:@selector(test:) InitValue:@"xxx"]];
    [self addChild:[self createConfigBlockWithName: @"Mass_Mult" Tag:16 Size:ccp(100, 40) Position:ccp(160, height - 340) Selector:@selector(test:) InitValue:@"xxx"]];
}

-(id) createConfigBlockWithName:(NSString *)name Tag:(int)tag Size:(CGPoint)size Position:(CGPoint)position Selector:(SEL)selector InitValue:(NSString *)initValue
{
    /*
    CCMenuItemImage *bg = [CCMenuItemImage itemWithNormalImage:@"square_border.png" selectedImage:@"square_border.png"];
    bg.scaleX = size.x / bg.contentSize.width;
    bg.scaleY = size.y / bg.contentSize.height;
    bg.position = CGPointZero;
    */
    CCLabelTTF *titleText = [CCLabelTTF labelWithString:name fontName:@"Arial" fontSize:20];
    CCMenuItemLabel *title = [CCMenuItemLabel itemWithLabel:titleText];
    
    CCMenuItemFont *display = [CCMenuItemFont itemWithString:initValue];
    [display setFontSize:20];
    [display setColor:ccc3(104,0,0)];
    CCMenu *menu = [CCMenu menuWithItems:title, display, nil];
    [menu alignItemsVertically];
    menu.tag = tag;
    menu.position = position;
    
    [[TextInputField alloc] initWithParent:self Selector:selector Position:ccp(position.x-size.x/2, [[CCDirector sharedDirector] winSize].height-(position.y+size.y/2)) Size:size DisplayField:display];
    
    return menu;
}
-(void) setHeroRadius:(NSString *)radiusString
{
    ((HeroManager*)[HeroManager shared]).heroRadius = [radiusString floatValue];
}

-(void) test:(NSString *)returnValue
{
    DLog(@"test successful!!!%@", returnValue);
}

-(void) backToGame
{
    [[CCDirector sharedDirector] popScene];
}

@end

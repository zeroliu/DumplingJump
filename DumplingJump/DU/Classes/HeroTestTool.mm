//
//  HeroTestTool.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "HeroTestTool.h"
#import "HeroManager.h"

@implementation HeroTestTool
+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[HeroTestTool alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self createUI];
    }
    
    return self;
}

-(void) createUI
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Revive" target:self selector:@selector(revive)];
    item.position = ccp(270, winSize.height - 200);
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    menu.position = CGPointZero;
    [GAMELAYER addChild:menu];
}

-(void) revive
{
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
}
@end

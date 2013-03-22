//
//  ItemUnlockUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ItemUnlockUI.h"
#import "DeadUI.h"
#import "CCBReader.h"
#import "UserData.h"
#import "EquipmentData.h"

@implementation ItemUnlockUI
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[ItemUnlockUI alloc] init];
    }
    return shared;
}

-(void) createUI
{
    [super createUI];
    [self updateData];
}

-(void) updateData
{
    //increase multiplier
    int currentMultiplier = [[USERDATA objectForKey:@"multiplier"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentMultiplier + 1] forKey:@"multiplier"];
    
    //increase current group
    int currentGroup = [[USERDATA objectForKey:@"achievementGroup"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentGroup + 1] forKey:@"achievementGroup"];
    
    //update UI
    NSDictionary *currentEquipment = [[EquipmentData shared] findEquipmentWithGroupID:currentGroup];
    NSDictionary *nextEquipment = [[EquipmentData shared] findEquipmentWithGroupID:currentGroup+1];
    
    [USERDATA setObject:[NSNumber numberWithInt:0] forKey:[currentEquipment objectForKey:@"name"]];
    
    [itemTitle setString:[currentEquipment objectForKey:@"displayName"]];
    
    float scale = 150 / itemTitle.boundingBox.size.width;
    itemTitle.scale = MIN(1, scale);

    NSString *multiplierString = [NSString stringWithFormat:@"%@x",[USERDATA objectForKey:@"multiplier"]];
    [multiplierNum setString: multiplierString];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *unlockedItemframe = [cache spriteFrameByName:[NSString stringWithFormat:@"%@.png",[currentEquipment objectForKey:@"image"]]];
    [unlockedItemSprite setDisplayFrame:unlockedItemframe];
    CCSpriteFrame *lockedItemFrame = [cache spriteFrameByName:[NSString stringWithFormat:@"%@_shadow.png",[currentEquipment objectForKey:@"image"]]];
    [lockedItemSprite setDisplayFrame:lockedItemFrame];
    CCSpriteFrame *nextItemFrame = [cache spriteFrameByName:[NSString stringWithFormat:@"%@_shadow.png",[nextEquipment objectForKey:@"image"]]];
    [nextItemSprite setDisplayFrame:nextItemFrame];
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"ItemGetUI.ccbi";
        priority = Z_DEADUI+1;
        winsize = [[CCDirector sharedDirector] winSize];
    }
    
    return self;
}

-(void)didTapForward:(id)sender
{
    [animationManager runAnimationsForSequenceNamed:@"Fly Up"];
    id delay = [CCDelayTime actionWithDuration:0.5];
    id resumeGameFunc = [CCCallFunc actionWithTarget:GAMELAYER selector:@selector(showDeadUI)];
    id selfDestruction = [CCCallFunc actionWithTarget:self selector:@selector(destroy)];
    id sequence = [CCSequence actions:delay, resumeGameFunc, selfDestruction, nil];
    
    [node runAction:sequence];
}

- (void) dealloc
{
    [itemTitle release];
    [multiplierNum release];
    [unlockedItemSprite release];
    [lockedItemSprite release];
    [nextItemSprite release];
    [super dealloc];
}

@end

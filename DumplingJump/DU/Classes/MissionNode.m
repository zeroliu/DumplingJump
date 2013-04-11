//
//  MissionNode.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "MissionNode.h"
#import "AchievementData.h"
#import "AchievementManager.h"
#import "Constants.h"
#import "UserData.h"
#import "EquipmentData.h"

@implementation MissionNode
@synthesize missionArray;

-(void)didLoadFromCCB
{
    missionArray = [NSArray arrayWithObjects:mission0, mission1, mission2, mission3, nil];
}

- (void) drawlockedItemSpriteWithGroupID:(int)groupID
{
    NSDictionary *currentEquipment = [[EquipmentData shared] findEquipmentWithGroupID:groupID];

    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame *unlockedItemframe = [cache spriteFrameByName:[NSString stringWithFormat:@"%@_shadow.png",[currentEquipment objectForKey:@"image"]]];
    [unlockItemSprite setDisplayFrame:unlockedItemframe];
}

- (void) drawWithUnknown:(int)groupID
{
    for (int i=0; i<4; i++)
    {
        AchievementNode *node = [missionArray objectAtIndex:i];
        
        //check if unlocked
        [node.UnlockIcon setVisible:NO];
        
        //update title
        [node.MissionName setString:@"???"];
        
        //update description
        [node.DescriptionText setString:@"??????"];
        
        [node.Bar setScaleY:0];
    }
    [self drawlockedItemSpriteWithGroupID:groupID];
}

- (void) drawWithAchievementDataWithGroupID:(int)groupID
{
    NSArray *availableAchievement = [[[AchievementData shared] getAllAchievementsByGroupID:groupID]retain];
    
    for (int i=0; i<4; i++)
    {
        NSDictionary *data = [availableAchievement objectAtIndex:i];
        AchievementNode *node = [missionArray objectAtIndex:i];
        int achievementID = [[data objectForKey:@"id"] intValue];
        NSString *key = [NSString stringWithFormat:@"%d-%d", groupID, achievementID];
        
        //check if unlocked
        if ([[((UserData *)[UserData shared]).userAchievementDataDictionary objectForKey:key] isEqualToString:@"YES"])
        {
            [node.UnlockIcon setVisible:YES];
        }
        else
        {
            [node.UnlockIcon setVisible:NO];
        }
        
        //update title
        [node.MissionName setString:[data objectForKey:@"name"]];
        
        //update description
        NSString *description2 = [data objectForKey:@"description2"];
        if (description2 == nil)
        {
            description2 = @"";
        }
        [node.DescriptionText setString:[NSString stringWithFormat:@"%@ %d %@", [data objectForKey:@"description1"], [[data objectForKey:@"number"] intValue], description2]];
        
        //percentage of how much you have finished (for life type)
        float percentage = [[AchievementManager shared] getFinishPercentageWithType:[data objectForKey:@"type"] target:[[data objectForKey:@"number"] floatValue]];

        [node.Bar setScaleY:percentage];
    }

    [availableAchievement release];
    [self drawlockedItemSpriteWithGroupID:groupID];
}

- (void)dealloc
{
    [mission0 release];
    [mission1 release];
    [mission2 release];
    [mission3 release];
    
    [missionArray release];
    [unlockItemName release];
    [unlockItemSprite release];
    [unlockedItemSprite release];
    [unlockBG release];
    [unlockedBG release];
    [unlockItemDescription release];
    [starNumLabel release];
    [multiplierIconNum release];
    
    [super dealloc];
}
@end

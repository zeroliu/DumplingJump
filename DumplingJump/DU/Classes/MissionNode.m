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
#import "StarRewardData.h"

@implementation MissionNode
@synthesize missionArray = _missionArray;
@synthesize TransitionAnim = transitionAnim;

-(void)didLoadFromCCB
{
    self.missionArray = [NSArray arrayWithObjects:mission0, mission1, mission2, mission3, nil];
}

- (void) drawlockedItemSpriteWithGroupID:(int)groupID
{
//    NSDictionary *currentEquipment = [[EquipmentData shared] findEquipmentWithGroupID:groupID];
//    
//    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
//    CCSpriteFrame *unlockedItemframe = [cache spriteFrameByName:[NSString stringWithFormat:@"%@_shadow.png",[currentEquipment objectForKey:@"image"]]];
//    [unlockItemSprite setDisplayFrame:unlockedItemframe];
    
    if ([[AchievementData shared] hasUnlockedAllAchievementsByGroup:groupID] && [[USERDATA objectForKey:@"achievementGroup"] intValue] != groupID)
    {
        [unlockedBG setVisible:YES];
        [unlockBG setVisible:NO];
        [unlockItemSprite setVisible:NO];
        [unlockedItemSprite setVisible:YES];
        [multiplierIconNum setVisible:YES];
        [multiplierIconNum setString:[NSString stringWithFormat:@"%dx", groupID+1]];
        
        [unlockItemName setColor:ccc3(0, 0, 0)];
        [multiplierNumLabel setColor:ccc3(0, 0, 0)];
        [multiplierDescription setColor:ccc3(0, 0, 0)];
        [starNumLabel setColor:ccc3(0, 0, 0)];
        [smallStarIcon setColor:ccc3(0, 0, 0)];
    }
    else
    {
        [unlockedBG setVisible:NO];
        [unlockBG setVisible:YES];
        [unlockItemSprite setVisible:YES];
        [unlockedItemSprite setVisible:NO];
        [multiplierIconNum setVisible:NO];
    }
    
    [multiplierNumLabel setString:[NSString stringWithFormat:@"%d", groupID+1]];
    [starNumLabel setString:[NSString stringWithFormat:@"+%d", [[StarRewardData shared] loadRewardStarNumWithGroupID:groupID]]];
    
}

- (void) drawWithUnknown:(int)groupID
{
    for (int i=0; i<4; i++)
    {
        AchievementNode *node = [_missionArray objectAtIndex:i];
        
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
        AchievementNode *node = [_missionArray objectAtIndex:i];
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
//    [mission0 release];
//    [mission1 release];
//    [mission2 release];
//    [mission3 release];
//    
    [_missionArray release];
//    [unlockItemName release];
//    [unlockItemSprite release];
//    [unlockedItemSprite release];
//    [unlockBG release];
//    [unlockedBG release];
//    [unlockItemDescription release];
//    [starNumLabel release];
//    [multiplierIconNum release];
//    [transitionAnim release];
    
    [super dealloc];
}
@end

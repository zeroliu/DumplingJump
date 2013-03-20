//
//  MissionNode.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "MissionNode.h"
#import "AchievementData.h"
#import "Constants.h"
#import "UserData.h"

@implementation MissionNode
@synthesize missionArray;


-(void)didLoadFromCCB
{
    missionArray = [NSArray arrayWithObjects:mission0, mission1, mission2, mission3, nil];
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
    }
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
        [node.DescriptionText setString:[NSString stringWithFormat:@"%@ %d %@", [data objectForKey:@"description1"], [[data objectForKey:@"number"] intValue], [data objectForKey:@"description2"]]];
    }
    
    [availableAchievement release];
}
@end

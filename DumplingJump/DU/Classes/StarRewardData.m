//
//  StarRewardData.m
//  CastleRider
//
//  Created by zero.liu on 4/15/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "StarRewardData.h"

@interface StarRewardData()
@property (nonatomic, retain) NSDictionary *rewardData;
@end


@implementation StarRewardData
@synthesize rewardData = _rewardData;

- (void)dealloc
{
    [_rewardData release];
    [super dealloc];
}

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[StarRewardData alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self loadStarRewardDataFromPlist];
    }
    
    return self;
}

-(void)loadStarRewardDataFromPlist
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"achievementUnlockStarReward.plist"];
    self.rewardData = [NSDictionary dictionaryWithContentsOfFile:path];
}

-(int) loadRewardStarNumWithGroupID:(int) groupID;
{
    return [[_rewardData objectForKey:[NSString stringWithFormat:@"group%d", groupID]] intValue];
}

@end

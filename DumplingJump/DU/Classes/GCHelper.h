//
//  GCHelper.h
//  CastleRider
//
//  Created by zero.liu on 5/13/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (nonatomic, readonly) BOOL gameCenterAvailable;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSString *currentLB;

+ (GCHelper *) sharedInstance;
- (void) authenticateLocalUser;
- (void) reportScore: (int64_t)score forLeaderboardID: (NSString *) category;
@end

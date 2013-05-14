//
//  GCHelper.m
//  CastleRider
//
//  Created by zero.liu on 5/13/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize categories = _categories;
@synthesize titles = _titles;
@synthesize currentLB = _currentLB;

- (void)dealloc
{
    self.currentLB = nil;
    [self.categories release];
    self.categories = nil;
    [self.titles release];
    self.titles = nil;
    [super dealloc];
}

#pragma mark - Initialization

+ (GCHelper *) sharedInstance
{
    static GCHelper *sharedHelper = nil;
    if (!sharedHelper)
    {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL) isGameCenterAvailable
{
    //Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //Check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id) init
{
    if (self = [super init])
    {
        gameCenterAvailable = [self isGameCenterAvailable];
        
        if (gameCenterAvailable)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
            self.currentLB = @"edu.cmu.etc.CastleRider.distanceLB";
        }
    }
    
    return self;
}

- (void) authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
    {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = YES;
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = NO;
    }
}

- (void) loadLeaderboardInfo
{
    [GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error) {
        self.categories = categories;
        self.titles = titles;
    }];
}

- (void) reportScore: (int64_t)score forLeaderboardID: (NSString *) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        
    }];
}

#pragma mark - User functions
- (void) authenticateLocalUser
{
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    }
    else
    {
        NSLog(@"Already authenticated!");
    }
}

@end

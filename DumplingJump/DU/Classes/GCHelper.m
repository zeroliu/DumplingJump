//
//  GCHelper.m
//  CastleRider
//
//  Created by zero.liu on 5/13/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "GCHelper.h"
#import "HighscoreLineManager.h"
#import "Constants.h"
#import "UserData.h"

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize categories = _categories;
@synthesize titles = _titles;
@synthesize currentLB = _currentLB;
@synthesize highDistances = _highDistances;
@synthesize playerID2Alias = _playerID2Alias;
@synthesize localplayerID = _localplayerID;
@synthesize forceReload = _forceReload;

- (void)dealloc
{
    self.currentLB = nil;
    self.categories = nil;
    self.titles = nil;
    self.highDistances = nil;
    self.playerID2Alias = nil;
    self.localplayerID = nil;
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
        
        self.forceReload = NO;
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

- (void) retrieveScores
{
    //Check date
    int lastTime = [[USERDATA objectForKey:@"scoreRetrieveTime"] intValue];
    int currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
    
    //Only retrieve score every 20 minutes
    if (self.forceReload || (currentTime - lastTime > 60 * 20))
    {
        self.forceReload = NO;
        
        //Remove highscore manager observers
        [[HighscoreLineManager shared] removeObservers];
        
        [USERDATA setObject:[NSNumber numberWithInt:currentTime] forKey:@"scoreRetrieveTime"];
    
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
        if (leaderboardRequest != nil)
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeWeek;
            leaderboardRequest.range = NSMakeRange(1,50);
            
            [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error)
            {
                NSMutableArray *playerIDs = [NSMutableArray arrayWithCapacity:50];
                if (self.playerID2Alias != nil)
                {
                    [self.playerID2Alias release];
                    _playerID2Alias = nil;
                }
                
                self.playerID2Alias = [NSMutableDictionary dictionaryWithCapacity:50];
                
                if (error != nil)
                {
                    NSLog(@"leaderboard request error: %@", error);
                }
                if (scores != nil)
                {
                    if (self.highDistances != nil)
                    {
                        [self.highDistances release];
                        self.highDistances = nil;
                    }
                    self.highDistances = scores;
                    
                    for (GKScore *score in scores)
                    {
                        [playerIDs addObject:score.playerID];
                    }
                }
                
                [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
                    if (players != nil)
                    {
                        for (GKPlayer *player in players)
                        {
                            [self.playerID2Alias setObject:player.alias forKey:player.playerID];
                        }
                        
                        
                        
                        //Register highscore to manager
                        for (GKScore *score in scores)
                        {
                            if (![score.playerID isEqualToString: [GKLocalPlayer localPlayer].playerID] && score.value > 30)
                            {
                                [[HighscoreLineManager shared] registerHighDistance:score.value playerID:score.playerID nickName:[self.playerID2Alias objectForKey:score.playerID]];
                            }
                        }
                    }
                }];
            }];
        }
        
        if ([[USERDATA objectForKey:@"highdistance"] intValue] > 30)
        {
            //Register local player highscore to manager
            [[HighscoreLineManager shared] registerHighDistance:[[USERDATA objectForKey:@"highdistance"] intValue] playerID:[GKLocalPlayer localPlayer].playerID nickName:@"Your BEST"];
        }
    }
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

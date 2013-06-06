#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BoardManager.h"
#import "HeroManager.h"
#import "StarManager.h"
#import "InterReactionManager.h"
#import "AchievementData.h"
#import "AddthingFactory.h"
#import "AchievementManager.h"
#import "AddthingTestTool.h"
#import "HeroTestTool.h"
#import "LevelTestTool.h"
#import "ParamConfigTool.h"
#import "GameUI.h"
#import "AchievementUnlockUI.h"
#import "DeadUI.h"
#import "GamespeedTestTool.h"
#import "BackgroundManager.h"
#import "CameraEffects.h"
#import "Hero.h"
#import "GCHelper.h"
#import "HighscoreLineManager.h"
#import "TutorialUI.h"
#import "TutorialManager.h"

@interface GameLayer()
{
    CCNode *_loadingPlaceHolder;
    BOOL _loadCompleted;
}
@end

@implementation GameLayer
@synthesize model = _model;
//@synthesize bgController = _bgController;
//@synthesize heroManager = _heroManager;

@synthesize batchNode = _batchNode;
@synthesize isDebug = _isDebug;
@synthesize timeScale = _timeScale;

-(void) onEnter
{
    [super onEnter];
    DLog(@"GameLayer scene onEnter");
}

-(void) onExit
{
    [super onExit];
    [[DUObjectsDictionary sharedDictionary] cleanDictionary];
    DLog(@"GameLayer scene onExit");
}

+(CCScene *) scene
{
//	autorelease object.
	CCScene *scene = [CCScene node];
	
//	autorelease object.
	GameLayer *gamelayer = [GameLayer node];
    gamelayer.tag = GAMELAYER_TAG;
	[scene addChild: gamelayer z:1];
	return scene;
}

#pragma mark - 
#pragma mark Lazy Init
-(GameModel *) getGameMode
{
    return self.model;
}
-(id) model
{
    if (_model == nil) _model = [[GameModel alloc] init];
    return _model;
}

#pragma mark - 
#pragma mark Initialization
-(id) init
{
	if( (self=[super init]))
    {
        //Set debug mode
        _isDebug = YES;
        _loadCompleted = NO;
        _timeScale = 1;
        
        //[[XMLHelper shared] loadParagraphFromFolder:@"xmls"];
        
        //Initialize Hub
        [[Hub shared] setGameLayer:self];
        
		// enable touches
		self.isTouchEnabled = YES;
        
        self.model.state = GAME_INIT;
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self cleanScreen];
        //Show loading text
        [self setLoadingScreen];
        
        //Loading in the background
        dispatch_queue_t loadingQueue = dispatch_queue_create("loadingQueue", NULL);
        dispatch_async(loadingQueue, ^
        {
            [self initBatchNode];
            [self loadBackendData];
            [self loadUserData];
            [self initGameParam];
            [self preloadMusic];
            //Load the draw related content on main thread
            [self performSelectorOnMainThread:@selector(loadFrontendData) withObject:self waitUntilDone:YES];
        });
        
	}
	return self;
}

-(void) setLoadingScreen
{
    CCMenuItemFont *loadingText = [CCMenuItemFont itemWithString:@"loading..."];
    [loadingText setFontName:@"Eras Bold ITC"];
    [loadingText setFontSize:20];
    loadingText.position = CGPointZero;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    _loadingPlaceHolder = [[CCNode alloc] init];
    _loadingPlaceHolder.position = CGPointZero;
    [self addChild:_loadingPlaceHolder];
    
    loadingText.anchorPoint = ccp(1,0.5);
    loadingText.position = ccp(winSize.width, 20);
    
    CCSprite *heroSprite = [CCSprite spriteWithSpriteFrameName:@"H_hero_1.png"];
    heroSprite.anchorPoint = ccp(1,0.5);
    heroSprite.position = ccp(winSize.width - loadingText.boundingBox.size.width, 25);
    
    //Build loading text animation
    //Manually create the animation because the animation manager and the plist data
    //has not being loaded yet
    NSMutableArray *frameArrayHero = [NSMutableArray array];
    for (int i=1; i<=12; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"H_hero_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArrayHero addObject:frameObject];
    }
    
    id heroAnim = [CCAnimation animationWithSpriteFrames :frameArrayHero delay:0.12];
    
    if (heroAnim != nil)
    {
        id heroAnimate = [CCAnimate actionWithAnimation:heroAnim];
        [heroSprite stopAllActions];
        [heroSprite runAction:[CCRepeatForever actionWithAction:heroAnimate]];
    }
    
    [_loadingPlaceHolder addChild:loadingText z:1];
    [_loadingPlaceHolder addChild:heroSprite z:1];
    
     
}

-(void) cleanScreen
{
    [self removeAllChildrenWithCleanup:NO];
}

-(void) initDebugTool
{
    //[[AddthingTestTool shared] reset];
    //[[HeroTestTool shared] reset];
    
    NSDictionary *debugData = [[WorldData shared] loadDataWithAttributName:@"debug"];
    if ([[debugData objectForKey:@"levelEditorEnabled"] boolValue])
    {
        [[LevelTestTool shared] setEnable:YES];
        [[LevelTestTool shared] reload];
    }
    if ([[debugData objectForKey:@"gameSpeedEditorEnabled"] boolValue])
    {
        [[GamespeedTestTool shared] setEnable:YES];
        [[GamespeedTestTool shared] reset];
    }
    //[[ParamConfigTool shared] reset];
    
    world = [[PhysicsManager sharedPhysicsManager] getWorld];
    
    if ([[[[WorldData shared] loadDataWithAttributName:@"debug"] objectForKey:@"physicsDebug"] boolValue])
    {
        m_debugDraw = new GLESDebugDraw(RATIO);
        world->SetDebugDraw(m_debugDraw);
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        flags += b2Draw::e_jointBit;
        flags += b2Draw::e_aabbBit;
        flags += b2Draw::e_pairBit;
        flags += b2Draw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
    }
}

-(void) initBatchNode
{
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png" capacity:50];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetTutorial.plist"];
    
    [self addChild:self.batchNode z:Z_BATCHNODE];
}

-(void) initGameParam
{
    self.model.star = 0;
    self.model.distance = 0;
}

-(void) initUI
{
    [[GameUI shared] createUI];
    [[GameUI shared] updateStar:0];
    [[GameUI shared] updateDistance:0];
    
    if ([[TutorialManager shared] isInTutorial])
    {
        [[TutorialUI shared] createUI];
    }
}

-(void) loadBackendData
{
    [XMLHelper shared];
    [AnimationManager shared];
    [ReactionManager shared];
    [EffectManager shared];
    [LevelManager shared];
    [WorldData shared];
    [HeroManager shared];
    [BoardManager shared];
    [StarManager shared];
    [InterReactionManager shared];
    [AchievementData shared];
    
    [self registerAchievementNotification];
}

-(void) preloadMusic
{
    [[AudioManager shared] preloadBackgroundMusic:@"Music_MainMenu.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_hero_jump.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_arrowHit.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_barrelHit.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_blindBat.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_clawHit.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_crateCountdown.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_crateExplode.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_crateHit.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_addthing_iceHit.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_powerup_springBounce.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_powerup_springJump.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_powerup_starCollect.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_powerup_swordFlame.mp3"];
    [[AudioManager shared] preloadSFX:@"sfx_UI_menuButton.mp3"];
}

-(void) loadFrontendData
{
    [[BackgroundManager shared] addBackgroundToLayer];
    [[BackgroundManager shared] reset];
    [self initUI];
    [self initGame];
    if (_isDebug)
    {
        [self initDebugTool];
    }
    
    [self scheduleUpdate];
    [self startGame];
    if (_loadingPlaceHolder != nil)
    {
        [_loadingPlaceHolder removeAllChildrenWithCleanup:NO];
        [_loadingPlaceHolder removeFromParentAndCleanup:NO];
        [_loadingPlaceHolder release];
        _loadingPlaceHolder = nil;
    }
    [[GameUI shared] fadeOut];
    [[GameUI shared] setButtonsEnabled:YES];
    _loadCompleted = YES;
}

-(void) loadUserData
{
    [self.model loadPowerUpLevelsData];
}

-(void) initGame
{
    //Init level with level name
    [self setLevelWithName:LEVEL_NORMAL];
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [[LevelManager shared] selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
//    [[BackgroundController shared] setBackgroundWithName:self.model.currentLevel.backgroundName];
    [[BoardManager shared] createBoardWithSpriteName:MAZE_BOARD position:ccp(160,150*SCALE_MULTIPLIER)];
    [self generateHero];
}

-(void) generateHero
{
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
}

-(void) update:(ccTime)deltaTime
{
    if (self.model.state == GAME_START)
    {
        self.model.gameTime += deltaTime;
        
        [[BackgroundManager shared] updateBackgroundObjectPosition:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [[HeroManager shared] updateHeroPosition];
        [[[HeroManager shared] getHero] updateHeroChildrenPosition];
        [[[HeroManager shared] getHero] updateHeroBoosterEffect];
        [[[HeroManager shared] getHero] updateJumpState];
        
        if (![[TutorialManager shared] isInGameTutorial])
        {
            [[BackgroundManager shared] updateBackgroundPosition:deltaTime];
            
            //Calculate distance increase
            float distanceIncrease = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"scoreUnit"] floatValue] * 10;
            
            //Update distance value
            self.model.distance += distanceIncrease;
        
            //Post highdistance signal
            [MESSAGECENTER postNotificationName:[NSString stringWithFormat:@"highdistance:%d",(int)self.model.distance] object:self];
            
            //Post distance achievement signal
            [MESSAGECENTER postNotificationName:NOTIFICATION_DISTANCE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.model.distance] forKey:@"num"]];
            
            //Increase life distance
            float currentLifeDistance = [[USERDATA objectForKey:@"totalDistance"] floatValue];
            [USERDATA setObject:[NSNumber numberWithFloat:currentLifeDistance+distanceIncrease] forKey: @"totalDistance"];
            [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_DISTANCE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[[USERDATA objectForKey:@"totalDistance"] floatValue]] forKey:@"num"]];
            
            //Show distance sign if needed
            int distance = (int)self.model.distance;
            if (distance>0 && distance % 250 == 0)
            {
                [[GameUI shared] updateDistanceSign:distance];
                
                //Hacky way for avoiding the sign showing up multiple times
                self.model.distance = self.model.distance + 1;
            }
            
            //Update distance text on game UI
            [[GameUI shared] updateDistance:(int)(self.model.distance)];
            
            //Post score achievement notification
            [MESSAGECENTER postNotificationName:NOTIFICATION_SCORE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)(self.model.distance*self.model.multiplier)] forKey:@"num"]];
            
            [[LevelManager shared] dropNextAddthing];
        }
        
        [[LevelManager shared] updateWarningSign];
        [[LevelManager shared] updatePowderCountdown:deltaTime];
        [[CCDirector sharedDirector].scheduler setTimeScale:_timeScale];
        [[GamespeedTestTool shared] updateUI];
        
        [[CameraEffects shared] updateCameraEffect:deltaTime];
    }
}

-(void) startGame
{
    self.model.state = GAME_START;
    
    if ([[TutorialManager shared] isInTutorial])
    {
        [[TutorialManager shared] resetTutorial];
        [[TutorialManager shared] performSelector:@selector(startBombTutorial) withObject:nil afterDelay:1];
    }
    else
    {
        //Increase life game count
        int currentGameNum = [[USERDATA objectForKey:@"totalGame"] intValue];
        [USERDATA setObject:[NSNumber numberWithInt:currentGameNum+1] forKey: @"totalGame"];
        [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_GAME object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[[USERDATA objectForKey:@"totalGame"] intValue]] forKey:@"num"]];
        
        if ([[USERDATA objectForKey:@"headstart"] intValue] >= 0)
        {
            int currentStar = [[USERDATA objectForKey:@"star"] intValue];
            if (currentStar > [[[HeroManager shared] getHero] getHeadstartCost])
            {
                [[GameUI shared] showHeadstartButton];
            }
        }

        [[GCHelper sharedInstance] retrieveScores];
    }
    [[LevelManager shared] loadCurrentParagraph];
    [[AudioManager shared] setBackgroundMusicVolume:1];
    [[AudioManager shared] playBackgroundMusic:@"Music_MainMenu.mp3" loop:YES];
    [self.model resetGameData];
    
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([[[HeroManager shared] getHero] isFreezing])
    {
        //If hero is freezing, tap means break the ice
        [[[HeroManager shared] getHero] tapOnIce];
    }
    else
    {
        //If hero is normal, tap means jump
        [[[HeroManager shared] getHero] jump];
    }
}

-(void) gameOver
{
    //Clear warning sign
    [[LevelManager shared] restart];
    
    //Clean object dictionary
    [[DUObjectsDictionary sharedDictionary] cleanDictionary];
    
    //Clean particles
    [[DUParticleManager shared] cleanParticlesInGame];
    
    //Check power-ups level achievement
    int minLevel = [[USERDATA objectForKey:@"BOOSTER"] intValue];
    minLevel = MIN(minLevel, [[USERDATA objectForKey:@"SPRING"] intValue]);
    minLevel = MIN(minLevel, [[USERDATA objectForKey:@"MAGIC"] intValue]);
    [MESSAGECENTER postNotificationName:NOTIFICATION_POWERUP_LEVEL object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:minLevel] forKey:@"num"]];
    
    //Check skills level achievement
    minLevel = [[USERDATA objectForKey:@"SHELTER"] intValue];
    minLevel = MIN(minLevel, [[USERDATA objectForKey:@"MAGNET"] intValue]);
    [MESSAGECENTER postNotificationName:NOTIFICATION_SKILL_LEVEL object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:minLevel] forKey:@"num"]];
    
    [MESSAGECENTER postNotificationName:NOTIFICATION_DIE_TIME object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:self.model.gameTime] forKey:@"num"]];
    
    //Increase life die count
    int currentDieNum = [[USERDATA objectForKey:@"die"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentDieNum+1] forKey: @"die"];
    [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_DIE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[[USERDATA objectForKey:@"die"] intValue]] forKey:@"num"]];
    
    [[AudioManager shared] setBackgroundMusicVolume:0.2];
    [self pauseGame];
    
    self.model.isHighScore = [self isHighScore]; //WARNING! isHighScore method must be called before updateGame Data
    [self updateGameData];
    [[UserData shared] saveUserData];
    
    if ([[[AchievementManager shared] getUnlockedEvents] count] > 0)
    {
        [[AchievementUnlockUI shared] createUI];
    }
    else
    {
        [self showDeadUI];
    }
    
    [[GameUI shared] setButtonsEnabled:NO];
    
}

- (void) showDeadUI
{
    int multiplier = [[USERDATA objectForKey:@"multiplier"] intValue];
    [[DeadUI shared] createUI];
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    
    if ([[TutorialManager shared] isInTutorial])
    {
        //Check if need to run store tutorial
        //hardcode 100 for the price to unlock the first item booster
        //if booster has not been unlocked and player has enough money
        if (currentStar >= 100 && [[USERDATA objectForKey:@"BOOSTER"] intValue] < 0)
        {
            [[TutorialManager shared] startStoreTutorialPartOne];
        }
        else
        {
            [USERDATA setObject:@0 forKey:@"tutorial"];
        }
    }
 
    [[DeadUI shared] updateUIDataWithScore:(int)(self.model.distance*multiplier) Star:self.model.star TotalStar:currentStar Distance:self.model.distance Multiplier:multiplier IsHighScore:self.model.isHighScore];
    
    [[DeadUI shared] updateNextMission:[[AchievementData shared] getNextMission:[[USERDATA objectForKey:@"achievementGroup"] intValue]]];
}

-(BOOL) isHighScore
{
    int currentHighscore = [[USERDATA objectForKey:@"highscore"] intValue];
    int myScore = (int)(self.model.distance*self.model.multiplier);
    return (myScore > currentHighscore);
}

-(void) updateGameData
{
    int currentHighscore = [[USERDATA objectForKey:@"highscore"] intValue];
    int myScore = (int)(self.model.distance*self.model.multiplier);
    if (myScore > currentHighscore)
    {
        [USERDATA setObject:[NSNumber numberWithInt:myScore] forKey:@"highscore"];
    }
    
    int currentHighDistance = [[USERDATA objectForKey:@"highdistance"] intValue];
    int myDistance = (int)(self.model.distance);
    if (myDistance > currentHighDistance)
    {
        [GCHelper sharedInstance].forceReload = YES;
        [USERDATA setObject:[NSNumber numberWithInt:myDistance] forKey:@"highdistance"];
    }
}

-(void) restart
{
    //Reset batch node position
    self.batchNode.position = CGPointZero;
    
    //Clear all unlocked
    [[AchievementManager shared] removeAllUnlockedEvent];
    
    //Re-register available achievement
    [self registerAchievementNotification];
    
    //Reload powerup data
    [self.model loadPowerUpLevelsData];
    
    //Clean object dictionary
    [[DUObjectsDictionary sharedDictionary] cleanDictionary];
    
    //Clean particles
    [[DUParticleManager shared] cleanParticlesInGame];
    
    //Clean all the actions in the gamelayer
    [self stopAllActions];
    
    //Reset gameUI
    [[GameUI shared] resetUI];
    
    //Reset gameData
    [self.model resetGameData];
    
    //Reset star
    [[GameUI shared] updateStar:self.model.star];
    
    //Restart levelManger
    [[LevelManager shared] restart];
    
    //Reset Hero
    [self generateHero];
    
    //Reset Board
    [[BoardManager shared] createBoardWithSpriteName:MAZE_BOARD position:ccp(160,150*SCALE_MULTIPLIER)];
    
    //Reset game frame
    [[CCDirector sharedDirector].scheduler setTimeScale:1.0];
    
    //Show Fade out animation
    [[GameUI shared] fadeOut];
    
    //Reset game speed
    [self.model resetGameSpeed];
    
    //Reset background
    [[BackgroundManager shared] reset];
    
    //Reset buttons in Game UI in case they got unlocked
    [[GameUI shared] refreshButtons];
    
    //Reset Line manager
    [[HighscoreLineManager shared] reset];
    
    //Resume game
    [self resumeGame];
    
    //Start
    [self startGame];
}

-(void) pauseGame
{
    [self pauseSchedulerAndActions];
    [BATCHNODE pauseSchedulerAndActions];
    CCNode *child;
    CCARRAY_FOREACH([BATCHNODE children], child)
    {
        [child pauseSchedulerAndActions];
    }
    [[GameUI shared] pauseUI];
}

-(void) resumeGame
{
    CCNode *child;
    CCARRAY_FOREACH([BATCHNODE children], child)
    {
        [child resumeSchedulerAndActions];
    }
    [self resumeSchedulerAndActions];
    [BATCHNODE resumeSchedulerAndActions];
    [[GameUI shared] resumeUI];
    [[GameUI shared] setButtonsEnabled:YES];
}

-(void) registerAchievementNotification
{
    [[AchievementManager shared] removeAllNotification];
    
    //Search for the available achievements
    NSArray *availableAchievement = [[[AchievementData shared] getAvailableAchievementsByGroupID:[[USERDATA objectForKey:@"achievementGroup"] intValue]] retain];
    
    for (NSDictionary *achievementData in availableAchievement)
    {
        [[AchievementManager shared] registerAchievement:achievementData];
    }
    
    [availableAchievement release];
}

-(void) draw
{
    if ([[[[WorldData shared] loadDataWithAttributName:@"debug"] objectForKey:@"physicsDebug"] boolValue])
    {
        if (_loadCompleted)
        {
            [super draw];
            ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
            
            kmGLPushMatrix();
            
            world->DrawDebugData();
            
            kmGLPopMatrix();
        }
    }
}

#pragma mark -
#pragma mark ListenerHandlers


#pragma mark -
#pragma mark Dealloc
- (void) dealloc
{
    [_model release];
    [_batchNode release];
	[super dealloc];
}
@end
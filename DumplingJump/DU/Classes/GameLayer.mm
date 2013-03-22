#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
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
            [[LevelManager shared] destroyAllObjects];
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
//    CCMenuItemFont *loadingText = [CCMenuItemFont itemWithString:@"loading..."];
//    loadingText.position = CGPointZero;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    _loadingPlaceHolder = [[CCNode alloc] init];
    _loadingPlaceHolder.position = CGPointZero;
    [self addChild:_loadingPlaceHolder];
    
    CCSprite *loadingText = [CCSprite spriteWithSpriteFrameName:@"UI_other_loading_1.png"];
    loadingText.anchorPoint = ccp(1,0.5);
    loadingText.position = ccp(winSize.width, 20);
    loadingText.scale = 1.5f;

    //Build loading text animation
    //Manually create the animation because the animation manager and the plist data
    //has not being loaded yet
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=4; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"UI_other_loading_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id loadingTextAnim = [CCAnimation animationWithSpriteFrames :frameArray delay:0.12];
    
    if (loadingTextAnim != nil)
    {
        id loadingTextAnimate = [CCAnimate actionWithAnimation:loadingTextAnim];
        [loadingText stopAllActions];
        [loadingText runAction:[CCRepeatForever actionWithAction:loadingTextAnimate]];
    }
    
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
    [[LevelTestTool shared] reload];
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
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
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
    [[GameUI shared] updateScore:0];
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
    [[AudioManager shared] preloadBackgroundMusic:@"Music_Game.mp3"];
}

-(void) loadFrontendData
{
    [[BackgroundController shared] initParam];
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
    [[BackgroundController shared] setBackgroundWithName:self.model.currentLevel.backgroundName];
    [[BoardManager shared] createBoardWithSpriteName:self.model.currentLevel.boardType position:ccp(160,150*SCALE_MULTIPLIER)];
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
        [[BackgroundController shared] updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [[HeroManager shared] updateHeroPosition];
        [[[HeroManager shared] getHero] updateHeroChildrenPosition];
        [[[HeroManager shared] getHero] updateHeroBoosterEffect];
        [[[HeroManager shared] getHero] updateJumpState];
        
        float distanceIncrease = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"distanceUnit"] floatValue] * 10;
        self.model.distance += distanceIncrease;
        
        [MESSAGECENTER postNotificationName:NOTIFICATION_DISTANCE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.model.distance] forKey:@"num"]];
        //Increase life distance
        float currentLifeDistance = [[USERDATA objectForKey:@"totalDistance"] floatValue];
        [USERDATA setObject:[NSNumber numberWithFloat:currentLifeDistance+distanceIncrease] forKey: @"totalDistance"];
        [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_DISTANCE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[[USERDATA objectForKey:@"totalDistance"] floatValue]] forKey:@"num"]];
        
        [[GameUI shared] updateDistanceSign:(int)self.model.distance];
        [[GameUI shared] updateScore:(int)(self.model.distance*self.model.multiplier)];
        [MESSAGECENTER postNotificationName:NOTIFICATION_SCORE object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)(self.model.distance*self.model.multiplier)] forKey:@"num"]];
        [[LevelManager shared] dropNextAddthing];
        [[LevelManager shared] updateWarningSign];
        [[LevelManager shared] updatePowderCountdown:deltaTime];
        [[CCDirector sharedDirector].scheduler setTimeScale:_timeScale];
    }
}

-(void) startGame
{
    //Increase life game count
    int currentGameNum = [[USERDATA objectForKey:@"totalGame"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentGameNum+1] forKey: @"totalGame"];
    [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_GAME object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[[USERDATA objectForKey:@"totalGame"] intValue]] forKey:@"num"]];
    
    self.model.state = GAME_START;
    [[LevelManager shared] loadCurrentParagraph];
    [[AudioManager shared] setBackgroundMusicVolume:1];
    [[AudioManager shared] playBackgroundMusic:@"Music_Game.mp3" loop:YES];
    
    int headStartCount = [[USERDATA objectForKey:@"headstart"] intValue];
    if (headStartCount > 0)
    {
        [USERDATA setObject:[NSNumber numberWithInt:headStartCount -1] forKey:@"headstart"];
        [[[HeroManager shared] getHero] headStart];
        [[[BoardManager shared] getBoard] hideBoard];
    }
    [self.model resetGameData];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [[[HeroManager shared] getHero] jump];
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
    [[DeadUI shared] createUI];
    [[DeadUI shared] updateUIDataWithScore:(int)(self.model.distance*self.model.multiplier) Star:self.model.star TotalStar:[[USERDATA objectForKey:@"star"] intValue] Distance:self.model.distance Multiplier:self.model.multiplier IsHighScore:self.model.isHighScore];
}

-(BOOL) isHighScore
{
    int currentHighscore = [[USERDATA objectForKey:@"highscore"] intValue];
    int myScore = (int)(self.model.distance*self.model.multiplier);
    return (myScore > currentHighscore);
}

-(void) updateGameData
{
    int currentStar = [[USERDATA objectForKey:@"star"] intValue];
    [USERDATA setObject:[NSNumber numberWithInt:currentStar + self.model.star] forKey:@"star"];
    int currentHighscore = [[USERDATA objectForKey:@"highscore"] intValue];
    int myScore = (int)(self.model.distance*self.model.multiplier);
    if (myScore > currentHighscore)
    {
        [USERDATA setObject:[NSNumber numberWithInt:myScore] forKey:@"highscore"];
    }
}

-(void) restart
{
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
    //[[BoardManager shared] createBoardWithSpriteName:MAZE_BOARD position:ccp(160,150*SCALE_MULTIPLIER)];
    [[BoardManager shared] createBoardWithSpriteName:MAZE_BOARD position:ccp(160,150*SCALE_MULTIPLIER)];
    
    //Reset game frame
    [[CCDirector sharedDirector].scheduler setTimeScale:1.0];
    
    //Show Fade out animation
    [[GameUI shared] fadeOut];
    
    //Reset game speed
    [self.model resetGameSpeed];
    
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
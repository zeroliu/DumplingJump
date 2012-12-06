#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
#import "BoardManager.h"
#import "HeroManager.h"
#import "StarManager.h"
#import "AddthingFactory.h"

#import "AddthingTestTool.h"
#import "HeroTestTool.h"
#import "LevelTestTool.h"
#import "ParamConfigTool.h"
#import "GameUI.h"
#import "DeadUI.h"

@interface GameLayer()

@end

@implementation GameLayer
@synthesize model = _model;
//@synthesize bgController = _bgController;
//@synthesize heroManager = _heroManager;

@synthesize batchNode = _batchNode;
@synthesize isDebug = _isDebug;

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
	if( (self=[super init])) {
        //Set debug mode
        _isDebug = YES;
        
        //Initialize Hub
        [[Hub shared] setGameLayer:self];
        
		// enable touches
		self.isTouchEnabled = YES;
        
        self.model.state = GAME_INIT;
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self cleanScreen];
        [self initBatchNode];
        [self preloadGameData];
        [self loadUserData];
        [self initGameParam];
        [self initUI];
        [self initGame];
        
        if (_isDebug)
        {
            [self initDebugTool];
        }
        
        [self scheduleUpdate];
	}
	return self;
}

-(void) cleanScreen
{
    [self removeAllChildrenWithCleanup:NO];
}

-(void) initDebugTool
{
    //[[AddthingTestTool shared] reset];
    [[HeroTestTool shared] reset];
    [[LevelTestTool shared] reload];
    [[ParamConfigTool shared] reset];
    
    world = [[PhysicsManager sharedPhysicsManager] getWorld];
    
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

-(void) initBatchNode
{
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:self.batchNode z:10];
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
}

-(void) preloadGameData
{
    [XMLHelper shared];
    [AnimationManager shared];
    [ReactionManager shared];
    [EffectManager shared];
    [LevelManager shared];
    [HeroManager shared];
    [BoardManager shared];
    [StarManager shared];
    [[BackgroundController shared] initParam];
}

-(void) loadUserData
{
    [self.model loadPowerUpLevelsData];
}

-(void) initGame
{
    //Init level with level name
    [self setLevelWithName:LEVEL_NORMAL];
    //[[LevelManager shared] loadParagraphAtIndex:0];
    [self startGame];
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [[LevelManager shared] selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
    [[BackgroundController shared] setBackgroundWithName:self.model.currentLevel.backgroundName];
    [[BoardManager shared] createBoardWithSpriteName:self.model.currentLevel.boardType position:ccp(160,120*SCALE_MULTIPLIER)];
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
}

-(void) update:(ccTime)deltaTime
{
    if (self.model.state == GAME_START)
    {
        [[BackgroundController shared] updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [[HeroManager shared] updateHeroPosition];
        [[[HeroManager shared] getHero] updateHeroPowerupCountDown:deltaTime];
        self.model.distance += DISTANCE_UNIT * 10;
        [[GameUI shared] updateDistance:(int)self.model.distance];
        [[LevelManager shared] dropNextAddthing];
    }
}

-(void) startGame
{
    self.model.state = GAME_START;
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [[[HeroManager shared] getHero] jump];
}

-(void) gameOver
{
    [self pauseGame];
    [[DeadUI shared] createUI];
}

-(void) restart
{
    //Clean object dictionary
    [[DUObjectsDictionary sharedDictionary] cleanDictionary];
    
    //Reset score
    self.model.distance = 0;
    
    //Reset star
    self.model.star = 0;
    [[GameUI shared] updateStar:self.model.star];
    
    //Destroy all objects
    [[LevelManager shared] destroyAllObjects];
    
    //Reset Level
    [[LevelManager shared] stopCurrentParagraph];
    
    //Reset Hero
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
    
    //Reset Board
    [[BoardManager shared] createBoardWithSpriteName:MAZE_BOARD position:ccp(160,120*SCALE_MULTIPLIER)];
    
    //Show Fade out animation
    [[GameUI shared] fadeOut];
    
    //if isDebug, restart currentLevel
    [[LevelManager shared] loadCurrentParagraph];
    
    //Resume game
    [self resumeGame];
}

-(void) pauseGame
{
    [self pauseSchedulerAndActions];
    [BATCHNODE pauseSchedulerAndActions];
    //self.batchNode.isRunning = NO;
    CCNode *child;
    CCARRAY_FOREACH([BATCHNODE children], child)
    {
        [child pauseSchedulerAndActions];
    }
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
}

-(void) draw
{
    
    [super draw];
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();
    
}

#pragma mark -
#pragma mark ListenerHandlers


#pragma mark -
#pragma mark Dealloc
- (void) dealloc
{
    [self.batchNode release];
	[super dealloc];
}
@end
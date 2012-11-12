#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
#import "BoardManager.h"
#import "HeroManager.h"
#import "AddthingFactory.h"

#import "AddthingTestTool.h"
#import "HeroTestTool.h"
#import "LevelTestTool.h"
#import "ParamConfigTool.h"

@interface GameLayer()
{
    
}
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) BackgroundController *bgController;

@end

@implementation GameLayer
@synthesize model = _model;
@synthesize bgController = _bgController;
//@synthesize heroManager = _heroManager;

@synthesize batchNode = _batchNode;
-(void) onEnter
{
    [super onEnter];
    DLog(@"GameLayer scene onEnter");
    if (isReload)
    {
        DLog(@"is reload");
        
        [[LevelTestTool shared] reload];
    }
    isReload = false;
}

-(void) onExit
{
    [super onExit];
    DLog(@"GameLayer scene onExit");
    isReload = true;
    
    
}

+(CCScene *) scene
{
//	autorelease object.
	CCScene *scene = [CCScene node];
	
//	autorelease object.
	GameLayer *layer = [GameLayer node];

	[scene addChild: layer];
	
	return scene;
}

#pragma mark - 
#pragma mark Lazy Init

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
        //Initialize Hub
        [[Hub shared] setGameLayer:self];
        
		// enable touches
		self.isTouchEnabled = YES;
        
        self.model.state = GAME_INIT;
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self initBatchNode];
        [self preloadGameData];
        [self initManagers];
        [self initListener];
        [self initParameters];
        [self initGame];
        
        [self initDebugTool];
        
        [self scheduleUpdate];
	}
	return self;
}

-(void) initDebugTool
{
    [AddthingTestTool shared];
    [HeroTestTool shared];
    [LevelTestTool shared];
    [ParamConfigTool shared];
    
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

-(void) initManagers
{
    _bgController = [[BackgroundController alloc] init];
}

-(void) initListener
{
    //    [MESSAGECENTER addObserver:self selector:@selector(gameStart) name:GAMELAYER_INITIALIZED object:nil];
}

-(void) preloadGameData
{
    [AnimationManager shared];
    [ReactionManager shared];
    [EffectManager shared];
    [LevelManager shared];
    [HeroManager shared];
    [BoardManager shared];
    [XMLHelper shared];
}

-(void) initGame
{
    //Init level with level name
    [self setLevelWithName:LEVEL_NORMAL];
    //[[LevelManager shared] loadParagraphAtIndex:0];
    [self startGame];
}

-(void) initParameters
{
    
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [[LevelManager shared] selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
    [self.bgController setBackgroundWithName:self.model.currentLevel.backgroundName];
    [[BoardManager shared] createBoardWithSpriteName:self.model.currentLevel.boardType position:ccp(160,120*SCALE_MULTIPLIER)];
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
}

-(void) update:(ccTime)deltaTime
{
    if (self.model.state == GAME_START)
    {
        [self.bgController updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [[HeroManager shared] updateHeroPosition];
        [[[HeroManager shared] getHero] updateHeroPowerupCountDown:deltaTime];
        self.model.distance += DISTANCE_UNIT;
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

-(void) fire
{
    DUPhysicsObject *slash = [[LevelManager shared] dropAddthingWithName:@"SLASH" atPosition:ccp(((Hero *)[HEROMANAGER getHero]).sprite.position.x,((Hero *)[HEROMANAGER getHero]).sprite.position.y +5)];
    slash.body->SetLinearVelocity(b2Vec2(0,24));
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
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
#import "CCBReader.h"

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
}

-(void) onExit
{
    [super onExit];
    DLog(@"GameLayer scene onExit");
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
        [self initUILayer];
        
        [self initDebugTool];
        
        [self scheduleUpdate];
        
        paused = NO;
	}
	return self;
}

-(void) initUILayer
{
    CCNode *node = [CCBReader nodeGraphFromFile:@"GameUI.ccbi" owner:self];
    node.position = ccp(0,[[CCDirector sharedDirector] winSize].height - node.boundingBox.size.height);
    
    [self addChild:node z:Z_GAMEUI];
}

-(void) TestPause:(id)sender
{
    DLog(@"TestPause");
    if (!paused)
    {
        //[[CCDirector sharedDirector] stopAnimation];
        [[CCDirector sharedDirector] pause];
        paused = YES;
    } else
    {
        //[[CCDirector sharedDirector] stopAnimation];
        [[CCDirector sharedDirector] resume];
        //[[CCDirector sharedDirector] startAnimation];
        paused = NO;
    }
}

-(void) testItem1:(id)sender
{
    DLog(@"item1");
}
-(void) testItem2:(id)sender
{
    DLog(@"item2");
}
-(void) testItem3:(id)sender
{
    DLog(@"item3");
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
    [XMLHelper shared];
    [AnimationManager shared];
    [ReactionManager shared];
    [EffectManager shared];
    [LevelManager shared];
    [HeroManager shared];
    [BoardManager shared];
    [StarManager shared];
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
        self.model.distance += DISTANCE_UNIT * 10;
        [UI_scoreText setString:[NSString stringWithFormat:@"%d", (int)self.model.distance]];
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
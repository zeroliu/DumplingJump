#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
#import "BoardManager.h"
#import "HeroManager.h"
#import "AddthingFactory.h"

#import "AddthingTestTool.h"
#import "HeroTestTool.h"

@interface GameLayer()
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) BackgroundController *bgController;
@property (nonatomic, retain) BoardManager *boardManager;

@end

@implementation GameLayer
@synthesize model = _model;
@synthesize bgController = _bgController;
@synthesize boardManager = _boardManager;
//@synthesize heroManager = _heroManager;

@synthesize batchNode = _batchNode;

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
}

-(void) initBatchNode
{
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:self.batchNode z:10];
}

-(void) initManagers
{

    _boardManager = [[BoardManager alloc] init];
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
    [XMLHelper shared];
}

-(void) initGame
{
    //Init level with level name
    //TODO: select the level with a menu or something
    [self setLevelWithName:LEVEL_NORMAL];
    [[LevelManager shared] loadParagraphAtIndex:0];
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
    [self.boardManager createBoardWithSpriteName:self.model.currentLevel.boardType position:ccp(160,120)];
    [[HeroManager shared] createHeroWithPosition:ccp(150,200)];
    //TODO: set the rest of the characters or elements for the level
}

-(void) update:(ccTime)deltaTime
{
    if (self.model.state == GAME_START)
    {
        [self.bgController updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [[HeroManager shared] updateHeroPosition];
        self.model.distance += DISTANCE_UNIT;
        [[LevelManager shared] dropNextAddthing];
    }
}

-(void) startGame
{
    self.model.state = GAME_START;
//    DUPhysicsObject *tub = [self.addthingFactory createWithName:TUB];
//    tub.sprite.position = ccp(100,650);
//    [tub addChildTo:BATCHNODE];
//    
//    DUPhysicsObject *vat = [self.addthingFactory createWithName:VAT];
//    vat.sprite.position = ccp(200,650);
//    [vat addChildTo:BATCHNODE];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [[[HeroManager shared] getHero] jump];
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
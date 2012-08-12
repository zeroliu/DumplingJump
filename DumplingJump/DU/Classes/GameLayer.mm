#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
#import "BoardManager.h"
#import "HeroManager.h"

@interface GameLayer()
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) LevelManager *levelManager;
@property (nonatomic, retain) BackgroundController *bgController;
@property (nonatomic, retain) BoardManager *boardManager;
@property (nonatomic, retain) HeroManager *heroManager;

@end

@implementation GameLayer
@synthesize model = _model;
@synthesize levelManager = _levelManager;
@synthesize bgController = _bgController;
@synthesize boardManager = _boardManager;
@synthesize heroManager = _heroManager;


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

-(id) bgController
{
    if (_bgController == nil) _bgController = [[BackgroundController alloc] init];
    return _bgController;
}

-(id) boardManager
{
    if (_boardManager == nil) _boardManager = [[BoardManager alloc] init];
    return _boardManager;
}

-(id) levelManager
{
    if (_levelManager == nil) _levelManager = [[LevelManager alloc] init];
    return _levelManager;
}

-(id) heroManager
{
    if (_heroManager == nil) _heroManager = [[HeroManager alloc] init];
    return _heroManager;
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
			
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self initBatchNode];
        
        self.model.state = GAME_INIT;
        [self initListener];
        [self initGame];
        [self scheduleUpdate];
	}
	return self;
}

-(void) initBatchNode
{
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:self.batchNode z:10];
}

-(void) update:(ccTime)deltaTime
{
    if (self.model.state == GAME_START)
    {
        [self.bgController updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
        [self.heroManager updateHeroPosition];
    }
}

-(void) initListener
{
    //    [MESSAGECENTER addObserver:self selector:@selector(gameStart) name:GAMELAYER_INITIALIZED object:nil];
}

-(void) initGame
{
    //Init level with level name
    //TODO: select the level with a menu or something
    [self setLevelWithName:LEVEL_NORMAL];
    [self startGame];
}

-(void) startGame
{
    self.model.state = GAME_START;
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [self.levelManager selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
    [self.bgController setBackgroundWithName:self.model.currentLevel.backgroundName];
    [self.boardManager createBoardWithBoardName:self.model.currentLevel.boardType position:ccp(160,100)];
    [self.heroManager createHeroWithPosition:ccp(150,200)];
    //TODO: set the rest of the characters or elements for the level
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



//-(void) initListeners
//{
//    [MESSAGECENTER addObserver:self selector:@selector(updateDistanceText) name:DISTANCEUPDATED object:nil];
//}

//-(void) initUI
//{
//    label = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:20];
//    CGSize size = [[CCDirector sharedDirector] winSize];
//    label.position =  ccp( size.width - 20 , size.height - 20 );
//    [self addChild: label];
//}
//
//-(void)createBall:(CGPoint)point
//{
//    DUPhysicsObject *ball = [[TestBall shared] create];
//    [ball.sprite runAction: [ANIMATIONMANAGER getAnimationWithName:@"HeroIdle" repeat:0]];
//    ball.sprite.position = point;
//    [ball addChildTo:[[[Hub shared] gameLayer] batchNode]];
//}
//
//-(void) createNewBall
//{
//    CGPoint ballPos = ccp(randomInt(20, 300),650);
//    [self createBall:ballPos];
//}
//
//-(void)update:(ccTime)dt
//{
//    [bgManager updateBackground];
//    [PHYSICSMANAGER updatePhysicsBody:dt];
//    [hero updateHeroPosition];
//    [DUGAMEMANAGER update:dt];
//    [self updateUI];
//}

//
//-(void) updateUI
//{
//    [self updateDistanceText];
//}

//-(void) updateDistanceText
//{
//    [label setString:[NSString stringWithFormat: @"%d", (int)[SCOREMANAGER distance]]];
//}


//-(void) initHero
//{
////    hero = [[Hero alloc] initHeroWithFile:@"HERO/AL_H_hero_1.png" position:ccp(150,200)];
//    hero = [[Hero alloc] initHeroWithName:@"TrueHero" position:ccp(150,200)];
//    [hero addChildTo:self.batchNode z:10];
//}
//
//        [self initListeners];

//        [GAMEMANAGER init];
//        [MESSAGECENTER postNotificationName:GAMELAYER_INITIALIZED object:self]; 
//        
//        [self initHero];
//        [self initBackground];
//        [self initBoard];
//        
//        
//        
//        [self scheduleUpdate];

//        [self createNewBall];
//        
//        [[CCScheduler sharedScheduler] scheduleSelector:@selector(createNewBall) forTarget:self interval:0.02 paused:NO];
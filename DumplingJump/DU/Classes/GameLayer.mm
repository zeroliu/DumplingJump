#import "GameLayer.h"
#import "GameModel.h"
#import "LevelManager.h"
#import "BackgroundController.h"
#import "BoardManager.h"
#import "HeroManager.h"
#import "AddthingFactory.h"

@interface GameLayer()
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) LevelManager *levelManager;
@property (nonatomic, retain) BackgroundController *bgController;
@property (nonatomic, retain) BoardManager *boardManager;

@property (nonatomic, retain) AddthingFactory *addthingFactory;
@end

@implementation GameLayer
@synthesize model = _model;
@synthesize levelManager = _levelManager;
@synthesize bgController = _bgController;
@synthesize boardManager = _boardManager;
@synthesize heroManager = _heroManager;
@synthesize addthingFactory = _addthingFactory;

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
        [self initManagers];
        [self initListener];
        [self preloadGameData];
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

-(void) initManagers
{
    _heroManager = [[HeroManager alloc] init];
    _boardManager = [[BoardManager alloc] init];
    _levelManager = [[LevelManager alloc] init];
    _bgController = [[BackgroundController alloc] init];
    _addthingFactory = [[AddthingFactory alloc] initFactory];
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
}

-(void) initGame
{
    //Init level with level name
    //TODO: select the level with a menu or something
    [self setLevelWithName:LEVEL_NORMAL];
    [self startGame];
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [self.levelManager selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
    [self.bgController setBackgroundWithName:self.model.currentLevel.backgroundName];
    [self.boardManager createBoardWithSpriteName:self.model.currentLevel.boardType position:ccp(160,100)];
    [self.heroManager createHeroWithPosition:ccp(150,200)];
    //TODO: set the rest of the characters or elements for the level
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
    UITouch* touch = [touches anyObject];
    DUPhysicsObject *vat = [self.addthingFactory createWithName:STAR];
    vat.sprite.position = [self convertTouchToNodeSpace: touch];
    [vat addChildTo:BATCHNODE];
    //in your touchesEnded event, you would want to see if you touched
    //down and then up inside the same place, and do your logic there.
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
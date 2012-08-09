#import "GameLayer.h"
//#import "BackgroundManager.h"
//#import "Board.h"
//#import "Hero.h"
//
//#import "TestBall.h"

@implementation GameLayer
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
#pragma mark Initialization
-(id) init
{
	if( (self=[super init])) {
        //Initialize Hub
        [[Hub shared] setGameLayer:self];
        
        [self addChild:[GameManager shared]];
        
		// enable touches
		self.isTouchEnabled = YES;
			
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self initBatchNode];
        [self initUI];
        
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
	}
	return self;
}


//-(void) initListeners
//{
//    [MESSAGECENTER addObserver:self selector:@selector(updateDistanceText) name:DISTANCEUPDATED object:nil];
//}

-(void) initUI
{
    label = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:20];
    CGSize size = [[CCDirector sharedDirector] winSize];
    label.position =  ccp( size.width - 20 , size.height - 20 );
    [self addChild: label];
}

-(void) initBatchNode
{
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:self.batchNode z:10];
}



//-(void) initHero
//{
////    hero = [[Hero alloc] initHeroWithFile:@"HERO/AL_H_hero_1.png" position:ccp(150,200)];
//    hero = [[Hero alloc] initHeroWithName:@"TrueHero" position:ccp(150,200)];
//    [hero addChildTo:self.batchNode z:10];
//}
//

//
//-(void) initBoard
//{
//    board = [[Board alloc] initWithName:@"board"];
//    [board addChildTo:self.batchNode z:10];
//}

#pragma mark -
#pragma mark ListenerHandlers
//
//-(void) updateUI
//{
//    [self updateDistanceText];
//}

//-(void) updateDistanceText
//{
//    [label setString:[NSString stringWithFormat: @"%d", (int)[SCOREMANAGER distance]]];
//}

#pragma mark -
#pragma mark Dealloc
- (void) dealloc
{
//	[board release];
//    [bgManager release];
//    
//    [hero release];
    [self.batchNode release];
	[super dealloc];
}
@end

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


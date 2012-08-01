#import "GameLayer.h"
#import "BackgroundManager.h"
#import "Board.h"
#import "Hero.h"

#import "TestBall.h"

@implementation GameLayer
@synthesize batchNode;

+(CCScene *) scene
{
//	autorelease object.
	CCScene *scene = [CCScene node];
	
//	autorelease object.
	GameLayer *layer = [GameLayer node];

	[scene addChild: layer];
	
	return scene;
}

-(void)update:(ccTime)dt
{
    [bgManager updateBackground];
    [[PhysicsManager sharedPhysicsManager] updatePhysicsBody:dt];
    [hero updateHeroPosition];
//    NSLog(@"x=%g, y=%g, z=%g",[[AccelerometerManager shared] accX],[[AccelerometerManager shared] accY],[[AccelerometerManager shared] accZ]);
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
		
//		// enable accelerometer
//		self.isAccelerometerEnabled = YES;
		
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];        
        
        [self initBatchNode];
        
        [self initHero];
        [self initBackground];
        [self initBoard];
        
        [self scheduleUpdate];
        
        [self createNewBall];
//        //[self createNewBall];
        
        [[CCScheduler sharedScheduler] scheduleSelector:@selector(createNewBall) forTarget:self interval:0.02 paused:NO];
	}
	return self;
}

-(void)createBall:(CGPoint)point
{
    DUPhysicsObject *ball = [[TestBall shared] create];
    [ball.sprite runAction: [[AnimationManager shared] getAnimationWithName:@"HeroIdle" repeat:0]];
    ball.sprite.position = point;
    [ball addChildTo:[[[Hub shared] gameLayer] batchNode]];
}

-(void) createNewBall
{
    CGPoint ballPos = ccp(randomInt(20, 300),650);
    [self createBall:ballPos];
}

-(void) initBatchNode
{
    batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:batchNode z:10];
}

-(void) initHero
{
//    hero = [[Hero alloc] initHeroWithFile:@"HERO/AL_H_hero_1.png" position:ccp(150,200)];
    hero = [[Hero alloc] initHeroWithName:@"TrueHero" position:ccp(150,200)];
    [hero addChildTo:batchNode z:10];
}

-(void) initBackground
{
    bgManager = [[BackgroundManager alloc] initWithFile:@"sheetBackground1" bgLayers:
                 new BgLayer(1, 0, @"CA_background_1.png",-30),
                 new BgLayer(2, 1, @"CA_background_2.png"),
                 new BgLayer(3, 2, @"CA_background_3.png"),
                 new BgLayer(4, 3, @"CA_background_4.png"),
                 new BgLayer(5, 4, @"CA_background_5.png"),
                 nil
                 ];
}

-(void) initBoard
{
    board = [[Board alloc] initWithName:@"board"];
    [board addChildTo:batchNode z:10];
}

#pragma mark -
#pragma mark ListenerHandlers
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark -
#pragma mark Dealloc
- (void) dealloc
{
	[board release];
    [bgManager release];
    [batchNode release];
    [hero release];
	[super dealloc];
}
@end

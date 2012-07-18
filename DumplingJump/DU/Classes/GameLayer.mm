#import "GameLayer.h"
#import "BackgroundManager.h"
#import "BoardManager.h"
#import "Hero.h"

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
}

-(id) init
{
	if( (self=[super init])) {
        //Initialize Hub
        [[Hub shared] setGameLayer:self];
        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
        [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
        
        
        [self initBatchNode];
        
        [self initHero];
        [self initBackground];
        [self initBoard];
        
        [self scheduleUpdate];
	}
	return self;
}

-(void) initBatchNode
{
    batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sheetObjects.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sheetObjects.plist"];
    
    [self addChild:batchNode z:10];
}

-(void) initHero
{
    hero = [[Hero alloc] initHeroWithFile:@"HERO/AL_H_hero_1.png" position:ccp(150,200)];
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
    boardManager = [[BoardManager alloc] initWithFile:@"SK_plate.png" z:10];
}

- (void) dealloc
{
	[boardManager release];
    [bgManager release];
    [batchNode release];
    [[PhysicsManager sharedPhysicsManager] release];
	[super dealloc];
}
@end

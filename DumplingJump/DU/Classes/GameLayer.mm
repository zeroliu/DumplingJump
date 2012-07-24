#import "GameLayer.h"
#import "BackgroundManager.h"
#import "Board.h"
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
        
        [self test];
        
        [[CCScheduler sharedScheduler] scheduleSelector:@selector(createNewBall) forTarget:self interval:0.04 paused:NO];
	}
	return self;
}

-(void) test
{
//    TEST HOW TO USE DUOBJECT
    
//    DUObject *testObject = [[DUObjectsFactory createObjectWithName:@"Hero"] autorelease];
//    NSLog(@"the old name is %@",testObject.name);
//    NSLog(@"before archieve: \n%@",[[DUObjectsDictionary sharedDictionary] printDictionary]);
//    [testObject archive];
    
//    TEST HOW TO USE DUSPRITE
    
//    [[AnimationManager shared] addAnimationWithName:@"HeroIdle" file:@"HERO/AL_H_hero" startFrame:1 endFrame:10 delay:0.1];
//    DUSprite *herotest = [[DUObjectsFactory createSpriteWithName:@"Hero" sprite:[CCSprite spriteWithSpriteFrameName:@"HERO/AL_H_hero_1.png"]] autorelease];
//    herotest.sprite.position = ccp(160, 300);
//    [herotest.sprite runAction:[[AnimationManager shared] getAnimationWithName:@"HeroIdle" repeat:0]];
//    [herotest addChildTo:batchNode];
//    [self performSelector:@selector(createTestHero) withObject:nil afterDelay:1.8];
//    [herotest archive];
    
//    TEST HOW TO USE DUPhysicsObject
    
}

//-(void) createTestHero
//{
//    DUSprite *herotest2 = [DUObjectsFactory createSpriteWithName:@"Hero" sprite:[CCSprite spriteWithSpriteFrameName:@"HERO/AL_H_hero_1.png"]];
//    
//    herotest2.sprite.position = ccp(100,200);
//    [herotest2.sprite runAction:[[AnimationManager shared] getAnimationWithName:@"HeroIdle" repeat:0]];
////    [batchNode addChild:herotest2.sprite];
//    [herotest2 addChildTo:batchNode];
//}


-(void)createBall:(CGPoint)point
{
    DUPhysicsObject *ball;
    if([[DUObjectsDictionary sharedDictionary] containsDUObject:@"ball"])
    {
        ball = [DUObjectsFactory createPhysicsWithName:@"ball" file:nil body:nil];
    } else {
        b2BodyDef heroBodyDef;
        heroBodyDef.type = b2_dynamicBody;
        CCSprite *herosprite = [CCSprite spriteWithSpriteFrameName:@"HERO/AL_H_hero_1.png"];
        b2Body *heroBody = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&heroBodyDef);
        
        b2CircleShape heroShape;
        heroShape.m_radius = (herosprite.contentSize.height/2-7) /RATIO;
        
        b2FixtureDef heroFixtureDef;
        heroFixtureDef.shape = &heroShape;
        heroFixtureDef.density = 1.0f;
        heroFixtureDef.friction = 0.3f;
        heroFixtureDef.restitution = 0.6f;
        
        heroBody->CreateFixture(&heroFixtureDef);
        
        b2MassData massData;
        massData.center = heroBody->GetLocalCenter();
        massData.mass = 100;
        massData.I = 1;
        heroBody->SetMassData(&massData);
        ball = [DUObjectsFactory createPhysicsWithName:@"ball" file:@"HERO/AL_H_hero_1.png" body:heroBody];
        
    }
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

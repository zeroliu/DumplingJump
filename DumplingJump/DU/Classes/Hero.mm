#import "Hero.h"

@implementation Hero
@synthesize heroSprite;

#pragma mark -
#pragma Initialization

-(id)initHeroWithFile:(NSString *)fileName position:(CGPoint)thePosition
{
    if(self = [super init])
    {
        heroSprite = [CCSprite spriteWithSpriteFrameName:fileName];
        heroSprite.position = thePosition;
        [[[[Hub shared] gameLayer] batchNode] addChild:heroSprite];
        
        [self initHeroAnimation];
        [self initHeroPhysicsWithPosition:thePosition];
        [self initSpeed];
        
        //Set up hero control
        [self initGestureHandler];
    }
    
    return self;
}

-(void) initGestureHandler
{
    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionUp selector:@selector(onSwipeUpDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionDown selector:@selector(onSwipeDownDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionLeft selector:@selector(onSwipeLeftDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionRight selector:@selector(onSwipeRightDetected:) target:self number:1];
}


-(void) initSpeed
{
    speed = heroBody->GetLinearVelocity(); 
    NSLog(@"speedY = %f",heroBody->GetLinearVelocity().y);
}

-(void) initHeroAnimation
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=10; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"HERO/AL_H_hero_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id animObject = [CCAnimation animationWithFrames:frameArray delay:0.1];
    id animAction = [CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
    animAction = [CCRepeatForever actionWithAction:animAction];
    
    [heroSprite runAction:animAction];
}

-(void) initHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = heroSprite;
    
    heroBody = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&heroBodyDef);
      
    b2CircleShape heroShape;
   
    heroShape.m_radius = (heroSprite.contentSize.height/2-7) /RATIO;
    
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0.6f;
    
    heroBody->CreateFixture(&heroFixtureDef);
    
    heroBody->SetFixedRotation(true);
    heroBody->SetSleepingAllowed(false);
    
    b2MassData massData;
    massData.center = heroBody->GetLocalCenter();
    massData.mass = 200;
    massData.I = 1;
    heroBody->SetMassData(&massData);
}

#pragma mark -
#pragma mark ListenerHandler
-(void) onSwipeUpDetected:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"state = %d", (int)recognizer.state);
    //acc.Set([[Constants shared]heroAccelerationXBase], 0);
    [self jump];
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateBegan) 
    {
        CGPoint ccp = [recognizer locationInView:[[CCDirector sharedDirector] openGLView]]; 
        ccp = [[CCDirector sharedDirector] convertToGL:ccp];
    }
}

#pragma mark -
#pragma mark Movement
-(void) setAccelerationWithX:(float)theX Y:(float)theY
{
    acc.Set(acc.x+theX, acc.y+theY);
}

-(void) jump
{
    heroBody->SetLinearVelocity(speed + *new b2Vec2(0, 12));
}

-(void) updateHeroPosition
{
    acc.Set([[AccelerometerManager shared] accX] * SENSIBILITY, 0);
    speed.Set(clampf(heroBody->GetLinearVelocity().x + acc.x, -MAX_SPEED, MAX_SPEED),heroBody->GetLinearVelocity().y + acc.y);
    heroBody->SetLinearVelocity(speed);
    speed.Set(speed.x * SPEED_INERTIA, speed.y);
}

-(void) dealloc
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super dealloc];
}
@end

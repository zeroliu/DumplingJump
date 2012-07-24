#import "Hero.h"

@implementation Hero

#pragma mark -
#pragma Initialization

-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition
{
    if (self = [super initWithName:theName]) 
    {
        [self initHeroAnimation];
        [self initHeroSpriteWithFile:@"HERO/AL_H_hero_1.png" position:thePosition];
        [self initHeroPhysicsWithPosition:thePosition];
        [self initSpeed];
    
        //Set up hero control
        [self initGestureHandler];
    }
    
    return self;
}

//-(id)initHeroWithFile:(NSString *)fileName position:(CGPoint)thePosition
//{
//    if(self = [super init])
//    {
//        heroSprite = [CCSprite spriteWithSpriteFrameName:fileName];
//        heroSprite.position = thePosition;
//        [[[[Hub shared] gameLayer] batchNode] addChild:heroSprite];
//        
//        [self initHeroAnimation];
//        [self initHeroPhysicsWithPosition:thePosition];
//        [self initSpeed];
//        
//        //Set up hero control
//        [self initGestureHandler];
//    }
//    
//    return self;
//}

-(void) initGestureHandler
{
    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionUp selector:@selector(onSwipeUpDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionDown selector:@selector(onSwipeDownDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionLeft selector:@selector(onSwipeLeftDetected:) target:self number:1];
//    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionRight selector:@selector(onSwipeRightDetected:) target:self number:1];
}


-(void) initSpeed
{
    speed = body->GetLinearVelocity(); 
//    NSLog(@"speedY = %f",body->GetLinearVelocity().y);
}

-(void) initHeroAnimation
{
    [[AnimationManager shared] addAnimationWithName:@"HeroIdle" file:@"HERO/AL_H_hero" startFrame:1 endFrame:10 delay:0.1];
}

-(void) initHeroSpriteWithFile:(NSString *)filename position:(CGPoint)thePosition
{
    sprite = [CCSprite spriteWithSpriteFrameName:filename];
    sprite.position = thePosition;
}

-(void) initHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = self;
    
    body = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&heroBodyDef);
    
    b2CircleShape heroShape;
   
    heroShape.m_radius = (sprite.contentSize.height/2-7) /RATIO;
    
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0.6f;
    
    body->CreateFixture(&heroFixtureDef);
    
    body->SetFixedRotation(true);
    body->SetSleepingAllowed(false);
    
    b2MassData massData;
    massData.center = body->GetLocalCenter();
    massData.mass = 200;
    massData.I = 1;
    body->SetMassData(&massData);
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
    body->SetLinearVelocity(speed + *new b2Vec2(0, 12));
}

-(void) updateHeroPosition
{
    acc.Set([[AccelerometerManager shared] accX] * SENSIBILITY, 0);
    speed.Set(clampf(body->GetLinearVelocity().x + acc.x, -MAX_SPEED, MAX_SPEED),body->GetLinearVelocity().y + acc.y);
    body->SetLinearVelocity(speed);
    speed.Set(speed.x * SPEED_INERTIA, speed.y);
}

-(void) dealloc
{
//    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super dealloc];
}
@end

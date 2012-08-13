//
//  Hero.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Hero.h"
@interface Hero()

@property (nonatomic, assign) float x,y;
@property (nonatomic, assign) b2Vec2 speed,acc;

@end

@implementation Hero
@synthesize x=_x, y=_y, speed=_speed, acc=_acc;

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

-(void) initHeroAnimation
{
    [ANIMATIONMANAGER addAnimationWithName:@"HeroIdle" file:@"HERO/AL_H_hero" startFrame:1 endFrame:10 delay:0.1];
}

-(void) initHeroSpriteWithFile:(NSString *)filename position:(CGPoint)thePosition
{
    self.sprite = [CCSprite spriteWithSpriteFrameName:filename];
    self.sprite.position = thePosition;
}

-(void) initHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = self;
    
    self.body = WORLD->CreateBody(&heroBodyDef);
    
    b2CircleShape heroShape;
    
    heroShape.m_radius = (self.sprite.contentSize.height/2-7) /RATIO;
    
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0.6f;
    
    self.body->CreateFixture(&heroFixtureDef);
    
    self.body->SetFixedRotation(true);
    self.body->SetSleepingAllowed(false);
    
    b2MassData massData;
    massData.center = self.body->GetLocalCenter();
    massData.mass = 200;
    massData.I = 1;
    self.body->SetMassData(&massData);
}

-(void) initSpeed
{
    self.speed = self.body->GetLinearVelocity(); 
    //    NSLog(@"speedY = %f",body->GetLinearVelocity().y);
}


-(void) initGestureHandler
{
    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionUp selector:@selector(onSwipeUpDetected:) target:self number:1];
    //    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionDown selector:@selector(onSwipeDownDetected:) target:self number:1];
    //    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionLeft selector:@selector(onSwipeLeftDetected:) target:self number:1];
    //    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionRight selector:@selector(onSwipeRightDetected:) target:self number:1];
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

-(void) updateHeroPositionWithAccX:(float)accX
{
    //Set hero acceleration
    self.acc = b2Vec2(accX * SENSIBILITY, 0);
    //Set hero speed
    self.speed = b2Vec2(clampf(self.body->GetLinearVelocity().x + self.acc.x, -MAX_SPEED, MAX_SPEED),self.body->GetLinearVelocity().y + self.acc.y);
    
    self.body->SetLinearVelocity(self.speed);
    self.speed = b2Vec2(self.speed.x * SPEED_INERTIA, self.speed.y);
//    DLog(@"speedY = %g", self.speed.y);
}

-(void) jump
{
    //TODO: Detect if hero is on the ground or on something
    self.body->SetLinearVelocity(self.speed + *new b2Vec2(0, 12));
}

-(void) dealloc
{
    //    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super dealloc];
}

@end

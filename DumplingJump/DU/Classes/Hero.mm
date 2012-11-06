//
//  Hero.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Hero.h"
@interface Hero()
{
    float adjustMove, adjustJump;
    b2Vec2 directionForce;
    float origHeight;
}
@property (nonatomic, assign) float x,y;
@property (nonatomic, assign) b2Vec2 speed,acc;
@property (nonatomic, assign) BOOL isOnGround;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float mass;
@property (nonatomic, assign) float I;
@property (nonatomic, assign) float fric;
@property (nonatomic, assign) float maxVx;
@property (nonatomic, assign) float maxVy;
@property (nonatomic, assign) float accValue;
@property (nonatomic, assign) float jumpValue;
@end

@implementation Hero
@synthesize x=_x, y=_y, speed=_speed, acc=_acc, isOnGround=_isOnGround, heroState = _heroState, radius = _radius, mass = _mass, I = _I, fric = _fric, maxVx = _maxVx, maxVy = _maxVy, accValue = _accValue, jumpValue = _jumpValue;

#pragma mark -
#pragma Initialization
-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius mass:(float)theMass I:(float)theI fric:(float)theFric maxVx:(float)theMaxVx maxVy:(float)theMaxVy accValue:(float)theAccValue jumpValue:(float)theJumpValue
{
    if (self = [super initWithName:theName]) 
    {
        self.radius = theRadius;
        self.mass = theMass;
        self.I = theI;
        self.fric = theFric;
        self.maxVx = theMaxVx;
        self.maxVy = theMaxVy;
        self.accValue = theAccValue;
        self.jumpValue = theJumpValue;
        
        [self initHeroParam];
        [self initHeroSpriteWithFile:@"HERO/AL_H_hero_1.png" position:thePosition];
        [self initHeroPhysicsWithPosition:thePosition];
        [self initSpeed];
        [self initGestureHandler];
        [self initContactListener];
        [self idle];
    }
    
    return self;
}

-(void) initHeroParam
{
    self.isOnGround = FALSE;
    self.heroState = nil;
}

-(void) initHeroSpriteWithFile:(NSString *)filename position:(CGPoint)thePosition
{
    self.sprite = [CCSprite spriteWithSpriteFrameName:filename];
    self.sprite.position = thePosition;
    origHeight = self.sprite.contentSize.height;
    //self.sprite.scale = self.radius/self.sprite.contentSize.height * SCALE_MULTIPLIER;
}

-(void) initHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = self;
    
    self.body = WORLD->CreateBody(&heroBodyDef);
    
    b2CircleShape heroShape;
    
//    heroShape.m_radius = (self.sprite.contentSize.height/2-10) /RATIO;
    heroShape.m_radius = self.radius / RATIO * SCALE_MULTIPLIER;
    self.sprite.scale = (heroShape.m_radius * RATIO + 20) * 2 / origHeight;
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.friction = self.fric;
    heroFixtureDef.restitution = 0;
    
    self.body->CreateFixture(&heroFixtureDef);
    
    self.body->SetFixedRotation(true);
    self.body->SetSleepingAllowed(false);
    
    b2MassData massData;
    massData.center = self.body->GetLocalCenter();
    massData.mass = self.mass * [PHYSICSMANAGER mass_multiplier];
    massData.I = self.I;
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

-(void) initContactListener
{
    [MESSAGECENTER addObserver:self selector:@selector(heroLandOnObject:) name:[NSString stringWithFormat:@"%@Contact",self.name] object:nil];
    [MESSAGECENTER addObserver:self selector:@selector(heroLandOffObject:) name:[NSString stringWithFormat:@"%@EndContact",self.name] object:nil];
}

-(void) updateHeroForce
{
    if (directionForce.x != 0 || directionForce.y != 0)
    {
        self.body->ApplyForce(directionForce, self.body->GetPosition());
    }
}

#pragma mark -
#pragma mark Movement

-(void) updateHeroPositionWithAccX:(float)accX
{
    //Set hero acceleration
    self.acc = b2Vec2(accX * self.accValue * adjustMove, 0);
    //Set hero speed
    self.speed = b2Vec2(clampf(self.body->GetLinearVelocity().x + self.acc.x, -self.maxVx, self.maxVx),clampf(self.body->GetLinearVelocity().y + self.acc.y, -self.maxVy, self.maxVy));
    
    self.body->SetLinearVelocity(self.speed);
    self.speed = b2Vec2(self.speed.x * SPEED_INERTIA, self.speed.y);
//    DLog(@"speedY = %g", self.speed.y);
}

-(void) jump
{
    //TODO: Detect if hero is on the ground or on something
    if (self.isOnGround) self.body->SetLinearVelocity(self.speed + *new b2Vec2(0, self.jumpValue/RATIO * adjustJump));
    [self checkIfOnGround];
}

-(void) idle
{
    if (self.heroState != HEROIDLE)
    {
        self.heroState = HEROIDLE;
        id animation = [ANIMATIONMANAGER getAnimationWithName:HEROIDLE];
        
        if(animation != nil)
        {
            [self.sprite stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [self.sprite runAction:animAction];
        }
        
        for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
        {
            f->SetFriction(0.3f);
            for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
            {
                contactEdge->contact->ResetFriction();
            }
        }
        
        directionForce = b2Vec2(0,0);
        
        adjustJump = 1;
        adjustMove = 1;
        
    }
}

-(void) dizzy
{
    //TODO: change the hero status
    
    
}

-(void) hurt:(NSArray *)value
{
    int hurtValue = [[value objectAtIndex:0] intValue];
    DUPhysicsObject *contactObject = [value objectAtIndex:1];
    int offset = 0;
    if (contactObject.sprite.position.x > self.sprite.position.x)
    {
        offset = -1;
    } else
    {
        offset = 1;
    }
    directionForce = b2Vec2(offset * self.body->GetMass() * 5 * hurtValue, 0);
    adjustJump = 0;
    //self.body->ApplyLinearImpulse(directionForce, self.body->GetPosition());
    //self.body->ApplyForce(directionForce, self.body->GetPosition());
    
}

-(void) bowEffect:(NSArray *)value
{
    if (self.heroState != HEROIDLE)
    {
        CGPoint explosionPos = [[value objectAtIndex:0] CGPointValue];
        float distance = ccpDistance(explosionPos, self.sprite.position);
        float explosionForce = min(SHOCK_PRESSURE / distance / distance, 15)/distance;
        DLog(@"Force direction: %g,%g", explosionForce * (self.sprite.position.x - explosionPos.x), explosionForce * (self.sprite.position.y - explosionPos.y));
        //float length = b2Vec2(self.sprite.position.x - explosionPos.x, self.sprite.position.y - explosionPos.y).Normalize();
        self.body->ApplyLinearImpulse(b2Vec2(explosionForce * self.body->GetMass() * (self.sprite.position.x - explosionPos.x), explosionForce * self.body->GetMass() * (self.sprite.position.y - explosionPos.y)), self.body->GetPosition());
         
        /*
        directionForce = b2Vec2(explosionForce * self.body->GetMass() * (self.sprite.position.x - explosionPos.x), explosionForce * self.body->GetMass() * (self.sprite.position.y - explosionPos.y));
         */
        //[self performSelector:@selector(bowEffect:) withObject:value afterDelay:1/23.0f];
    }
}

-(void) flat
{
    adjustJump = 0;
}

-(void) freeze
{
    self.body->GetFixtureList()->SetFriction(0);
    for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
    {
        contactEdge->contact->ResetFriction();
    }
    adjustJump = 0;
    adjustMove = 0;
    DLog(@"freeze");
}

-(void)heroLandOnObject:(NSNotification *)notification
{
    DUPhysicsObject *targetObject = (DUPhysicsObject *)([notification.userInfo objectForKey:@"object"]);
    if (self.sprite.position.y > targetObject.sprite.position.y)
    {
        self.isOnGround = YES;
    }
}

-(void)heroLandOffObject:(NSNotification *)notification
{
    self.isOnGround = NO;
    [self checkIfOnGround];
//    DLog(@"Land off");
}

-(void)checkIfOnGround
{
    //Fix hero cannot jump bug
    BOOL res = NO;
    for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
    {
        if (contactEdge->contact->IsTouching())
        {
            /*
            if (contactEdge->contact->GetFixtureA()->GetBody()->GetUserData() == self)
            {
                b2WorldManifold manifold;
                contactEdge->contact->GetWorldManifold(&manifold);
                
                if (manifold.points[0].y < self.sprite.position.y)
                {
                    res = YES;
                }
            } else if(contactEdge->contact->GetFixtureB()->GetBody()->GetUserData() == self)
            {
                b2WorldManifold manifold;
                contactEdge->contact->GetWorldManifold(&manifold);
                
                if (((DUPhysicsObject *)contactEdge->contact->GetFixtureA()->GetBody()->GetUserData()).sprite.position.y < self.sprite.position.y)
                {
                    res = YES;
                }
            }
             */
            b2WorldManifold manifold;
            contactEdge->contact->GetWorldManifold(&manifold);
            if (manifold.points[0].y < self.sprite.position.y)
            {
                res = YES;
                break;
            }
        }
    }
    self.isOnGround = res;
}

#pragma mark -
#pragma mark ListenerHandler
-(void) onSwipeUpDetected:(UISwipeGestureRecognizer *)recognizer
{
    /*
     NSLog(@"state = %d", (int)recognizer.state);
     //acc.Set([[Constants shared]heroAccelerationXBase], 0);
     [self jump];
     if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateBegan)
     {
     CGPoint ccp = [recognizer locationInView:[[CCDirector sharedDirector] view]];
     ccp = [[CCDirector sharedDirector] convertToGL:ccp];
     }
     */
}

-(void) dealloc
{
    //    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super dealloc];
}

@end

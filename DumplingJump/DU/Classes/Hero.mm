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
@property (nonatomic, assign) float gravity;
@end

@implementation Hero
@synthesize x=_x, y=_y, speed=_speed, acc=_acc, isOnGround=_isOnGround, heroState = _heroState, radius = _radius, mass = _mass, I = _I, fric = _fric, maxVx = _maxVx, maxVy = _maxVy, accValue = _accValue, jumpValue = _jumpValue, gravity = _gravity, powerup = _powerup, powerupCountdown = _powerupCountdown;

#pragma mark -
#pragma Initialization
-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition radius:(float)theRadius mass:(float)theMass I:(float)theI fric:(float)theFric maxVx:(float)theMaxVx maxVy:(float)theMaxVy accValue:(float)theAccValue jumpValue:(float)theJumpValue gravityValue:(float)theGravity
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
        self.gravity = theGravity;
        
        self.powerup = nil;
        
        [self initHeroParam];
        [self initHeroSpriteWithFile:@"AL_H_hero_1.png" position:thePosition];
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
    heroFixtureDef.filter.categoryBits = C_HERO;
    heroFixtureDef.filter.maskBits = C_HERO | C_BOARD | C_ADDTHING;
    
    b2CircleShape shellShape;
    shellShape.m_radius = self.radius * 1.5f * RATIO * SCALE_MULTIPLIER;
    shellFixtureDef.shape = &shellShape;
    shellFixtureDef.friction = self.fric;
    shellFixtureDef.restitution = 0;
    
    self.body->CreateFixture(&heroFixtureDef);
    
    self.body->SetFixedRotation(true);
    self.body->SetSleepingAllowed(false);
    self.body->SetGravityScale((self.gravity)/100.0f);
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

-(void) updateHeroPowerupCountDown:(ccTime)dt
{
    if (self.powerupCountdown > 0)
    {
        self.powerupCountdown = self.powerupCountdown - dt;
        if (self.powerupCountdown < 0)
        {
            self.powerupCountdown = 0;
            self.powerup = nil;
        }
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
    
    if ([self.heroState isEqualToString:@"spring"] && self.isOnGround)
    {
        [self springJump];
    }
    
    if (maskNode != NULL)
    {
        [maskNode updateSprite:ccp(self.sprite.position.x, self.sprite.position.y+self.radius*4)];
    }
    
//    DLog(@"speedY = %g", self.speed.y);
}

-(void) jump
{
    if (self.isOnGround) self.body->SetLinearVelocity(*new b2Vec2(self.speed.x, self.jumpValue/RATIO * adjustJump));
    [self checkIfOnGround];
}

-(void) springJump
{
    if (self.isOnGround) self.body->SetLinearVelocity(*new b2Vec2(self.speed.x, self.jumpValue * 1.5f/RATIO * adjustJump));
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
        
        if (shellFixture != NULL)
        {
            self.body->DestroyFixture(shellFixture);
            shellFixture = NULL;
        }
        
        [GAMELAYER unschedule:@selector(fire)];
        
        if (maskNode != nil)
        {
            [maskNode removeMask];
            [maskNode release];
            maskNode = nil;
        }
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

-(void) spring
{
    DLog(@"spring");
}

-(void) shelter
{
    DLog(@"shelter");
    //shellFixture = self.body->CreateFixture(&shellFixtureDef);
}

-(void) magic:(NSArray *)value;
{
    DLog(@"magic - %@", value);
    [GAMELAYER schedule:@selector(fire) interval:1];
}

-(void) blind
{
    DLog(@"blind");
    CCSprite *blackBg = [CCSprite spriteWithFile:@"blackbg.png"];
    CCSprite *mask = [CCSprite spriteWithFile:@"mask.png"];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    maskNode = [[CircleMask alloc] initWithTexture:[blackBg retain] Mask:[mask retain]];
    CCSprite *final = [maskNode maskedSpriteWithSprite: ccp(self.sprite.position.x, self.sprite.position.y+self.radius*4)];
    final.position = ccp(winSize.width/2,winSize.height/2);
    [GAMELAYER addChild:final z:10];
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

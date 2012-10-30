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
}
@property (nonatomic, assign) float x,y;
@property (nonatomic, assign) b2Vec2 speed,acc;
@property (nonatomic, assign) BOOL isOnGround;

@end

@implementation Hero
@synthesize x=_x, y=_y, speed=_speed, acc=_acc, isOnGround=_isOnGround, heroState = _heroState;

#pragma mark -
#pragma Initialization
-(id)initHeroWithName:(NSString *)theName position:(CGPoint)thePosition
{
    if (self = [super initWithName:theName]) 
    {
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
    self.sprite.scale = SCALE_MULTIPLIER;
}

-(void) initHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = self;
    
    self.body = WORLD->CreateBody(&heroBodyDef);
    
    b2CircleShape heroShape;
    
    heroShape.m_radius = (self.sprite.contentSize.height/2-10) /RATIO;
    
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0;
    
    self.body->CreateFixture(&heroFixtureDef);
    
    self.body->SetFixedRotation(true);
    self.body->SetSleepingAllowed(false);
    
    b2MassData massData;
    massData.center = self.body->GetLocalCenter();
    massData.mass = 13*MASS_MULTIPLIER;
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
    self.acc = b2Vec2(accX * SENSIBILITY * adjustMove, 0);
    //Set hero speed
    self.speed = b2Vec2(clampf(self.body->GetLinearVelocity().x + self.acc.x, -MAX_SPEED, MAX_SPEED),self.body->GetLinearVelocity().y + self.acc.y);
    
    self.body->SetLinearVelocity(self.speed);
    self.speed = b2Vec2(self.speed.x * SPEED_INERTIA, self.speed.y);
//    DLog(@"speedY = %g", self.speed.y);
}

-(void) jump
{
    //TODO: Detect if hero is on the ground or on something
    if (self.isOnGround) self.body->SetLinearVelocity(self.speed + *new b2Vec2(0, 325/RATIO * adjustJump));
    [self checkIfOnGround];
}

-(void) idle
{
    //TODO: change the hero status (EX: enable jump and move)
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
            if (contactEdge->contact->GetFixtureA()->GetBody()->GetUserData() == self)
            {
                if (((DUPhysicsObject *)contactEdge->contact->GetFixtureB()->GetBody()->GetUserData()).sprite.position.y < self.sprite.position.y)
                {
                    res = YES;
                }
            } else if(contactEdge->contact->GetFixtureB()->GetBody()->GetUserData() == self)
            {
                if (((DUPhysicsObject *)contactEdge->contact->GetFixtureA()->GetBody()->GetUserData()).sprite.position.y < self.sprite.position.y)
                {
                    res = YES;
                }
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

//
//  Hero.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#define ABSORB_POWERUP_TAG 10
#define REBORN_POWERUP_TAG 20

#import "Hero.h"
#import "AddthingObject.h"
#import "BackgroundController.h"
#import "LevelManager.h"
#import "BoardManager.h"
#import "EffectManager.h"
#import "GameModel.h"
#import "GameUI.h"
#import "DUEffectObject.h"
@interface Hero()
{
    float adjustMove, adjustJump;
    b2Vec2 directionForce;
    b2Vec2 lastVelocity;
    float origHeight;
    BOOL isReborning;
    BOOL isAbsorbing;
    CGSize heroSize;
    int blowAwayTrigger; //-1 left, 0 off, 1 right
    int freezeTrigger; //-1 left, 0 off, 1 right
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
@synthesize x=_x, y=_y, speed=_speed, acc=_acc, isOnGround=_isOnGround, heroState = _heroState, radius = _radius, mass = _mass, I = _I, fric = _fric, maxVx = _maxVx, maxVy = _maxVy, accValue = _accValue, jumpValue = _jumpValue, gravity = _gravity, powerup = _powerup, powerupCountdown = _powerupCountdown, canReborn = _canReborn;

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
        [self initHeroSpriteWithFile:@"H_hero_1.png" position:thePosition];
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
    self.isOnGround = NO;
    self.heroState = nil;
    isReborning = NO;
    isAbsorbing = NO;
}

-(void) initHeroSpriteWithFile:(NSString *)filename position:(CGPoint)thePosition
{
    self.sprite = [CCSprite spriteWithSpriteFrameName:filename];
    self.sprite.position = thePosition;
//    self.sprite = ccp(0.5,0.5);
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
    heroFixtureDef.filter.maskBits = C_BOARD | C_ADDTHING | C_STAR;
    heroFixtureDef.userData = @"heroBody";
    
    b2CircleShape shellShape;
    shellShape.m_radius = self.radius * 5 / RATIO * SCALE_MULTIPLIER;
    b2FixtureDef shellFixtureDef;
    shellFixtureDef.shape = &shellShape;
    shellFixtureDef.friction = 0;
    shellFixtureDef.restitution = 0;
    shellFixtureDef.isSensor = true;
    shellFixtureDef.filter.categoryBits = C_ABSORB;
    shellFixtureDef.filter.maskBits = C_NOTHING;
    shellFixtureDef.userData = @"absorb";
    
    self.body->CreateFixture(&heroFixtureDef);
    self.body->CreateFixture(&shellFixtureDef);
    
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
    /*
    [[InputManager sharedInputManager] watchForSwipeWithDirection:UISwipeGestureRecognizerDirectionUp selector:@selector(onSwipeUpDetected:) target:self number:1];
     */
}

-(void) initContactListener
{
    [MESSAGECENTER addObserver:self selector:@selector(heroLandOnObject:) name:[NSString stringWithFormat:@"%@Contact",self.name] object:nil];
    [MESSAGECENTER addObserver:self selector:@selector(heroLandOffObject:) name:[NSString stringWithFormat:@"%@EndContact",self.name] object:nil];
}

-(void) removeContactListner
{
    [MESSAGECENTER removeObserver:self name:[NSString stringWithFormat:@"%@Contact",self.name] object:nil];
    [MESSAGECENTER removeObserver:self name:[NSString stringWithFormat:@"%@EndContact",self.name] object:nil];
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

//Dirty function
-(void) updateHeroChildrenPosition
{
    if (heroSize.width != self.sprite.contentSize.width || heroSize.height != self.sprite.contentSize.height)
    {
        heroSize = self.sprite.contentSize;
        for (CCSprite *child in [self.sprite children])
        {
            if (child.tag == REBORN_POWERUP_TAG)
            {
                child.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2+3);
            } else
            {
                child.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
            }
            
        }
    }
}

-(void) updateJumpState
{
    if (lastVelocity.y > 0 && self.body->GetLinearVelocity().y < 0)
    {
        if ([self.heroState isEqualToString:@"springBoost"])
        {
            self.heroState = @"spring";
        }
    }
    lastVelocity = self.body->GetLinearVelocity();
}

-(void) updateHeroBoosterEffect
{
    //Ready phase, hero slowly moving back
    if ([self.heroState isEqualToString:@"booster"])
    {
        self.body->SetLinearVelocity(b2Vec2(0, -0.5));
    }
    
    if ([self.heroState isEqualToString:@"boosterReady"])
    {
        if (self.sprite.position.y > 450)
        {
            self.heroState = @"boosterStart";
            [self boosterStart];
            return;
        }
        
        self.body->SetLinearVelocity(b2Vec2(self.speed.x, 30));
    }
    
    if ([self.heroState isEqualToString:@"boosterStart"])
    {
        //Fake floating effect
        if (self.sprite.position.y < 330)
        {
            self.body->SetLinearVelocity(b2Vec2(self.speed.x, -0.015 * self.sprite.position.y + 5.5));
        }
        else if (self.sprite.position.y > 380)
        {
            self.body->SetLinearVelocity(b2Vec2(self.speed.x, randomFloat(-1.5, -1)));
        }
        
        //Don't move out of the screen
        if (self.sprite.position.x < 50)
        {
            self.body->SetLinearVelocity(b2Vec2(1, self.speed.y));
        }
        else if (self.sprite.position.x > 270)
        {
            self.body->SetLinearVelocity(b2Vec2(-1, self.speed.y));
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
    float vX = self.body->GetLinearVelocity().x/[[[[WorldData shared] loadDataWithAttributName:@"hero"] objectForKey:@"velocityAccRatio"] floatValue] + self.acc.x;
    
    self.speed = b2Vec2(clampf(vX, -self.maxVx, self.maxVx),clampf(self.body->GetLinearVelocity().y + self.acc.y, -self.maxVy, self.maxVy));
    
    if (blowAwayTrigger != 0)
    {
        self.body->SetLinearVelocity(b2Vec2(self.maxVx * blowAwayTrigger, self.speed.y));
    }
    else if (freezeTrigger != 0)
    {
        self.body->SetLinearVelocity(b2Vec2([[[[WorldData shared] loadDataWithAttributName:@"hero"] objectForKey:@"freezeSpeed"] floatValue] * freezeTrigger, self.speed.y));
    }
    else
    {
        self.body->SetLinearVelocity(self.speed);
    }
    
    if (maskNode != NULL)
    {
        [maskNode updateSprite:ccp(self.sprite.position.x, self.sprite.position.y+self.radius*4)];
    }
}

-(void) jump
{
    [self checkIfOnGround];
    if ([self.heroState isEqualToString:@"spring"])
    {
        self.heroState = @"springBoost";
        [self springJump];
    }
    else
    {
        [self normalJump];
    }
}

-(void) normalJump
{
    if (self.isOnGround) self.body->SetLinearVelocity(b2Vec2(self.speed.x, self.jumpValue/RATIO * adjustJump));
}

-(void) springJump
{
    if (self.isOnGround && self.sprite.position.y < [CCDirector sharedDirector].winSize.height/2) self.body->SetLinearVelocity(b2Vec2(self.speed.x, self.jumpValue * 1.35f/RATIO * adjustJump));
}

-(void) idle
{
    if (![self.heroState isEqualToString: HEROIDLE])
    {
        self.heroState = HEROIDLE;
        id animation = [ANIMATIONMANAGER getAnimationWithName:HEROIDLE];
        
        if(animation != nil)
        {
            [self.sprite stopAllActions];
            //self.sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_1.png", HEROIDLE]];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [self.sprite runAction:animAction];
        }
        
        for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
        {
            if ([(NSString *)f->GetUserData() isEqualToString:@"heroBody"])
            {
                f->SetFriction(self.fric);
            } else
            {
                f->SetFriction(0);
            }
        }
        for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
        {
            contactEdge->contact->ResetFriction();
        }
        
        self.body->SetGravityScale((self.gravity)/100.0f);
        
        directionForce = b2Vec2(0,0);
        
        adjustJump = 1;
        adjustMove = 1;
        freezeTrigger = 0;
        blowAwayTrigger = 0;
        /*
        for (CCSprite *child in [self.sprite children])
        {
            NSLog(@"idle: %g,%g", self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
            child.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
        }
        
        if (shellFixture != NULL)
        {
            self.body->DestroyFixture(shellFixture);
            shellFixture = NULL;
        }
        */
        [self unschedule:@selector(fire)];
        
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
    directionForce = b2Vec2(offset * self.body->GetMass() * 10 * hurtValue, 0);
    adjustJump = 0;
    adjustMove = 0;
    //self.body->ApplyLinearImpulse(directionForce, self.body->GetPosition());
    //self.body->ApplyForce(directionForce, self.body->GetPosition());
    
}

-(void) bowEffect:(NSArray *)value
{
    CGPoint explosionPos = [[value objectAtIndex:0] CGPointValue];

    adjustJump = 0;
    adjustMove = 0;
    //Blow hero
    
    float distance = ccpDistance(explosionPos, self.sprite.position);
    float explosionForce = SHOCK_PRESSURE / 500;
    self.body->ApplyLinearImpulse(b2Vec2(explosionForce * self.body->GetMass() * (self.sprite.position.x - explosionPos.x)/distance, explosionForce * self.body->GetMass() * (self.sprite.position.y - explosionPos.y)/distance), self.body->GetPosition());
    
    if (self.sprite.position.x < explosionPos.x)
    {
        blowAwayTrigger = -1;
    } else
    {
        blowAwayTrigger = 1;
    }
    //Blow objects
    for (DUPhysicsObject *ob in ((LevelManager *)[LevelManager shared]).generatedObjects)
    {
        CGPoint objectPos = ob.sprite.position;
        float distance = ccpDistance(objectPos, explosionPos);
        float explosionForce = SHOCK_PRESSURE/5000/distance;
        ob.body->ApplyLinearImpulse(b2Vec2(explosionForce * ob.body->GetMass() * (objectPos.x - explosionPos.x), explosionForce * ob.body->GetMass() * (objectPos.y - explosionPos.y)), ob.body->GetPosition());
    }

}

-(void) flat
{
    adjustJump = 0;
}

-(void) freeze
{
//    self.body->GetFixtureList()->SetFriction(0);
    for ( b2Fixture* bodyFixture = self.body->GetFixtureList(); bodyFixture; bodyFixture = bodyFixture->GetNext())
    {
        bodyFixture->SetFriction(0);
    }
    
    for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
    {
        contactEdge->contact->ResetFriction();
    }
//    for ( b2Shape* shape = self.body->get)
    adjustJump = 0;
    adjustMove = 0;
    
    if (self.speed.x > 0)
    {
        freezeTrigger = 1;
    }
    else
    {
        freezeTrigger = -1;
    }
}

-(void) spring
{
    DLog(@"spring");
}

-(void) shelter
{
    DLog(@"shelter");
}

-(void) headStart
{
    id animate = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:@"H_booster"]];
    [self.sprite runAction:[CCRepeatForever actionWithAction:animate]];
    self.body->SetTransform(b2Vec2([CCDirector sharedDirector].winSize.width/2 / RATIO, -200/RATIO),0);
    [self changeCollisionDetection:C_NOTHING];
    [self boosterReady];
    [self boosterBackgroundStart];
}

-(void) booster
{
    DLog(@"booster");
    //Ready effect
    [[BackgroundController shared] speedUpWithScale:0.5 interval:0.5];
    [self changeCollisionDetection:C_NOTHING];
    [self scheduleOnce:@selector(boosterReady) delay:1];
    [self scheduleOnce:@selector(boosterBackgroundStart) delay:0.8];
}

-(void) boosterBackgroundStart
{
    float interval = [[POWERUP_DATA objectForKey:@"booster"] floatValue];
    [[BackgroundController shared] speedUpWithScale:5 interval:interval];
    [GAMEMODEL boostGameSpeed:interval];
}

-(void) boosterReady
{
    float interval = [[POWERUP_DATA objectForKey:@"booster"] floatValue];
    self.heroState = @"boosterReady";
    //Play speed line effect
    CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_speedline.ccbi" parent:GAMELAYER z:Z_Speedline duration: MAX(1, interval) life:1];
    particleNode.position = CGPointZero;
}

-(void) boosterStart
{
    self.heroState = @"boosterStart";
    float interval = [[POWERUP_DATA objectForKey:@"booster"] floatValue];
    [[[BoardManager shared] getBoard] boosterEffect];
    
    
    self.body->SetGravityScale(0);
    self.body->SetLinearVelocity(b2Vec2(0,0));
    [self scheduleOnce:@selector(boosterEnd) delay:interval];
}

-(void) boosterEnd
{
    [self resetCollisionDetection];
    [[EffectManager shared] PlayEffectWithName:@"FX_ReviveEnd" position:ccp(self.sprite.contentSize.width/2, self.sprite.contentSize.height/2) z:Z_Hero-1 parent:self.sprite];
    [self idle];
}

-(void) magic:(NSArray *)value;
{
    DLog(@"magic - %@", value);
    [self schedule:@selector(fire) interval:[[POWERUP_DATA objectForKey:@"magic"] floatValue]];
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

-(void) fire
{
    DUPhysicsObject *slash = [[LevelManager shared] dropAddthingWithName:@"SLASH" atPosition:ccp(self.sprite.position.x,self.sprite.position.y +5)];
    
    id delay = [CCDelayTime actionWithDuration:0.2];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    [slash.sprite runAction:[CCSequence actions:delay, fadeOut, nil]];
    if (slash != nil)
    {
        slash.body->SetLinearVelocity(b2Vec2(0,17));
    }
}

-(void) star:(NSArray *)value
{
    AddthingObject *star = [value objectAtIndex:1];
    self.heroState = @"_star";
    
    if (isAbsorbing)
    {
        [PHYSICSMANAGER addToDisactiveList:star];
        id rotateStar = [CCRotateBy actionWithDuration:0.5 angle:180];
        id moveToPlayer = [CCCallBlock actionWithBlock:^
                           {
                               if (star.parent == nil)
                               {
                                   [GAMELAYER addChild:star];
                               }
                               [star schedule:@selector(moveToHeroWithSpeed:) interval:0.01];
                           }];
        [star.sprite runAction:rotateStar];
        [star.sprite runAction:moveToPlayer];
    } else
    {
        ((GameLayer *)GAMELAYER).model.star++;
        [[GameUI shared] updateStar:((GameLayer *)GAMELAYER).model.star];
        [star removeAddthing];
    }
}

-(void) megastar:(NSArray *)value
{
    AddthingObject *megastar = [value objectAtIndex:1];
    self.heroState = @"_megastar";
    
    ((GameLayer *)GAMELAYER).model.star += [[POWERUP_DATA objectForKey:@"megastar"] intValue];
    [[GameUI shared] updateStar:((GameLayer *)GAMELAYER).model.star];
    [megastar removeAddthing];
}

//Not being used
-(void) bombPowerup
{
    for (DUPhysicsObject *ob in ((LevelManager *)[LevelManager shared]).generatedObjects)
    {
        CGPoint explosionPos = ob.sprite.position;
        float distance = ccpDistance(explosionPos, self.sprite.position);
        float explosionForce = SHOCK_PRESSURE/5000/distance;
        ob.body->ApplyLinearImpulse(b2Vec2(explosionForce * ob.body->GetMass() * (explosionPos.x - self.sprite.position.x), explosionForce * ob.body->GetMass() * (explosionPos.y - self.sprite.position.y)), ob.body->GetPosition());
    }
    [EFFECTMANAGER PlayEffectWithName:FX_ItemBomb position:self.sprite.position z:Z_Hero-1 parent:BATCHNODE];
}

-(void) rebornPowerup
{
    if (!self.canReborn)
    {
        CCSprite *halo = [CCSprite spriteWithSpriteFrameName:@"E_item_reborn_start_1.png"];
        halo.scale = 0.8;
        halo.tag = REBORN_POWERUP_TAG;
        
        id animation = [ANIMATIONMANAGER getAnimationWithName:@"E_item_reborn_start"];
        
        if(animation != nil)
        {
            [halo stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [halo runAction:animAction];
        }

        [self.sprite addChild:halo z:-1];
        halo.position = ccp(halo.parent.contentSize.width/2,halo.parent.contentSize.height/2 + 3);
    }
    self.canReborn = YES;
    [self unschedule:@selector(rebornFinish)];
    [self scheduleOnce:@selector(rebornFinish) delay:10];
}

-(void) rebornFinish
{
    [self unschedule:@selector(rebornFinish)];
    
    //Flash effect
    [[GameUI shared] fadeOut];
    
    //remove mask
    [[GameUI shared] removeMask];
    
    //remove wing
    [[self.sprite getChildByTag:REBORN_POWERUP_TAG] removeFromParentAndCleanup:NO];

    //Play reborn finish animation
    [[EffectManager shared] PlayEffectWithName:@"FX_ReviveEnd" position:ccp(self.sprite.contentSize.width/2, self.sprite.contentSize.height/2) z:Z_Hero-1 parent:self.sprite];
    self.canReborn = NO;
}

-(void) reborn
{
    if (!isReborning)
    {
        //This line is added for the new reborn feature and rebornpowerup shouldn't
        //be called anywhere else
        [self rebornPowerup];
        
        isReborning = YES;
        
        //destroy objects on the screen
        [[LevelManager shared] destroyAllObjects];
        
        //stop dropping stuff for 4 sec
        [[LevelManager shared] stopDroppingForTime:4];
        
        //reset to the idle state
        [self idle];
        
        //change state to reborn
        self.heroState = HEROREBORN;
        
        id animation = [ANIMATIONMANAGER getAnimationWithName:@"H_happy"];
        
        if(animation != nil)
        {
            [self.sprite stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [self.sprite runAction:animAction];
        }
        
        //remove collision detection
        [self changeCollisionDetection:C_NOTHING];
        
        //pause physics simulation
        self.body->SetActive(false);
        self.body->SetAwake(false);
        self.body->SetLinearVelocity(b2Vec2(0,0));
        self.body->SetAngularVelocity(0);
        
        //add smoke effect
        CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_revive.ccbi" parent:GAMELAYER z:Z_Hero-1 duration:1.5 life:2.3 following:self.sprite];
        particleNode.position = self.sprite.position;
        //speed up background scroll
        [[BackgroundController shared] speedUpWithScale:3 interval:1.5];
        
        //move hero to the center of the screen
        id moveTo = [CCMoveTo actionWithDuration:1.5 position:ccp(150,350)];
        id ease = [CCEaseExponentialOut actionWithAction:moveTo];
        
        id moveTo2 = [CCMoveTo actionWithDuration:0.3 position:ccp(150,360)];
        id ease2 = [CCEaseSineInOut actionWithAction:moveTo2];
        
        //wing fade out animation
        id wingFadeoutAnim = [CCCallBlock actionWithBlock:^{
            [[self.sprite getChildByTag:REBORN_POWERUP_TAG] runAction:[CCFadeOut actionWithDuration:0.5]];
        }];
        
        id endingFunc = [CCCallFunc actionWithTarget:self selector:@selector(rebornEnding)];
        [self.sprite runAction:[CCSequence actions:ease, wingFadeoutAnim, ease2, endingFunc, nil]];
    }
}

//Called by reborn
-(void) rebornEnding
{
    //Set physic body to the center
    self.body->SetTransform(b2Vec2(self.sprite.position.x/RATIO, self.sprite.position.y/RATIO), 0);
    
    //reset physics simulation
    self.body->SetLinearVelocity(b2Vec2(0,0));
    self.body->SetActive(true);
    self.body->SetAwake(true);
    
    //reset collision detection
    [self resetCollisionDetection];
    isReborning = NO;
    
    //remove rebornEffect
    [self rebornFinish];
    
    //become idle again
    [self idle];
}

-(void) rocketPowerup:(float)duration
{
    float scale = self.sprite.scale;
    
    if (![self.heroState isEqualToString: HEROREBORN])
    {
        //Become idle except for reviving
        [self idle];
    
        //Hero becomes happy
        id animation = [ANIMATIONMANAGER getAnimationWithName:@"H_happy"];
        if(animation != nil)
        {
            [self.sprite stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [self.sprite runAction:animAction];
            self.heroState = @"happy";
        }
    }
    //Make it not collide with any objects except for the board
    [self changeCollisionDetection:C_BOARD];
    //Scale up Hero
    id scaleUp = [CCScaleTo actionWithDuration:0.3 scale:1.3*scale];
    //Set z value
    self.sprite.zOrder = Z_Hero + 10;
    //Countdown certain amount of time
    id delay = [CCDelayTime actionWithDuration: duration];
    //Reset the hero collision
    id resetCollision = [CCCallBlock actionWithBlock:^
                        {
                            [self resetCollisionDetection];
                        }];
    //Reset z value
    id resetHeroZ = [CCCallBlock actionWithBlock:^
                     {
                         self.sprite.zOrder = Z_Hero;
                     }];
    
    //hero back to Idle
    id heroIdle = [CCCallFunc actionWithTarget:self selector:@selector(idle)];
    
    //Scale down Hero to normal;
    id scaleDown = [CCScaleTo actionWithDuration:0.3 scale:scale];
    
    [self runAction:[CCSequence actions:scaleUp, delay, resetCollision, resetHeroZ, heroIdle, scaleDown, nil]];
}

-(void) absorbPowerup
{
    //Turn on absorb collision detection
    [self turnOnAbsorbCollisionDetection];
    
    //Create effect
    if (!isAbsorbing)
    {
        CCSprite *absorbEffect = [CCSprite spriteWithSpriteFrameName:@"E_item_coinstar_1.png"];
        absorbEffect.scale = 2;
        absorbEffect.tag = ABSORB_POWERUP_TAG;
        absorbEffect.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
        id animation = [ANIMATIONMANAGER getAnimationWithName:@"E_item_coinstar"];
        if(animation != nil)
        {
            [absorbEffect stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [absorbEffect runAction:animAction];
        }
        [self.sprite addChild:absorbEffect z:-1];
    }
    
    isAbsorbing = YES;
    
    //Wait for a certain amount of time
    id delay = [CCDelayTime actionWithDuration:[[POWERUP_DATA objectForKey:@"absorb"] floatValue]];
    //Remove effect
    id removeAbsorb = [CCCallBlock actionWithBlock:^
                       {
                           [[self.sprite getChildByTag:ABSORB_POWERUP_TAG] removeFromParentAndCleanup:NO];
                           //Remove absorb collision detection
                           [self removeAbsorbCollisionDetection];
                           isAbsorbing = NO;
                       }];
    CCSequence *sequence = [CCSequence actions:delay, removeAbsorb, nil];
    
    [self runAction:sequence];
}

-(void) sheildPowerup
{
    self.heroState = @"shelter";
    [self.sprite stopAllActions];
    id animation = [ANIMATIONMANAGER getAnimationWithName:@"H_shelter"];
    
    if(animation != nil)
    {
        id startAnimation = [CCCallBlock actionWithBlock:^{
            [self.sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
        }];
        id waitDelay = [CCDelayTime actionWithDuration:[[POWERUP_DATA objectForKey:@"shield"] floatValue]];
        id becomeIdle = [CCCallFunc actionWithTarget:self selector:@selector(idle)];
        
        id sequence = [CCSequence actions:startAnimation,waitDelay,becomeIdle, nil];
        [self.sprite runAction:sequence];
    }
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
                //DLog(@"%@", ((DUPhysicsObject *)contactEdge->contact->GetFixtureA()->GetUserData()).name);
                res = YES;
                break;
            }
        }
    }
    self.isOnGround = res;
}

-(void) changeCollisionDetection:(uint)maskBits
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        if ([((NSString *)f->GetUserData()) isEqualToString:@"heroBody"])
        {
            b2Filter filter;
            filter = f->GetFilterData();
            filter.maskBits = maskBits;
            f->SetFilterData(filter);
        }
    }
}

-(void) turnOnAbsorbCollisionDetection
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        if ([((NSString *)f->GetUserData()) isEqualToString:@"absorb"])
        {
            b2Filter filter;
            filter = f->GetFilterData();
            filter.maskBits = C_STAR;
            f->SetFilterData(filter);
        }
    }
}

-(void) removeAbsorbCollisionDetection
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        if ([((NSString *)f->GetUserData()) isEqualToString:@"absorb"])
        {
            b2Filter filter;
            filter = f->GetFilterData();
            filter.maskBits = C_NOTHING;
            f->SetFilterData(filter);
        }
    }
}

-(void) resetCollisionDetection
{
    for (b2Fixture* f = self.body->GetFixtureList(); f; f = f->GetNext())
    {
        if ([((NSString *)f->GetUserData()) isEqualToString:@"heroBody"])
        {
            b2Filter filter;
            filter = f->GetFilterData();
            filter.maskBits = C_HERO | C_BOARD | C_ADDTHING | C_STAR;
            f->SetFilterData(filter);
        }
    }
}

-(void) beforeDie
{
    //TODO: use user data
    if ([[POWERUP_DATA objectForKey:@"reborn"] intValue] > 0)
    {
        //Pause game
        [[[Hub shared] gameLayer] pauseGame];
        
        //Show revive button
        [[GameUI shared] showRebornButton];
    } else
    {
        //if has no revive
        [[[Hub shared] gameLayer] gameOver];
    }
}

#pragma mark -
#pragma mark ListenerHandler
-(void) onSwipeUpDetected:(UISwipeGestureRecognizer *)recognizer
{
}

-(void) deactivate
{
    [self idle];
    [self removeAllChildrenWithCleanup:NO];
    [self stopAllActions];
    [self removeContactListner];
    [super deactivate];
}

-(void) dealloc
{
    //    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    [super dealloc];
}

@end

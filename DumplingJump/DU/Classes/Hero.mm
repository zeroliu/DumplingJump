//
//  Hero.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//
#define ABSORB_POWERUP_TAG 10
#define REBORN_POWERUP_TAG 20
#define SHIELD_POWERUP_TAG 30
#define BLIND_EFFECT_TAG 35
#define HERO_FOREVER_ANIMATION_TAG 40

#import "Hero.h"
#import "AddthingObject.h"
#import "BackgroundController.h"
#import "LevelManager.h"
#import "BoardManager.h"
#import "EffectManager.h"
#import "GameModel.h"
#import "GameUI.h"
#import "DUEffectObject.h"
#import "InterReactionManager.h"
#import <Foundation/Foundation.h>

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
    BOOL hurtTrigger;
    BOOL isHeadStart;
    int boostStatus; //0 none, 1 ready, 2 start
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
@synthesize x=_x, y=_y, speed=_speed, acc=_acc, isOnGround=_isOnGround, heroState = _heroState, radius = _radius, mass = _mass, I = _I, fric = _fric, maxVx = _maxVx, maxVy = _maxVy, accValue = _accValue, jumpValue = _jumpValue, gravity = _gravity, canReborn = _canReborn, overlayHeroStateDictionary = _overlayHeroStateDictionary, isSpringBoost = _isSpringBoost, boostStatus;

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
        
        _overlayHeroStateDictionary = [[NSMutableDictionary alloc] init];
        
        [self initHeroParam];
        [self initHeroSpriteWithFile:@"H_hero_1.png" position:thePosition];
        [self initHeroPhysicsWithPosition:thePosition];
        [self initSpeed];
        [self initGestureHandler];
        [self initContactListener];
        [self resetHero];
        [self invulnerable];
    }
    
    return self;
}

-(void) invulnerable
{
    [self changeCollisionDetection:C_BOARD];
    id duration = [CCDelayTime actionWithDuration:0.5];
    id callback = [CCCallFunc actionWithTarget:self selector:@selector(resetHero)];
    [self.sprite runAction:[CCSequence actions:duration, callback, nil]];
}

-(void) initHeroParam
{
    self.isOnGround = NO;
    self.heroState = nil;
    isReborning = NO;
    isAbsorbing = NO;
    isHeadStart = NO;
    _isSpringBoost = NO;
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
            }
            else if (child.tag != TAG_HEADSTART_SUPPORT)
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
        if (_isSpringBoost)
        {
            [self removeHeroSpringEffect];
            id animation = [ANIMATIONMANAGER getAnimationWithName:HEROSPRING];
            if(animation != nil)
            {
                [self.sprite stopActionByTag:HERO_FOREVER_ANIMATION_TAG];
                CCRepeatForever *animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
                animAction.tag = HERO_FOREVER_ANIMATION_TAG;
                [self.sprite runAction:animAction];
            }
            _isSpringBoost = NO;
        }
    }
    lastVelocity = self.body->GetLinearVelocity();
}

-(void) updateHeroBoosterEffect
{
    //Ready phase, hero slowly moving back
    if ([self.heroState isEqualToString:@"booster"])
    {
        if (boostStatus == 0)
        {
            self.body->SetLinearVelocity(b2Vec2(0, -0.5));
        }
        else if (boostStatus == 1)
        {
            if (self.sprite.position.y > 650)
            {
                boostStatus = 2;
                [self boosterStart];
                return;
            }
            
            self.body->SetLinearVelocity(b2Vec2(self.speed.x, 30));
        }
        else if (boostStatus == 2)
        {
            //Fake floating effect
            if (self.sprite.position.y < 330)
            {
                self.body->SetLinearVelocity(b2Vec2(self.speed.x, 0));
            }
            else if (self.sprite.position.y > 340)
            {
                self.body->SetLinearVelocity(b2Vec2(self.speed.x, -10));
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
}

#pragma mark -
#pragma mark Movement

-(void) updateHeroPositionWithAccX:(float)accX
{
    //Set hero acceleration
    self.acc = b2Vec2(accX * self.accValue * adjustMove, 0);
    
    //Set hero speed
    float vX = self.body->GetLinearVelocity().x/[[[[WorldData shared] loadDataWithAttributName:@"hero"] objectForKey:@"velocityAccRatio"] floatValue] + self.acc.x;
    if (!hurtTrigger)
    {
        vX = [self calibrateVelocity:vX position:self.sprite.position.x];
    }
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
    
    if (maskNode != nil)
    {
        [maskNode updateSprite:ccp(self.sprite.position.x, self.sprite.position.y+self.radius*4)];
    }
}

-(float) calibrateVelocity:(float)originalVelocity position:(float)posX
{
    float center = [[CCDirector sharedDirector] winSize].width/2;
    float ratio = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"velocityCalibrationRatio"] floatValue];
    float minVelocity = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"minCalibrationVelocity"] floatValue];
    
    if ((originalVelocity > 0 && posX < center + center*(1-ratio)) ||
        (originalVelocity < 0 && posX > center - center*(1-ratio)))
    {
        return originalVelocity;
    }
    else if (originalVelocity > 0)
    {
        float x = 2 * center - center * ratio;
        float calibRatio = (minVelocity-1) / (center * ratio) / (center * ratio) * (posX - x) * (posX - x) + 1;
        return originalVelocity * MAX(calibRatio, minVelocity);
    }
    else if (originalVelocity < 0)
    {
        float calibRatio = (minVelocity-1) / (center * ratio) / (center * ratio) * (posX - center * ratio) * (posX - center * ratio) + 1;
        return originalVelocity * MAX(calibRatio, minVelocity);
    }
    
    return originalVelocity;
}

-(void) jump
{
    [self checkIfOnGround];
    if (self.isOnGround)
    {
        GAMEMODEL.jumpCount ++;
        [MESSAGECENTER postNotificationName:NOTIFICATION_JUMP object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.jumpCount] forKey:@"num"]];
        
        //Increase life jump count
        int currentJumpNum = [[USERDATA objectForKey:@"totalJump"] intValue];
        [USERDATA setObject:[NSNumber numberWithInt:currentJumpNum+1] forKey: @"totalJump"];
        [MESSAGECENTER postNotificationName:NOTIFICATION_LIFE_JUMP object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[[USERDATA objectForKey:@"totalJump"] intValue]] forKey:@"num"]];
        
        if ([self.heroState isEqualToString:@"spring"])
        {
            [self springJump];
        }
        else
        {
            [self normalJump];
        }
    }
}

-(void) normalJump
{
    if (self.isOnGround) self.body->SetLinearVelocity(b2Vec2(self.speed.x, self.jumpValue/RATIO * adjustJump));
}

-(void) springJump
{
    if (self.isOnGround && self.sprite.position.y < [CCDirector sharedDirector].winSize.height/2)
    {
        _isSpringBoost = YES;
        CCSprite *springBoostEffect = [CCSprite spriteWithSpriteFrameName:@"E_item_spring_1.png"];
        springBoostEffect.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
        id boostAnimation = [ANIMATIONMANAGER getAnimationWithName:SPRINGBOOSTEFFECT];
        if(boostAnimation != nil)
        {
            [springBoostEffect stopAllActions];
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:boostAnimation]];
            [springBoostEffect runAction:animAction];
        }
        
        if ([self.sprite getChildByTag:TAG_SPRING_BOOST] != nil)
        {
            [[self.sprite getChildByTag:TAG_SPRING_BOOST] removeFromParentAndCleanup:NO];
        }
        [self.sprite addChild:springBoostEffect z:-1 tag:TAG_SPRING_BOOST];
        
        id animation = [ANIMATIONMANAGER getAnimationWithName:SPRINGJUMP];
        if(animation != nil)
        {
            [self.sprite stopActionByTag:HERO_FOREVER_ANIMATION_TAG];
            CCRepeatForever *animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            animAction.tag = HERO_FOREVER_ANIMATION_TAG;
            [self.sprite runAction:animAction];
        }
        
        self.body->SetLinearVelocity(b2Vec2(self.speed.x, self.jumpValue * 1.15f/RATIO * adjustJump));
    }
}

- (void) removeHeroSpringEffect
{
    if ([self.sprite getChildByTag:TAG_SPRING_BOOST] != nil)
    {
        id fadeOutAnim = [CCFadeOut actionWithDuration:0.3];
        id destroyFunction = [CCCallBlock actionWithBlock:^{
            [[self.sprite getChildByTag:TAG_SPRING_BOOST] removeFromParentAndCleanup:NO];
        }];
        [[self.sprite getChildByTag:TAG_SPRING_BOOST] runAction:[CCSequence actions:fadeOutAnim, destroyFunction, nil]];
    }
}

-(void) shelterFin
{
    //Remove shield effect
    [self.sprite removeChildByTag:SHIELD_POWERUP_TAG cleanup:NO];
    
    //Remove shelter state
    [self.overlayHeroStateDictionary removeObjectForKey:@"shelter"];
    [self playCurrentFacialAnimation];
}

-(void) absorbFin
{
    //Remove absorb effect
    [self removeAbsorbCollisionDetection];
    isAbsorbing = NO;
    [self.sprite removeChildByTag:ABSORB_POWERUP_TAG cleanup:NO];
    
    //Remove absorb state
    [self.overlayHeroStateDictionary removeObjectForKey:@"absorb"];
    [self playCurrentFacialAnimation];
}

-(void) hurtFin
{
    //Remove hurt effect
    directionForce = b2Vec2(0,0);
    adjustJump = 1;
    adjustMove = 1;
    hurtTrigger = NO;
    //Change hero state back to idle
    self.heroState = @"idle";
    [self playCurrentFacialAnimation];
}

-(void) iceFin
{
    //Remove ice effect
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
    adjustJump = 1;
    adjustMove = 1;
    freezeTrigger = 0;
    
    //Change hero state back to idle
    self.heroState = @"idle";
    [self playCurrentFacialAnimation];
}

-(void) springFin
{
    //Remove spring effect
    _isSpringBoost = NO;
    [self removeHeroSpringEffect];
    
    //Change hero state back to idle
    self.heroState = @"idle";
    [self playCurrentFacialAnimation];
}

-(void) magicFin
{
    //Remove magic effect
    [self unschedule:@selector(fire)];
    
    //Change hero state back to idle
    self.heroState = @"idle";
    [self playCurrentFacialAnimation];
}

-(void) blindFin
{
    [self stopActionByTag:BLIND_EFFECT_TAG];
    //Remove blind mask
    if (maskNode != nil)
    {
        [maskNode removeMask];
        [maskNode release];
        maskNode = nil;
    }
    
    [self.overlayHeroStateDictionary removeObjectForKey:@"blind"];
    [self playCurrentFacialAnimation];
}

-(void) playCurrentFacialAnimation
{
    NSString *animationToPlay = nil;
    //If has main reaction
    if (![self.heroState isEqualToString:@"idle"])
    {
        animationToPlay = [[ReactionManager shared] getHeroReactAnimationName:self.heroState];
    }
    else
    {
        //if only has overlay reaction
        if ([self.overlayHeroStateDictionary count] > 0)
        {
            if ([self.overlayHeroStateDictionary objectForKey:@"blind"] != nil)
            {
                animationToPlay = @"H_blind";
            }
            else
            {
                animationToPlay = @"H_happy";
            }
        }
    }
    
    //If hero has no reaction
    if (animationToPlay == nil)
    {
        animationToPlay = @"H_hero";
    }
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:animationToPlay];
    id animAction = nil;
    if (animation != nil)
    {
        animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
    }
    else
    {
        animation = [ANIMATIONMANAGER getAnimationWithName:[[ReactionManager shared] getHeroReactAnimationName:HEROIDLE]];
        animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
    }
    [self.sprite stopAllActions];
    [self.sprite runAction:animAction];
}

- (void) resetHero
{
    self.heroState = @"idle";
    [self.overlayHeroStateDictionary removeAllObjects];
    
    [self.sprite stopAllActions];
    [self stopAllActions];
    
    [self resetCollisionDetection];
    
    //Play idle animation
    id animation = [ANIMATIONMANAGER getAnimationWithName:HEROIDLE];
    if(animation != nil)
    {
        [self.sprite stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
        [self.sprite runAction:animAction];
    }
    
    //Reset hero friction
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
    
    //Reset hero gravity
    self.body->SetGravityScale((self.gravity)/100.0f);
    
    //Reset the force on hero
    directionForce = b2Vec2(0,0);
    
    //Reset hero movement control
    adjustJump = 1;
    adjustMove = 1;
    freezeTrigger = 0;
    blowAwayTrigger = 0;
    boostStatus = 0;
    hurtTrigger = NO;
    
    //Unschedule fire
    [self unschedule:@selector(fire)];
    
    //Remove blind mask
    if (maskNode != nil)
    {
        [maskNode removeMask];
        [maskNode release];
        maskNode = nil;
    }
    
    [[self.sprite getChildByTag:TAG_SPRING_BOOST] removeFromParentAndCleanup:NO];
    [[self.sprite getChildByTag:ABSORB_POWERUP_TAG] removeFromParentAndCleanup:NO];
    [[self.sprite getChildByTag:SHIELD_POWERUP_TAG] removeFromParentAndCleanup:NO];
}

- (void) idle
{
    self.heroState = @"idle";
    /*
    id animation = [ANIMATIONMANAGER getAnimationWithName:HEROIDLE];
    
    if(animation != nil)
    {
        [self.sprite stopAllActions];
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

    [self unschedule:@selector(fire)];
    
    if (maskNode != nil)
    {
        [maskNode removeMask];
        [maskNode release];
        maskNode = nil;
    }
    
    [self removeHeroSpringEffect];
*/
}

-(void) hurt:(NSArray *)value
{
    int hurtValue = [[value objectAtIndex:0] intValue];
    AddthingObject *contactObject = [value objectAtIndex:1];
    
    //If hero is not idle, stop and become idle
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    //If hero is not blind
    if (![self.overlayHeroStateDictionary objectForKey:@"blind"])
    {
        //Play hurt animation
        [self playAnimation:@"H_hurt" duration:contactObject.reaction.reactionLasting callback:^{
            [self performSelector:@selector(hurtFin)];
        }];
    }
    else
    {
        //If hero is blind
        //Just remove the reaction after the reactionLasting
        id delay = [CCDelayTime actionWithDuration:contactObject.reaction.reactionLasting];
        id callback = [CCCallBlock actionWithBlock:^{
            [self performSelector:@selector(hurtFin)];
        }];
        [self.sprite runAction:[CCSequence actions:delay, callback, nil]];
    }
    
    self.heroState = @"hurt";
    
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
    
    hurtTrigger = YES;
}

-(void) bowEffect:(NSArray *)value
{
    //Blow hero
    if (![self.heroState isEqualToString:@"booster"])
    {
        CGPoint explosionPos = [[value objectAtIndex:0] CGPointValue];
        
        adjustJump = 0;
        adjustMove = 0;
        [self changeCollisionDetection:C_NOTHING];
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
}

-(void) flat:(NSArray *)value
{
    adjustJump = 0;
}

-(void) freeze:(NSArray *)value
{
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    AddthingObject *contactObject = [value lastObject];
    
    [self playAnimation:@"H_ice" duration:contactObject.reaction.reactionLasting callback:^{
        [self performSelector:@selector(iceFin)];
    }];
    
    self.heroState = @"ice";
    
    for ( b2Fixture* bodyFixture = self.body->GetFixtureList(); bodyFixture; bodyFixture = bodyFixture->GetNext())
    {
        bodyFixture->SetFriction(0);
    }
    
    for ( b2ContactEdge* contactEdge = self.body->GetContactList(); contactEdge; contactEdge = contactEdge->next )
    {
        contactEdge->contact->ResetFriction();
    }

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

-(void) spring:(NSArray *)value
{
    GAMEMODEL.useSpringCount ++;
    GAMEMODEL.powerCollectCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_SPRING object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useSpringCount] forKey:@"num"]];
    [MESSAGECENTER postNotificationName:NOTIFICATION_POWER_COLLECT object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.powerCollectCount] forKey:@"num"]];
    
    //If hero is not idle, stop and become idle
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"blind"] != nil)
    {
        [self performSelector:@selector(blindFin)];
    }
    
    [self playAnimation:@"H_spring" duration:[[POWERUP_DATA objectForKey:@"SPRING"] floatValue] callback:^{
        [self performSelector:@selector(springFin)];
    }];
    
    self.heroState = @"spring";
}

-(void) headStart
{
    GAMEMODEL.useHeadstartCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_HEADSTART object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useHeadstartCount] forKey:@"num"]];
    
    isHeadStart = YES;
    
    self.body->SetTransform(b2Vec2([CCDirector sharedDirector].winSize.width/2 / RATIO, -200/RATIO),0);
    [self playAnimationForever:@"H_happy"];
    
    boostStatus = 0;
    self.heroState = @"booster";
    
    //Create support
    CCSprite *headStartSupport = [CCSprite spriteWithSpriteFrameName:@"O_headstart_1.png"];
    headStartSupport.anchorPoint = ccp(0.5,1);
    headStartSupport.position = ccp(self.sprite.contentSize.width/2,8 );
    id supportAnimation = [ANIMATIONMANAGER getAnimationWithName:HEADSTART_SUPPORT];
    if(supportAnimation != nil)
    {
        [headStartSupport stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:supportAnimation]];
        [headStartSupport runAction:animAction];
    }
    
    if ([self.sprite getChildByTag:TAG_HEADSTART_SUPPORT] != nil)
    {
        [[self.sprite getChildByTag:TAG_HEADSTART_SUPPORT] removeFromParentAndCleanup:NO];
    }
    [self.sprite addChild:headStartSupport z:-1 tag:TAG_HEADSTART_SUPPORT];
    
    //Create aurora
    CCSprite *headStartBoostEffect = [CCSprite spriteWithSpriteFrameName:@"E_item_headstart_wave_1.png"];
    headStartBoostEffect.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
    id boostAnimation = [ANIMATIONMANAGER getAnimationWithName:HEADSTART_BOOST];
    if(boostAnimation != nil)
    {
        [headStartBoostEffect stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:boostAnimation]];
        [headStartBoostEffect runAction:animAction];
    }
    
    if ([self.sprite getChildByTag:TAG_HEADSTART_BOOST] != nil)
    {
        [[self.sprite getChildByTag:TAG_HEADSTART_BOOST] removeFromParentAndCleanup:NO];
    }
    [self.sprite addChild:headStartBoostEffect z:-2 tag:TAG_HEADSTART_BOOST];
    
    //Create trail
    CCSprite *headStartTrail = [CCSprite spriteWithSpriteFrameName:@"E_item_headstart_trail_1.png"];
    headStartTrail.scaleY = 25;
    headStartTrail.anchorPoint = ccp(0.5,1);
    headStartTrail.position = ccp(self.sprite.contentSize.width/2,0);
    id trailAnimation = [ANIMATIONMANAGER getAnimationWithName:HEADSTART_TRAIL];
    if(trailAnimation != nil)
    {
        [headStartTrail stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:trailAnimation]];
        [headStartTrail runAction:animAction];
    }
    
    if ([self.sprite getChildByTag:TAG_HEADSTART_TRAIL] != nil)
    {
        [[self.sprite getChildByTag:TAG_HEADSTART_TRAIL] removeFromParentAndCleanup:NO];
    }
    [self.sprite addChild:headStartTrail z:-3 tag:TAG_HEADSTART_TRAIL];
    
    [self changeCollisionDetection:C_STAR];
    [self boosterReady];
    [self boosterBackgroundStart];
}

-(float) getBoosterInterval
{
    if (isHeadStart)
    {
        return [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"headstartDuration"] floatValue];
    }
    else
    {
        return [[POWERUP_DATA objectForKey:@"BOOSTER"] floatValue];
    }
}

-(void) booster:(NSArray *)value;
{
    GAMEMODEL.useBoosterCount ++;
    GAMEMODEL.powerCollectCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_BOOSTER object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useBoosterCount] forKey:@"num"]];
    [MESSAGECENTER postNotificationName:NOTIFICATION_POWER_COLLECT object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.powerCollectCount] forKey:@"num"]];
    
    if (self.sprite.position.y < ((Board *)[[BoardManager shared] getBoard]).sprite.position.y)
    {
        [MESSAGECENTER postNotificationName:NOTIFICATION_BOOSTER_UNDER object:self];
    }
    
    //If hero is not idle, stop and become idle
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"blind"] != nil)
    {
        [self performSelector:@selector(blindFin)];
    }
    
    [self playAnimationForever:@"H_booster"];
    
    //Ready effect
    [[BackgroundController shared] speedUpWithScale:0.5 interval:0.5];
    [self changeCollisionDetection:C_STAR | C_ADDTHING];
    [self scheduleOnce:@selector(boosterReady) delay:1];
    [self scheduleOnce:@selector(boosterBackgroundStart) delay:0.8];
    
    boostStatus = 0;
    self.heroState = @"booster";
}

-(void) boosterBackgroundStart
{
    float interval = [self getBoosterInterval];
    [[BackgroundController shared] speedUpWithScale:5 interval:interval];
    [GAMEMODEL boostGameSpeed:interval];
}

-(void) boosterReady
{
    float interval = [self getBoosterInterval];
    boostStatus = 1;
    //Play speed line effect
    CCNode *particleNode = [[DUParticleManager shared] createParticleWithName:@"FX_speedline.ccbi" parent:GAMELAYER z:Z_Speedline duration: MAX(1, interval) life:1];
    particleNode.position = CGPointZero;
}

-(void) boosterStart
{
    boostStatus = 2;
    float interval = [self getBoosterInterval];
    [[[BoardManager shared] getBoard] boosterEffect];
    
    
    self.body->SetGravityScale(0);
    self.body->SetLinearVelocity(b2Vec2(0,0));
    [self scheduleOnce:@selector(boosterFin) delay:interval];
    [[[BoardManager shared] getBoard] scheduleOnce:@selector(boosterEnd) delay:interval-0.5];
}

-(void) boosterFin
{
    //Reset hero gravity
    self.body->SetGravityScale((self.gravity)/100.0f);
    
    //Reset hero movement control
    adjustJump = 1;
    adjustMove = 1;
    boostStatus = 0;
    
    [self resetCollisionDetection];
    [[EffectManager shared] PlayEffectWithName:@"FX_ReviveEnd" position:ccp(self.sprite.contentSize.width/2, self.sprite.contentSize.height/2) z:Z_Hero-1 parent:self.sprite];
    [self idle];
    
    if (isHeadStart)
    {
        isHeadStart = NO;
        id fadeOutAnim = [CCFadeOut actionWithDuration:0.3];
        id removeBoostFunc = [CCCallBlock actionWithBlock:^{
            [[self.sprite getChildByTag:TAG_HEADSTART_BOOST] removeFromParentAndCleanup:NO];
        }];
        id removeTrailFunc = [CCCallBlock actionWithBlock:^{
            [[self.sprite getChildByTag:TAG_HEADSTART_TRAIL] removeFromParentAndCleanup:NO];
        }];
        id removeSupportFunc = [CCCallBlock actionWithBlock:^{
            [[self.sprite getChildByTag:TAG_HEADSTART_SUPPORT] removeFromParentAndCleanup:NO];
        }];
        
        [[self.sprite getChildByTag:TAG_HEADSTART_BOOST] runAction:[CCSequence actions:fadeOutAnim, removeBoostFunc, nil]];
        [[self.sprite getChildByTag:TAG_HEADSTART_TRAIL] runAction:[CCSequence actions:fadeOutAnim, removeTrailFunc, nil]];
        [[self.sprite getChildByTag:TAG_HEADSTART_SUPPORT] runAction:[CCSequence actions:fadeOutAnim, removeSupportFunc, nil]];
    }
    
    //Change hero state back to idle
    self.heroState = @"idle";
    [self playCurrentFacialAnimation];
}

-(void) magic:(NSArray *)value;
{
    GAMEMODEL.useMagicCount ++;
    GAMEMODEL.powerCollectCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_MAGIC object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useMagicCount] forKey:@"num"]];
    [MESSAGECENTER postNotificationName:NOTIFICATION_POWER_COLLECT object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.powerCollectCount] forKey:@"num"]];
    
    //If hero is not idle, stop and become idle
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"blind"] != nil)
    {
        [self performSelector:@selector(blindFin)];
    }
    
    [self playAnimation:@"H_magic" duration:[[POWERUP_DATA objectForKey:@"MAGIC"] floatValue] callback:^{
        [self performSelector:@selector(magicFin)];
    }];
    
    [self schedule:@selector(fire) interval:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"magicFrequence"] floatValue]];
    
    self.heroState = @"magic";
}

-(void) blind:(NSArray *)value
{
    AddthingObject *contactObject = [value lastObject];
    
    //If hero is not idle, stop and become idle
    if (![self.heroState isEqualToString:@"idle"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"blind"] == nil)
    {
        [self playAnimationForever:@"H_blind"];
        
        CCSprite *blackBg = [CCSprite spriteWithFile:@"blackbg.png"];
        CCSprite *mask = [CCSprite spriteWithFile:@"mask.png"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        maskNode = [[CircleMask alloc] initWithTexture:[blackBg retain] Mask:[mask retain]];
        CCSprite *final = [maskNode maskedSpriteWithSprite: ccp(self.sprite.position.x, self.sprite.position.y+self.radius*4)];
        final.position = ccp(winSize.width/2,winSize.height/2);
        [GAMELAYER addChild:final z:10];
    }
    else
    {
        //Already blind
        
    }
    
    [self stopActionByTag:BLIND_EFFECT_TAG];
    id delay = [CCDelayTime actionWithDuration:contactObject.reaction.reactionLasting];
    id callback = [CCCallBlock actionWithBlock:^{
        [self performSelector:@selector(blindFin)];
    }];
    CCSequence *sequence = [CCSequence actions:delay, callback, nil];
    sequence.tag = BLIND_EFFECT_TAG;
    [self runAction:sequence];

    [self.overlayHeroStateDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"blind"];
    
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
        if ([self.heroState isEqualToString:@"idle"] && [self.overlayHeroStateDictionary count] == 0)
        {
            [self playAnimation:@"H_happy" duration:1 callback:^{
                [self playCurrentFacialAnimation];
            }];
        }
        
        float addStarNum = [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"starMultiplier"] floatValue];
        [GAMEMODEL addStarWithNum:addStarNum];
        [[GameUI shared] updateStar:((GameLayer *)GAMELAYER).model.star];
        [star removeAddthing];
        [[LevelManager shared] generateFlyingStarAtPosition:star.sprite.position destination: [[GameUI shared] getStarDestination]];
    }
}

-(void) megastar:(NSArray *)value
{
    if ([self.heroState isEqualToString:@"idle"] && [self.overlayHeroStateDictionary count] == 0)
    {
        [self playAnimation:@"H_happy" duration:1 callback:^{
            [self playCurrentFacialAnimation];
        }];
    }
    
    AddthingObject *megastar = [value objectAtIndex:1];
    GAMEMODEL.eatMegaStarCount ++;
    [GAMEMODEL addStarWithNum:[[POWERUP_DATA objectForKey:@"MEGA"] intValue]];
    [MESSAGECENTER postNotificationName:NOTIFICATION_MEGASTAR object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.eatMegaStarCount] forKey:@"num"]];
    
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
        GAMEMODEL.useRebornCount ++;
        [MESSAGECENTER postNotificationName:NOTIFICATION_REBORN object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useRebornCount] forKey:@"num"]];
        
        //This line is added for the new reborn feature and rebornpowerup shouldn't
        //be called anywhere else
        [self rebornPowerup];
        
        isReborning = YES;
        
        //destroy objects on the screen
        [[LevelManager shared] destroyAllObjects];
        
        //stop dropping stuff for 4 sec
        [[LevelManager shared] stopDroppingForTime:4];
        
        //reset to the idle state
        [self resetHero];
        
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
    [self resetHero];
}

//Warning: This function is not being used
-(void) rocketPowerup:(float)duration
{
    float scale = self.sprite.scale;
    
    if (![self.heroState isEqualToString: HEROREBORN])
    {
        //Become idle except for reviving
        [self resetHero];
    
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
    id heroIdle = [CCCallFunc actionWithTarget:self selector:@selector(resetHero)];
    
    //Scale down Hero to normal;
    id scaleDown = [CCScaleTo actionWithDuration:0.3 scale:scale];
    
    [self runAction:[CCSequence actions:scaleUp, delay, resetCollision, resetHeroZ, heroIdle, scaleDown, nil]];
}

-(void) absorbPowerup
{
    GAMEMODEL.useMagnetCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_MAGNET object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useMagnetCount] forKey:@"num"]];
    
    if (![self.heroState isEqualToString:@"idle"] && [[[InterReactionManager shared] getInterReactionByAddthingName:@"ABSORB" forHeroStatus:self.heroState] isEqualToString:@"covered"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
        [self playAnimationForever:@"H_happy"];
    }
    else if ([self.heroState isEqualToString:@"idle"] && [self.overlayHeroStateDictionary count] == 0)
    {
        [self playAnimationForever:@"H_happy"];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"absorb"] != nil)
    {
        [self performSelector:@selector(absorbFin)];
    }
    [self.overlayHeroStateDictionary setObject:[NSNumber numberWithBool:YES] forKey: @"absorb"];
    
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
    id delay = [CCDelayTime actionWithDuration:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"absorbDuration"] floatValue]];
    //Remove effect
    id removeAbsorb = [CCCallBlock actionWithBlock:^
                       {
                           [self absorbFin];
                       }];
    CCSequence *sequence = [CCSequence actions:delay, removeAbsorb, nil];
    
    [self runAction:sequence];
}

-(void) shieldPowerup
{
    GAMEMODEL.useShieldCount ++;
    [MESSAGECENTER postNotificationName:NOTIFICATION_SHIELD object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:GAMEMODEL.useShieldCount] forKey:@"num"]];
    
    //if hero has main reaction
    if (![self.heroState isEqualToString:@"idle"] && [[[InterReactionManager shared] getInterReactionByAddthingName:@"SHELTER" forHeroStatus:self.heroState] isEqualToString:@"covered"])
    {
        SEL stopReactionSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Fin", self.heroState]);
        [self performSelector:stopReactionSelector];
        [self playAnimationForever:@"H_happy"];
    }
    else if ([self.heroState isEqualToString:@"idle"] && [self.overlayHeroStateDictionary count] == 0)
    {
        [self playAnimationForever:@"H_happy"];
    }
    
    if ([self.overlayHeroStateDictionary objectForKey:@"shelter"] != nil)
    {
        [self performSelector:@selector(shelterFin)];
    }
    [self.overlayHeroStateDictionary setObject:[NSNumber numberWithBool:YES] forKey: @"shelter"];
    
    //Create shield effect
    CCSprite *shieldEffect = [CCSprite spriteWithSpriteFrameName:@"E_item_shield_1.png"];
    shieldEffect.tag = SHIELD_POWERUP_TAG;
    shieldEffect.scale = 1.2;
    shieldEffect.position = ccp(self.sprite.contentSize.width/2,self.sprite.contentSize.height/2);
    id animationShield = [ANIMATIONMANAGER getAnimationWithName:@"E_item_shield"];
    if(animationShield != nil)
    {
        [shieldEffect stopAllActions];
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animationShield]];
        [shieldEffect runAction:animAction];
    }
    [self.sprite addChild:shieldEffect z:1];
    
    id waitDelay = [CCDelayTime actionWithDuration:[[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"shieldDuration"] floatValue]];
    id removeSheild = [CCCallFunc actionWithTarget:self selector:@selector(shelterFin)];
    
    CCSequence *sequence = [CCSequence actions:waitDelay, removeSheild, nil];
    
    [self runAction:sequence];
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

-(void) changeCollisionDetection:(uint)maskBits
{
    DLog(@"changeCollision to %d", maskBits);
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
    DLog(@"reset collision");
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
    if ([[USERDATA objectForKey:@"reborn"] intValue] > 0)
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

-(BOOL) isShelterOn
{
    BOOL result = NO;
    for (NSString *status in _overlayHeroStateDictionary)
    {
        if ([status isEqualToString:@"shelter"])
        {
            result = YES;
            break;
        }
    }
    return result;
}

-(BOOL) isBoosterOn
{
    return [self.heroState isEqualToString:@"booster"];
}

-(void) playAnimationForever:(NSString *)animName
{
    id animation = [ANIMATIONMANAGER getAnimationWithName:animName];
    if(animation != nil)
    {
        CCRepeatForever *animAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        animAction.tag = HERO_FOREVER_ANIMATION_TAG;
        [self.sprite stopAllActions];
        [self.sprite runAction:animAction];
    }
}

-(void) playAnimation:(NSString *)animName duration:(float)time callback:(void(^)())block
{
    [self playAnimationForever:animName];
    id delay = [CCDelayTime actionWithDuration:time];
    id callbackFunc = [CCCallBlock actionWithBlock:block];
    [self.sprite runAction:[CCSequence actions:delay, callbackFunc, nil]];
}

#pragma mark -
#pragma mark ListenerHandler
-(void) onSwipeUpDetected:(UISwipeGestureRecognizer *)recognizer
{
}

-(void) deactivate
{
//    [self resetHero];
    [self removeAllChildrenWithCleanup:NO];
    [self stopAllActions];
    [self removeContactListner];
    [super deactivate];
}

-(void) dealloc
{
    [_heroState release];
    _heroState = nil;
    [_overlayHeroStateDictionary release];
    _overlayHeroStateDictionary = nil;
    [super dealloc];
}

@end

#import "HeroManager.h"
#import "ReactionFunctions.h"
#import "DUObjectsDictionary.h"

#define HERO_RADIUS 13.0f
#define HERO_MASS 13.0f
#define HERO_I 1.0f
#define HERO_FRIC 0.6f
#define HERO_MAX_VX 5.0f
#define HERO_MAX_VY 26.0f
#define HERO_ACC 1.56f
#define HERO_JUMP 400.0f
#define HERO_GRAVITY 150.0f

@implementation HeroManager
@synthesize hero = _hero, heroRadius = _heroRadius, heroMass = _heroMass, heroI = _heroI, heroMaxVx = _heroMaxVx, heroMaxVy = _heroMaxVy, heroAcc = _heroAcc, heroJump = _heroJump, heroGravity = _heroGravity;
#pragma mark -
#pragma Initialization

+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[HeroManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        self.heroRadius = HERO_RADIUS;
        self.heroMass = HERO_MASS;
        self.heroI = HERO_I;
        self.heroFric = HERO_FRIC;
        self.heroMaxVx = HERO_MAX_VX;
        self.heroMaxVy = HERO_MAX_VY;
        self.heroAcc = HERO_ACC;
        self.heroJump = HERO_JUMP;
        self.heroGravity = HERO_GRAVITY;
        [ANIMATIONMANAGER registerAnimationForName:HEROIDLE];
    }
    return self;
}

-(id)createHeroWithPosition:(CGPoint)thePosition
{
    if (self.hero != nil)
    {
        [self.hero removeFromParentAndCleanup:NO];
        [self.hero remove];
        self.hero = nil;
//        [[DUObjectsDictionary sharedDictionary] cleanObjectByName:HERO];
    }
    self.hero = [[Hero alloc] initHeroWithName:HERO position:thePosition radius:self.heroRadius mass:self.heroMass I:self.heroI fric:self.heroFric maxVx:self.heroMaxVx maxVy:self.heroMaxVy accValue:self.heroAcc jumpValue:self.heroJump gravityValue:self.heroGravity];
    //Add hero sprite to BATCHNODE
    [self.hero addChildTo:BATCHNODE z:5];
    //Add hero object to GameLayer
    [GAMELAYER addChild:self.hero];
    [self.hero idle];
    
    return self.hero;
}

-(id)getHero
{
    if (self.hero != nil)
    {
        return self.hero;
    }
    return [self createHeroWithPosition:ccp(300,500)];
}

-(void) playAnimationWithName:(NSString *)animName delay:(float)theDelay
{
    if (self.hero == nil) return;
    
    [self.hero.sprite stopAllActions];
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:animName];
    
    if(animation != nil)
    {
        id startAnimation = [CCCallFuncND actionWithTarget:self selector:@selector(playAnimationForever:data:) data:animName];
        id waitDelay = [CCDelayTime actionWithDuration:theDelay];
        id becomeIdle = [CCCallFunc actionWithTarget:self.hero selector:@selector(idle)];
        
        id sequence = [CCSequence actions:startAnimation,waitDelay,becomeIdle, nil];
        [self.hero.sprite runAction:sequence];
    }
}

-(void) playAnimationForever:(id)sender data:(void *)animName
{
    id animation = [ANIMATIONMANAGER getAnimationWithName:(NSString *)animName];
    if(animation != nil)
    {
        id animAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        [self.hero.sprite runAction:animAction];
    }
}

-(void) updateHeroPosition
{
    [self.hero updateHeroPositionWithAccX:[[AccelerometerManager shared] accX]];
}

-(void) heroReactWithReaction:(Reaction *)theReaction contactObject:(DUPhysicsObject *)theContactObject
{
    if (self.hero.heroState != theReaction.name && theReaction.reactHeroSelectorName != nil)
    {
        self.hero.heroState = theReaction.name;
        if (theReaction.heroReactAnimationName != nil)
        {
            if (theReaction.reactionLasting <= 0)
            {
                [self playAnimationWithName:theReaction.heroReactAnimationName delay:2];
            } else
            {
                [self playAnimationWithName:theReaction.heroReactAnimationName delay:theReaction.reactionLasting];
            }
        }
        
        if (theReaction.reactHeroSelectorParam == nil)
        {
            SEL callback = NSSelectorFromString(theReaction.reactHeroSelectorName);
            
            [self.hero performSelector:callback];
        } else {
            SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:", theReaction.reactHeroSelectorName]);
            [self.hero performSelector:callback withObject: [NSArray arrayWithObjects:theReaction.reactHeroSelectorParam, theContactObject, nil]];
        }
        
        if ([theReaction.name isEqualToString:@"SHELTER"] || [theReaction.name isEqualToString:@"MAGIC"] || [theReaction.name isEqualToString:@"SPRING"])
        {
            self.hero.powerup = theReaction.name;
            self.hero.powerupCountdown = theReaction.reactionLasting - 0.1f;
        }
    }
}

-(void) heroReactWithReactionName:(NSString *)theName heroAnimName:(NSString *)animName reactionLasting:(float)duration heroSelectorName:(NSString *)selectorName heroSelectorParam:(id) param
{
    if (self.hero.heroState != theName && selectorName != nil)
    {
        self.hero.heroState = theName;
        if (animName != nil)
        {
            if (duration <= 0)
            {
                [self playAnimationWithName:animName delay:2];
            } else
            {
                [self playAnimationWithName:animName delay:duration];
            }
        }
        
        if (param == nil)
        {
            SEL callback = NSSelectorFromString(selectorName);
            
            [self.hero performSelector:callback];
        } else {
            SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:", selectorName]);
            [self.hero performSelector:callback withObject: [NSArray arrayWithObjects:param, nil]];
        }
    }
}




@end

#import "HeroManager.h"
#import "ReactionFunctions.h"
#import "DUObjectsDictionary.h"
#import "GameModel.h"

#define HERO_RADIUS @"heroRadius"
#define HERO_MASS @"heroMass"
#define HERO_I @"heroI"
#define HERO_FRIC @"heroFric"
#define HERO_MAX_VX @"heroMaxVx"
#define HERO_MAX_VY @"heroMaxVy"
#define HERO_ACC @"heroAcc"
#define HERO_JUMP @"heroJump"
#define HERO_GRAVITY @"heroGravity"

@implementation HeroManager
@synthesize hero = _hero, heroRadius = _heroRadius, heroMass = _heroMass, heroI = _heroI, heroFric = _heroFric, heroMaxVx = _heroMaxVx, heroMaxVy = _heroMaxVy, heroAcc = _heroAcc, heroJump = _heroJump, heroGravity = _heroGravity;
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
        NSDictionary *heroInitData = [[WorldData shared] loadDataWithAttributName:@"hero"];
        
        self.heroRadius = [[heroInitData objectForKey:HERO_RADIUS] floatValue];
        self.heroMass = [[heroInitData objectForKey:HERO_MASS] floatValue];
        self.heroI = [[heroInitData objectForKey:HERO_I] floatValue];
        self.heroFric = [[heroInitData objectForKey:HERO_FRIC] floatValue];
        self.heroMaxVx = [[heroInitData objectForKey:HERO_MAX_VX] floatValue];
        self.heroMaxVy = [[heroInitData objectForKey:HERO_MAX_VY] floatValue];
        self.heroAcc = [[heroInitData objectForKey:HERO_ACC] floatValue];
        self.heroJump = [[heroInitData objectForKey:HERO_JUMP] floatValue];
        self.heroGravity = [[heroInitData objectForKey:HERO_GRAVITY] floatValue];
        [ANIMATIONMANAGER registerAnimationForName:HEROIDLE];
        [ANIMATIONMANAGER registerAnimationForName:@"H_happy"];
        [ANIMATIONMANAGER registerAnimationForName:@"E_item_reborn_start"];
        [ANIMATIONMANAGER registerAnimationForName:@"E_item_coinstar"];
        [ANIMATIONMANAGER registerAnimationForName:SPRINGJUMP];
        [ANIMATIONMANAGER registerAnimationForName:SPRINGBOOSTEFFECT];
        [ANIMATIONMANAGER registerAnimationForName:HEADSTART_BOOST];
        [ANIMATIONMANAGER registerAnimationForName:HEADSTART_TRAIL];
        [ANIMATIONMANAGER registerAnimationForName:HEADSTART_SUPPORT];
        
    }
    return self;
}

-(id)createHeroWithPosition:(CGPoint)thePosition
{
    if (self.hero != nil)
    {
        [self.hero removeFromParentAndCleanup:NO];
        [self.hero archive];
        self.hero = nil;
//        [[DUObjectsDictionary sharedDictionary] cleanObjectByName:HERO];
    }
    
    self.hero = [[Hero alloc] initHeroWithName:HERO position:thePosition radius:self.heroRadius mass:self.heroMass I:self.heroI fric:self.heroFric maxVx:self.heroMaxVx maxVy:self.heroMaxVy accValue:self.heroAcc jumpValue:self.heroJump gravityValue:self.heroGravity];
    //Add hero sprite to BATCHNODE
    [self.hero addChildTo:BATCHNODE z:Z_Hero];
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
            if ([theReaction.name isEqualToString:@"booster"])
            {
                //Play animation without stop for special case, will handle stop time by plist data
                [self.hero.sprite stopAllActions];
                id animation = [ANIMATIONMANAGER getAnimationWithName:theReaction.heroReactAnimationName];
                if(animation != nil)
                {
                    id animAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
                    [self.hero.sprite runAction:animAction];
                }
            }
            else
            {
                if (theReaction.reactionLasting <= 0)
                {
                    [self playAnimationWithName:theReaction.heroReactAnimationName delay:2];
                }
                else
                {
                    [self playAnimationWithName:theReaction.heroReactAnimationName delay:theReaction.reactionLasting];
                }
            }
        }
        
        if (theReaction.reactHeroSelectorParam == nil)
        {
            SEL callback = NSSelectorFromString(theReaction.reactHeroSelectorName);
            [self.hero performSelector:callback];
        }
        else
        {
            SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:", theReaction.reactHeroSelectorName]);
            [self.hero performSelector:callback withObject: [NSArray arrayWithObjects:theReaction.reactHeroSelectorParam, theContactObject, nil]];
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

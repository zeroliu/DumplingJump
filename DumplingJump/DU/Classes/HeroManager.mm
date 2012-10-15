#import "HeroManager.h"
#import "ReactionFunctions.h"

@implementation HeroManager
@synthesize hero = _hero;
#pragma mark -
#pragma Initialization

-(id)createHeroWithPosition:(CGPoint)thePosition
{
    if (self.hero != nil) [self.hero release];
    self.hero = [[Hero alloc] initHeroWithName:HERO position:thePosition];
    [self.hero addChildTo:BATCHNODE];
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
//        id animAction = [CCAnimate actionWithAnimation:animation];
//        [animAction setRepeatDuration:theDelay];
        
//        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];

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
    if (self.hero.heroState != theReaction.name)
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
        
        if (theReaction.reactHeroSelectorName != nil)
        {
            if (theReaction.reactHeroSelectorParam == nil)
            {
                SEL callback = NSSelectorFromString(theReaction.reactHeroSelectorName);
                
                [self.hero performSelector:callback];
            } else {
                SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:", theReaction.reactHeroSelectorName]);
                [self.hero performSelector:callback withObject: [NSArray arrayWithObjects:theReaction.reactHeroSelectorParam, theContactObject, nil]];
            }
        }
    }
}


@end

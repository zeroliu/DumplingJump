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

-(void) playAnimationWithName:(NSString *)animName
{
    if (self.hero == nil) return;
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:animName];
    
    if(animation != nil)
    {
        id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
        
        [self.hero.sprite runAction:animAction];
    }
}

-(void) updateHeroPosition
{
    [self.hero updateHeroPositionWithAccX:[[AccelerometerManager shared] accX]];
}

-(void) heroReactWithReaction:(Reaction *)theReaction
{
    if (self.hero.heroState != theReaction.name)
    {
        self.hero.heroState = theReaction.name;
        if (theReaction.heroReactAnimationName != nil)
        {
            [self playAnimationWithName:theReaction.heroReactAnimationName];
        }
        
        if (theReaction.reactHeroSelectorName != nil)
        {
            if (theReaction.reactHeroSelectorParam == nil)
            {
                SEL callback = NSSelectorFromString(theReaction.reactHeroSelectorName);
                
                [self.hero performSelector:callback];
            } else {
                SEL callback = NSSelectorFromString([NSString stringWithFormat:@"%@:", theReaction.reactHeroSelectorName]);
                [self.hero performSelector:callback withObject:theReaction.reactHeroSelectorParam];
            }
        }
    }
}


@end

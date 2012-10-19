#import "Common.h"
#import "Hero.h"

@interface HeroManager : NSObject

@property (nonatomic, retain) Hero *hero; 

+(id)shared;
-(id)createHeroWithPosition:(CGPoint)thePosition;
-(id)getHero;
-(void) updateHeroPosition;
-(void) heroReactWithReaction:(Reaction *)theReaction contactObject:(DUPhysicsObject *)theContactObject;


-(void) playAnimationWithName:(NSString *)animName delay:(float)theDelay;

@end

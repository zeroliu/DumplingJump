#import "Common.h"
#import "Hero.h"

@interface HeroManager : NSObject

@property (nonatomic, retain) Hero *hero; 

-(id)createHeroWithPosition:(CGPoint)thePosition;
-(void) updateHeroPosition;
-(void) heroReactWithReaction:(Reaction *)theReaction contactObject:(DUPhysicsObject *)theContactObject;


-(void) playAnimationWithName:(NSString *)animName delay:(float)theDelay;

@end

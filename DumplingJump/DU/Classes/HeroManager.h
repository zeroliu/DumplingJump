#import "Common.h"
#import "Hero.h"

@interface HeroManager : NSObject

@property (nonatomic, retain) Hero *hero; 
@property (nonatomic, assign) float heroRadius;
+(id)shared;
-(id)createHeroWithPosition:(CGPoint)thePosition;
-(id)getHero;
-(void) updateHeroPosition;
//This function is used by addthingObject->contact
-(void) heroReactWithReaction:(Reaction *)theReaction contactObject:(DUPhysicsObject *)theContactObject;
//This function is used by reactionFuctions
-(void) heroReactWithReactionName:(NSString *)theName heroAnimName:(NSString *)animName reactionLasting:(float)duration heroSelectorName:(NSString *)selectorName heroSelectorParam:(id) param;

-(void) playAnimationWithName:(NSString *)animName delay:(float)theDelay;

@end

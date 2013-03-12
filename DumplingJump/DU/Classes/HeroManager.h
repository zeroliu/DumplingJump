#import "Common.h"
#import "Hero.h"
#import "AddthingObject.h"

@interface HeroManager : NSObject

@property (nonatomic, retain) Hero *hero; 
@property (nonatomic, assign) float heroRadius;
@property (nonatomic, assign) float heroMass;
@property (nonatomic, assign) float heroI;
@property (nonatomic, assign) float heroFric;
@property (nonatomic, assign) float heroMaxVx;
@property (nonatomic, assign) float heroMaxVy;
@property (nonatomic, assign) float heroAcc;
@property (nonatomic, assign) float heroJump;
@property (nonatomic, assign) float heroGravity;

+(id)shared;
-(id)createHeroWithPosition:(CGPoint)thePosition;
-(id)getHero;
-(void) updateHeroPosition;
//This function is used by addthingObject->contact
-(void) heroReactWithReaction:(Reaction *)theReaction contactObject:(AddthingObject *)theContactObject;
//This function is used by reactionFuctions
-(void) heroReactWithReactionName:(NSString *)theName heroAnimName:(NSString *)animName reactionLasting:(float)duration heroSelectorName:(NSString *)selectorName heroSelectorParam:(id) param;

-(void) playAnimationWithName:(NSString *)animName delay:(float)theDelay;

@end

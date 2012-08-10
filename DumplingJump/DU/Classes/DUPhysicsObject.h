#import "DUSprite.h"
#import "Box2D.h"

@interface DUPhysicsObject : DUSprite
@property (nonatomic, assign) b2Body *body;
-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody;
-(void) resetPhysicsBodyPosition;
-(void) setUserData:(id)data;
@end

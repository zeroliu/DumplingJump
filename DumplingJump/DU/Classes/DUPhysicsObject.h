#import "DUSprite.h"
#import "Box2D.h"

@interface DUPhysicsObject : DUSprite
@property (nonatomic, assign) b2Body *body;
-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody;
-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL) resize;
-(void) resetPhysicsBodyPosition;
-(void) setUserData:(id)data;
@end

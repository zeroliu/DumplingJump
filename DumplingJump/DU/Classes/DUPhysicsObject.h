#import "DUSprite.h"
#import "Box2D.h"

@interface DUPhysicsObject : DUSprite
{
    b2Body *body;
}

-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody;
-(void) activate;
-(void) deactivate;
-(void) resetPhysicsBody;

@end

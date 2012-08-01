#import "DUPhysicsObject.h"
#import "DUObjectsDictionary.h"

/* 
 * DUFactory is used to create the new DUObjects using DUCache feature
 * This is a ABSTRACT class
 * For specific objects, you should inherit from this class and create your own factory
 */

@interface DUFactory : NSObject
{
    NSString *name;
}

-(id) initWithName:(NSString *)theName;
-(id) create;

-(id) createNewObject;
-(id) reuseOldObject;
@end

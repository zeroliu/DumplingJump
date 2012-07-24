#import "cocos2d.h"
#import "DUObjectsDictionary.h"
#import "DUObject.h"
#import "DUSprite.h"
#import "DUPhysicsObject.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


@interface DUObjectsFactory: NSObject
+(id) createObjectWithName:(NSString *)theName;
+(id) createSpriteWithName:(NSString *)theName file:(NSString *)theFile;
+(id) createPhysicsWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody;
@end

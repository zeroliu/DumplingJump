#import "cocos2d.h"
@class DUObject;

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

@interface DUObjectsDictionary : NSObject
{
    NSMutableDictionary *DUDictionary;
}

+(id) sharedDictionary;
-(BOOL) containsDUObject:(NSString *)theName;
-(id) getDUObjectbyName:(NSString *)theName;
-(void) addDUObject:(DUObject *)theObject;

-(NSString *) printDictionary;

@end

#import "cocos2d.h"
@class DUObject;

@interface DUObjectsDictionary : CCNode
{
    NSMutableDictionary *DUDictionary;
}

+(id) sharedDictionary;
-(BOOL) containsDUObject:(NSString *)theName;
-(id) getDUObjectbyName:(NSString *)theName;
-(void) addDUObject:(DUObject *)theObject;

-(NSString *) printDictionary;

@end

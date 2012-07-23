#import "Common.h"

@interface DUObjectsManager : CCNode
{
    NSMutableDictionary *objectsDict;
}

+(id) shared;
  
-(void) addObjectWithName:(NSString *)theName;
@end

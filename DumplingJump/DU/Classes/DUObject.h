#import "cocos2d.h"
#import "DUObjectsDictionary.h"

@interface DUObject : NSObject
{
    NSString *name;
}
@property (readonly, nonatomic) NSString *name;

-(id) initWithName:(NSString *)theName;
-(void) archive;
@end
#import "cocos2d.h"
#import "DUObjectsDictionary.h"

@interface DUObject : NSObject
{
    NSString *name;
    BOOL rebuilt;
}
@property (readonly, nonatomic) NSString *name;
@property (nonatomic, assign) BOOL rebuilt;

-(id) initWithName:(NSString *)theName;
-(void) archive;
@end
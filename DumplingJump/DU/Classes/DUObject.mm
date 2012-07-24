#import "DUObject.h"

@implementation DUObject
@synthesize name,rebuilt;

-(id)initWithName:(NSString *)theName
{
    if (self = [super init])
    {
        name = theName;
    }
    
    return self;
}

-(void) archive
{
    [[DUObjectsDictionary sharedDictionary] addDUObject:self];
}
@end

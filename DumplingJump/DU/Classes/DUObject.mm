#import "DUObject.h"

@implementation DUObject
@synthesize name;

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

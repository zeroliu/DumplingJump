#import "DUObject.h"

@implementation DUObject
@synthesize name = _name,rebuilt = _rebuilt, archived = _archived, ID = _ID;

-(id)initWithName:(NSString *)theName
{
    if (self = [super init])
    {
        self.name = theName;
        self.ID = theName;
        self.rebuilt = NO;
        self.archived = NO;
    }
    
    return self;
}

-(void) archive
{
    self.archived = YES;
    [self deactivate];
    
    DLog(@"before release %@ count:%d [1]", self.name, [self retainCount]);
    
    [self release];
    //[[DUObjectsDictionary sharedDictionary] addDUObject:self];
}

-(void) remove
{
    [self deactivate];
    [self release];
}

-(void) activate
{
    self.archived = NO;
}

-(void) deactivate
{
    self.rebuilt = YES;
//    NSLog(@"call DUObject deactive");
}
@end

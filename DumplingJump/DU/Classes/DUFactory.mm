#import "DUFactory.h"

@implementation DUFactory

-(id) initWithName:(NSString *)theName;
{
    if (self = [super init]) {
        name = theName;
    }
    
    return self;
}

-(id) create
{
    if ([[DUObjectsDictionary sharedDictionary] containsDUObject:name] == NO) 
    {
//        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new DUObject.", name);        
        return [self createNewObject];
        
    } else {
//        DLog(@"Key <%@> found, reuse the object from the dictionary", name);
        return [self reuseOldObject];
    }
}

-(id) createNewObject
{
    return nil;
}

-(id) reuseOldObject
{
    DUObject *myObject;
    myObject = [[DUObjectsDictionary sharedDictionary] getDUObjectbyName:name];
    [myObject activate];
    
    return myObject;
}
@end

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
    return [self createWithName:name];
}

-(id) createWithName:(NSString *)objectName
{
    //if ([[DUObjectsDictionary sharedDictionary] containsDUObject:objectName] == NO)
    {
        //        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new DUObject.", name);        
        return [self createNewObjectWithName:objectName];
        
    }
    /*
    else {
        //        DLog(@"Key <%@> found, reuse the object from the dictionary", name);
        return [self reuseOldObjectWithName:objectName];
    }
     */
}

-(id) createNewObjectWithName:(NSString *)objectName;
{
    return nil;
}

-(id) reuseOldObjectWithName:(NSString *)objectName;
{
    DLog(@"asset for <%@> is reused",objectName);
    DUObject *myObject;
    myObject = [[DUObjectsDictionary sharedDictionary] getDUObjectbyName:objectName];
    [myObject activate];
    
    return myObject;
}
@end

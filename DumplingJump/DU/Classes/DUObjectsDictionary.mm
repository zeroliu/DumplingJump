#import "DUObjectsDictionary.h"
#import "DUObject.h"

@implementation DUObjectsDictionary

+(id) sharedDictionary
{
    static id sharedDictionary = nil;
    if (sharedDictionary == nil)
    {
        sharedDictionary = [[DUObjectsDictionary alloc] init];
    }
    
    return sharedDictionary;
}

-(NSString *) printDictionary
{
    NSString *res = @"";
    
    for (id key in DUDictionary)
    {
        id myArray = [DUDictionary objectForKey:key];
        res = [res stringByAppendingString:[NSString stringWithFormat:@"Key:%@ - %d\n",key, [myArray count]]];
    }
    
    return res;
}

-(id) init
{
    if (self = [super init])
    {
        DUDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(BOOL) containsDUObject:(NSString *)theName
{
    if ([DUDictionary objectForKey:theName] == nil)
    {
        return NO;
    } else {
        return YES;
    }
}

-(id) getDUObjectbyName:(NSString *)theName
{
    id result;
    NSMutableArray *currentArray = [DUDictionary objectForKey:theName];
    if (currentArray != nil && [currentArray count] > 0)
    {
        result = [currentArray objectAtIndex:0];
        [result retain];
        [currentArray removeObjectAtIndex:0];
        
        [self printArray:currentArray];
        
        if ([currentArray count] <= 0)
        {
            [DUDictionary removeObjectForKey:theName];
        }
    }
    return result;
}

-(void) printArray:(NSArray *)currentArray
{
    NSString *test = @"after reuse: ";
    for (DUObject *ob in currentArray)
    {
        test = [test stringByAppendingFormat:@"%@ ", ob.ID];
    }
    DLog(@"%@", test);
}

-(void) addDUObject:(DUObject *)theObject
{
//    [theObject retain];
    NSMutableArray *currentArray = [DUDictionary objectForKey:theObject.name];
    if (currentArray == nil)
    {
        currentArray = [NSMutableArray array];
        [DUDictionary setObject:currentArray forKey:theObject.name];
    }
    [currentArray addObject:theObject];
    [self printMyArray:currentArray];
}

-(void) printMyArray:(NSArray *)currentArray
{
    NSString *test = @"after add: ";
    for (DUObject *ob in currentArray)
    {
       test = [test stringByAppendingFormat:@"%@ ", ob.ID];
    }
    DLog(@"%@", test);
}

@end

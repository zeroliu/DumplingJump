//
//  DUIAPHelper.m
//  CastleRider
//
//  Created by zero.liu on 5/8/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "DUIAPHelper.h"
#import "XMLHelper.h"

@interface DUIAPHelper()
@end

@implementation DUIAPHelper
@synthesize
dataDictionary = _dataDictionary;

- (void)dealloc
{
    self.dataDictionary = nil;
    [super dealloc];
}

+ (DUIAPHelper *) sharedInstance
{
    static dispatch_once_t once;
    static DUIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"edu.cmu.etc.CastleRider.LuckyStars",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id) initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if (self = [super initWithProductIdentifiers:productIdentifiers])
    {
        self.dataDictionary = [[XMLHelper shared] loadIAPData];
    }
    
    return self;
}

@end

//
//  DUIAPHelper.h
//  CastleRider
//
//  Created by zero.liu on 5/8/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "IAPHelper.h"

@interface DUIAPHelper : IAPHelper
@property (nonatomic, retain) NSDictionary *dataDictionary;
+ (DUIAPHelper *) sharedInstance;

@end

//
//  EquipmentData.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "EquipmentData.h"
#import "XMLHelper.h"
#import "Constants.h"
#import "UserData.h"

@implementation EquipmentData
@synthesize dataDictionary = _dataDictionary;
@synthesize structedDictionary = _structedDictionary;
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[EquipmentData alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self loadEquipmentData];
    }
    return self;
}

- (void) loadEquipmentData
{
    self.dataDictionary = [[XMLHelper shared] loadEquipmentDataWithXML:@"Editor_equipment"];
    
    /*
     *  dict (dictionary)
     *  ->  "powerups" (array)
     *      ->  itemData1 (dictionary)
     *          ->  group
     *          ->  type
     *      ->  itemData2
     *  ->  "skills" (array)
     *      ->  itemData1
     *      ->  itemData2
     */
    _structedDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [self.dataDictionary allKeys])
    {
        NSDictionary *item = [self.dataDictionary objectForKey:key];
        NSString *typeName = [item objectForKey:@"type"];
        
        NSMutableArray *itemArray = [self.structedDictionary objectForKey:typeName];
        //If there is no array existed for a certain type
        if (itemArray == nil)
        {
            itemArray = [NSMutableArray array];
            [self.structedDictionary setObject:itemArray forKey:typeName];
        }
        [itemArray addObject:item];
    }
    
    for (NSString *type in [self.structedDictionary allKeys])
    {
        NSArray *unsortedArray = [self.structedDictionary objectForKey:type];
        NSArray *sortedArray;
        sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *first = [NSNumber numberWithInt:[[obj1 objectForKey:@"order"] intValue]];
            NSNumber *second = [NSNumber numberWithInt:[[obj2 objectForKey:@"order"] intValue]];
            return [first compare:second];
        }];
        [self.structedDictionary setObject:sortedArray forKey:type];
    }
}

-(NSDictionary *) findEquipmentWithGroupID:(int)groupID
{
    for (NSString *key in [self.dataDictionary allKeys])
    {
        NSDictionary *equipment = [self.dataDictionary objectForKey:key];
        if ([[equipment objectForKey:@"group"] intValue] == groupID)
        {
            return equipment;
        }
    }
    
    return nil;
}

-(int) isAffordable:(int)starNum
{
    int res = 0;
    
    for (NSString *key in [self.dataDictionary allKeys])
    {
        NSDictionary *item = [self.dataDictionary objectForKey:key];
        int amount = 0;
        amount = [[USERDATA objectForKey:[item objectForKey:@"name"]] intValue];
//        float multiplier = [[item objectForKey:@"multiplier"] floatValue];
//        float base = [[item objectForKey:@"base"] floatValue];
        int unlockPrice = [[item objectForKey:@"unlockPrice"] intValue];
        
        if (amount >= 0 && amount < 4)
        {
            int price = [[item objectForKey:[NSString stringWithFormat:@"price%d",amount]] intValue];
//            if (amount == 0)
//            {
//                price = base;
//            }
//            else
//            {
//                price = base * multiplier * amount;
//            }
//            
            if (price <= starNum)
            {
                res ++;
            }
        
        }
        else
        {
            if (unlockPrice <= starNum)
            {
                res ++;
            }
        }
    }
    
    return res;
}

- (void)dealloc
{
    [_dataDictionary release];
    [_structedDictionary release];
    [super dealloc];
}

@end

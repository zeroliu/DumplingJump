//
//  XMLHelper.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-21.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "XMLHelper.h"
#import "DDXML.h"

#import "Paragraph.h"
#import "AddthingObjectData.h"
#import "Constants.h"
@implementation XMLHelper

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[XMLHelper alloc] init];
    }
    return shared;
}

-(DDXMLDocument *) loadXMLContentFromFile:(NSString *)xmlFilename
{
    DDXMLDocument *xmlDoc;
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:xmlFilename ofType:@"xml"] encoding:NSUTF8StringEncoding error:&err];
    xmlDoc = [[DDXMLDocument alloc] initWithXMLString:content options:0 error:&err];
    if (xmlDoc == nil)
    {
        if (err)
        {
            NSLog(@"error parse to xmldoc, %@", [err description]);
        }
    }
    return [xmlDoc retain];
}

-(id) loadAddthingWithXML:(NSString *)fileName
{
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//Item" error:&err];
    if (err)
    {
        NSLog(@"%@", [err localizedDescription]);
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (DDXMLElement *item in nodeResults)
    {
        if (![[[[item nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"0"])
        {
            //NSLog(@"%@",[[[item nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue]);
            NSArray *itemProperties = [item children];
            AddthingObjectData *data = [[AddthingObjectData alloc] initEmptyData];
            NSString *addthingName = nil;
            for (DDXMLElement *child in itemProperties)
            {
                if ([[child name] isEqualToString:@"name"])
                {
                    data.name = [child stringValue];
                    addthingName = [child stringValue];
                } else if ([[child name] isEqualToString:@"shape"])
                {
                    data.shape = [child stringValue];
                } else if ([[child name] isEqualToString:@"radius"])
                {
                    data.radius = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"width"])
                {
                    data.width = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"length"])
                {
                    data.length = [[child stringValue] doubleValue] * SCALE_MULTIPLIER / 2;
                } else if ([[child name] isEqualToString:@"I"])
                {
                    data.i = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"mass"])
                {
                    data.mass = [[child stringValue] doubleValue] * MASS_MULTIPLIER;
                } else if ([[child name] isEqualToString:@"res"])
                {
                    data.restitution = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"fric"])
                {
                    data.friction = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"gravity"])
                {
                    data.gravity = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"blood"])
                {
                    data.blood = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"react_type"])
                {
                    if (![[child stringValue] isEqualToString:@"Null"])
                    {
                        data.reactionName = [child stringValue];
                    }
                } else if ([[child name] isEqualToString:@"animation"])
                {
                    data.animationName = [child stringValue];
                }
            }
            data.spriteName = [NSString stringWithFormat:@"CA_%@_1", [addthingName lowercaseString]];
            [result setObject:data forKey:addthingName];
        }
    }
    
    return result;
}

-(id) loadParagraphWithXML: (NSString *)fileName
{
    Paragraph *result = [[Paragraph alloc] init];
    
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//level" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    for (DDXMLElement *level in nodeResults)
    {
        if (![[[[level nodesForXPath:@"time" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"1"])
        {
            NSArray *levelArray = [level children];
            float distance = 0;
            NSMutableArray *slotsArray = [NSMutableArray array];
            for (DDXMLElement *child in levelArray)
            {
                //NSLog(@"%@: %@",[child name], [child stringValue]);
                if ([[child name] isEqualToString:@"time"])
                {
                    distance = [[child stringValue] floatValue];
                } else if ([[child name] rangeOfString:@"slot"].location != NSNotFound)
                {
                    int slotNum = [[[child name] substringWithRange:NSMakeRange(4, 1)] intValue];
                    
                    for(int i=[slotsArray count]; i<slotNum-1; i++)
                    {
                        [slotsArray addObject:NOTHING];
                    }
                    [slotsArray addObject:[child stringValue]];
                }
            }
            if ([slotsArray count] < SLOTS_NUM)
            {
                for(int i=[slotsArray count]; i<9; i++)
                {
                    [slotsArray addObject:NOTHING];
                }
            }
            Sentence *thisSentence = [[Sentence alloc] initWithDistance:distance Words:slotsArray];
            [result addSentence:thisSentence];
        }
    }

    return result;
}

@end

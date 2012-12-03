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
#import "DUEffectData.h"
#import "Reaction.h"
#import "Star.h"
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
    xmlDoc = [[[DDXMLDocument alloc] initWithXMLString:content options:0 error:&err] autorelease];
    if (xmlDoc == nil)
    {
        if (err)
        {
            NSLog(@"error parse to xmldoc, %@", [err description]);
        }
    }
    
    return xmlDoc;
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
                    data.mass = [[child stringValue] doubleValue] * [PHYSICSMANAGER mass_multiplier];
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

-(id) loadEffectWithXML: (NSString *)fileName
{
    NSMutableDictionary *effectDict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    NSArray *nodeResult = [xmlDoc nodesForXPath:@"//Effect" error:&err];
    for (DDXMLElement *effect in nodeResult)
    {
        DUEffectData *data = [[DUEffectData alloc]initEmptyEffect];

        NSArray *effectArray = [effect children];
        for (DDXMLElement *child in effectArray)
        {
            if ([[child name] isEqualToString:@"name"])
            {
                data.name = [child stringValue];
            } else if ([[child name] isEqualToString:@"animation"])
            {
                data.animationName = [child stringValue];
                [ANIMATIONMANAGER registerAnimationForName:data.animationName speed:1.8f];
            } else if ([[child name] isEqualToString:@"repeat"])
            {
                data.times = [[child stringValue] intValue];
            }
        }
        if (data.name != nil)
        {
            [effectDict setObject:data forKey:data.name];
        }
    }
    
    return effectDict;
}

-(id) loadReactionWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//react" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    for (DDXMLElement *react in nodeResults)
    {
        if (![[[[react nodesForXPath:@"ID" error:&err] objectAtIndex:0] stringValue] isEqualToString:@"0"])
        {
            Reaction *theReaction = [[Reaction alloc] initEmptyData];
            for (DDXMLElement *child in [react children])
            {
                if ([[child name] isEqualToString:@"react_type"])
                {
                    theReaction.name = [child stringValue];
                } else if ([[child name] isEqualToString:@"reactimage"])
                {
                    theReaction.heroReactAnimationName = [child stringValue];
                    [ANIMATIONMANAGER registerAnimationForName:theReaction.heroReactAnimationName];
                } else if ([[child name] isEqualToString:@"effectimage"])
                {
                    theReaction.effectName = [child stringValue];
                } else if ([[child name] isEqualToString:@"statetime"])
                {
                    theReaction.reactionLasting = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"react_hero"])
                {
                    theReaction.reactHeroSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"react_hero_param"])
                {
                    theReaction.reactHeroSelectorParam = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_hero"])
                {
                    theReaction.triggerCleanHero = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_board"])
                {
                    theReaction.triggerCleanBoard = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"react_item"])
                {
                    theReaction.reactWorldSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_item"])
                {
                    theReaction.triggerCleanWorld = [[child stringValue] intValue];
                } else if ([[child name] isEqualToString:@"react_time"])
                {
                    theReaction.reactTimeSelectorName = [child stringValue];
                } else if ([[child name] isEqualToString:@"trigger_react_time"])
                {
                    theReaction.reactTime = [[child stringValue] doubleValue];
                } else if ([[child name] isEqualToString:@"trigger_clean_time"])
                {
                    theReaction.cleanTime = [[child stringValue] doubleValue];
                }
            }
            [dict setObject:theReaction forKey:theReaction.name];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(id) loadStarDataWithXML: (NSString *)fileName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DDXMLDocument *xmlDoc = [self loadXMLContentFromFile:fileName];
    NSError *err = nil;
    
    //Create Node by finding level
    NSArray *nodeResults = [xmlDoc nodesForXPath:@"//Line" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    
    Star *currentStar;
    int lineWidth = 0;
    int lineCounter = 0;
    NSString *currentStarName;
    
    for (DDXMLElement *line in nodeResults)
    {
        if ([line attributeForName:@"name"] != nil)
        {
            //DLog(@"%@", [line attributeForName:@"name"]);
            currentStarName = [[line attributeForName:@"name"] stringValue];
            currentStar = [[Star alloc] initEmptyStar];
            currentStar.name = [currentStarName retain];
            lineWidth = 0;
            lineCounter = 0;
        } else
        {
            NSArray *slots = [line children];
            for (DDXMLElement *slot in slots)
            {
                int slotNum = [[[slot name] substringFromIndex:4] intValue] - 1;
                [[currentStar.starLines objectAtIndex:lineCounter] replaceObjectAtIndex:slotNum withObject:@"1"];
                lineWidth = max(slotNum, lineWidth);
            }
            
            lineCounter ++;
            if (lineCounter == 9)
            {
                currentStar.width = lineWidth;
                [dict setObject:currentStar forKey:currentStarName];
            }
        }
    }
    
    return dict;
}
@end

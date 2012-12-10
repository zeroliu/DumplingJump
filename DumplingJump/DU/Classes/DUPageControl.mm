//
//  DUPageControl.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-8.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUPageControl.h"

@interface DUPageControl()
{
    NSString *normalSpriteFile_;
    NSString *selectedSpriteFile_;
    int num_;
    CGPoint position_;
    
}
@property (nonatomic, retain) CCMenu *bulletsMenu;
@end

@implementation DUPageControl
@synthesize bulletsMenu = bulletsMenu_;
#pragma mark - Public Methods

-(id) initWithPosition:(CGPoint)pos bulletsNum:(int)num normalSpriteFile:(NSString *)normalSpriteFile selectedSpriteFile:(NSString *)selectedSpriteFile
{
    if (self = [super init])
    {
        normalSpriteFile_ = normalSpriteFile;
        selectedSpriteFile_ = selectedSpriteFile;
        num_ = num;
        position_ = pos;
        
        [self createPageControlMenu];
    }
    
    return self;
}

-(void) moveToIndex:(int)index
{
    for (CCMenuItemSprite *item in [self.bulletsMenu children])
    {
        if (item.tag == index)
        {
            [item selected];
        } else
        {
            [item unselected];
        }
    }
}

-(void) addMenuToNode:(CCNode *)node
{
    [self addMenuToNode:node z:0];
}

-(void) addMenuToNode:(CCNode *)node z:(int)priority
{
    [node addChild:bulletsMenu_ z:priority];
}

-(void) removeMenuFromParent
{
    [bulletsMenu_ removeFromParentAndCleanup:YES];
}

#pragma mark - Private Methods

-(void) createPageControlMenu
{
    NSMutableArray *bulletArray = [[NSMutableArray alloc] initWithCapacity:num_];
    
    for (int i=0; i<num_; i++)
    {
        CCMenuItemSprite *bullet = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:normalSpriteFile_] selectedSprite:[CCSprite spriteWithFile:selectedSpriteFile_]];
        bullet.position = ccp(0,0);
        bullet.isEnabled = NO;
        bullet.tag = i;
        [bulletArray addObject:bullet];
    }
    
    id menu = [CCMenu menuWithArray:bulletArray];
    self.bulletsMenu = menu;
    
    bulletsMenu_.position = position_;
    [bulletsMenu_ alignItemsHorizontallyWithPadding:5];
    
    [bulletArray release];
}

- (void)dealloc
{
    [bulletsMenu_ removeAllChildrenWithCleanup:YES];
    [bulletsMenu_ release];
    [super dealloc];
}
@end

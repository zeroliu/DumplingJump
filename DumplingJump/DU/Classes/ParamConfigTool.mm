#import "ParamConfigTool.h"
#import "ConfigScene.h"

@implementation ParamConfigTool

+(id) shared
{
    static id shared;
    
    if (shared == nil)
    {
        shared = [[ParamConfigTool alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self createGotoConfigSceneButton];
    }
    
    return self;
}

-(void) createGotoConfigSceneButton
{
    
    CCMenuItemFont *gotoButton = [CCMenuItemFont itemWithString:@"Config" target:self selector:@selector(gotoConfigScene)];
    gotoButton.position = ccp(240, 50);
    CCMenu *menu = [CCMenu menuWithItems:gotoButton, nil];
    menu.position = CGPointZero;
    [GAMELAYER addChild:menu];
}

-(void) gotoConfigScene
{
    NSArray *subViews = [[[CCDirector sharedDirector] view] subviews];
    for (id view in subViews)
    {
        [view removeFromSuperview];
    }
    [[CCDirector sharedDirector] pushScene:[CCTransitionShrinkGrow transitionWithDuration:0.2f scene:[ConfigScene scene]]];
}
@end

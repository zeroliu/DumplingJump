#import "BackgroundController.h"

@interface BackgroundController()
{
    BOOL bgLoaded;
}
@property (nonatomic, retain) BackgroundModel *model;
@property (nonatomic, retain) BackgroundView *view;
@property (nonatomic, retain) NSMutableArray *currentBGArray;
@property (nonatomic, retain) NSString *currentBGName;
@end

@implementation BackgroundController
@synthesize model = _model;
@synthesize view = _view;
@synthesize currentBGName = _currentBGName;
@synthesize currentBGArray = _currentBGArray;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[BackgroundController alloc] init];
    }
    
    return shared;
}

-(void) initParam
{
    _model = [[BackgroundModel alloc] init];
    _view = [[BackgroundView alloc] init];
    bgLoaded = false;
    [self.model addBackgroundWithFileName:MAZE bgLayers:
     new BgLayer(1, 0, 120, @"CA_background_1.png"),
     new BgLayer(2, 5, 100, @"CA_background_2.png"),
     new BgLayer(3, 10, 60, @"CA_background_3.png"),
     nil
     ];
}

-(void) setBackgroundWithName:(NSString *)bgName
{
    self.currentBGArray = [self.model getBGArrayByName:bgName];
    self.currentBGName = bgName;
    [self.view setBgBatchNodeWithName:bgName];
    [self.view setBackgroundWithBGArray:self.currentBGArray];
    bgLoaded = true;
}

-(void) updateBackground:(ccTime)deltaTime
{
    if(bgLoaded)
    {
        [self.view updateBackgroundWithBGArray:self.currentBGArray];
    }
}

-(void) speedUpWithScale:(int)scale interval:(float)time
{
    [self.view stopAllActions];
    id speedScaleUp = [CCActionTween actionWithDuration:0.5 key:@"scrollSpeedScale" from:1 to:scale];
    id delay = [CCDelayTime actionWithDuration:time];
    id speedScaleDown = [CCActionTween actionWithDuration:0.2 key:@"scrollSpeedScale" from:scale to:1];
    id sequence = [CCSequence actions:speedScaleUp, delay, speedScaleDown, nil];
    [self.view runAction:sequence];
}

-(void) dealloc
{
    [_model release];
    [_view release];
    [_currentBGArray release];
    [_currentBGName release];
    [super dealloc];
}

@end

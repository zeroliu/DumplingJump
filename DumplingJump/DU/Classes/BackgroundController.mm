#import "BackgroundController.h"

@interface BackgroundController()
{
    BOOL bgLoaded;
}
@property (nonatomic, retain) BackgroundModel *model;
@property (nonatomic, retain) BackgroundView *view;
@property (nonatomic, assign) NSMutableArray *currentBGArray;
@property (nonatomic, assign) NSString *currentBGName;
@end

@implementation BackgroundController
@synthesize model = _model;
@synthesize view = _view;
@synthesize currentBGName = _currentBGName;
@synthesize currentBGArray = _currentBGArray;

-(id) model
{
    if (_model == nil) _model = [[BackgroundModel alloc] init];
    return _model;
}

-(id) view
{
    if (_view == nil) _view = [[BackgroundView alloc] init];
    return _view;
}

-(id) init
{
    if (self = [super init])
    {
        bgLoaded = false;
        
        [self.model addBackgroundWithFileName:SKY bgLayers:
         new BgLayer(1, 0, @"CA_background_1.png",-30),
         new BgLayer(2, 1, @"CA_background_2.png"),
         new BgLayer(3, 2, @"CA_background_3.png"),
         new BgLayer(4, 3, @"CA_background_4.png"),
         new BgLayer(5, 4, @"CA_background_5.png"),
         nil
         ];
    }
    
    return self;
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

@end

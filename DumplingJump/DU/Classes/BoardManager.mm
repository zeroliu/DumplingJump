#import "BoardManager.h"
#import "DUObjectsDictionary.h"

#define FREQ_L 1.05f
#define FREQ_M 1.0f
#define FREQ_R 1.05f
#define DAMP_L 1.0f
#define DAMP_M 1.0f
#define DAMP_R 1.0f

@interface BoardManager()
@property (nonatomic, retain) DUPhysicsObject *board;
@end

@implementation BoardManager

@synthesize board = _board, freq_l = _freq_l, freq_m = _freq_m, freq_r = _freq_r, damp_l = _damp_l, damp_m = _damp_m, damp_r = _damp_r;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[BoardManager alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        self.freq_l = FREQ_L;
        self.freq_m = FREQ_M;
        self.freq_r = FREQ_R;
        self.damp_l = DAMP_L;
        self.damp_m = DAMP_M;
        self.damp_r = DAMP_R;
        
        [ANIMATIONMANAGER registerAnimationForName:ANIM_BROOM];
    }
    
    return self;
}

-(id) createBoardWithSpriteName:(NSString *)fileName position:(CGPoint) pos
{
    //Remove the existing board
    if (self.board != nil)
    {
        [self.board removeFromParentAndCleanup:NO];
        [self.board archive];
        self.board = nil;
    }
    //Create new board with the board name and the position
    self.board = [[Board alloc] initBoardWithBoardName:BOARD spriteName:fileName position:pos leftFreq:self.freq_l middleFreq:self.freq_m rightFreq:self.freq_r leftDamp:self.damp_l middleDamp:self.damp_m rightDamp:self.damp_r];
    //Add the board to the view
    [self.board addChildTo:BATCHNODE z:2];
    //Add board object to GameLayer
    [GAMELAYER addChild:self.board];
    return self.board;
}

-(id) getBoard
{
    return self.board;
}

@end

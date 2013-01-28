#import "BoardManager.h"
#import "DUObjectsDictionary.h"

#define FREQ_L @"freqL"
#define FREQ_M @"freqM"
#define FREQ_R @"freqR"
#define DAMP_L @"dampL"
#define DAMP_M @"dampM"
#define DAMP_R @"dampR"

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
        NSDictionary *boardData = [[WorldData shared] loadDataWithAttributName:@"board"];
        self.freq_l = [[boardData objectForKey:FREQ_L] floatValue];
        self.freq_m = [[boardData objectForKey:FREQ_M] floatValue];
        self.freq_r = [[boardData objectForKey:FREQ_R] floatValue];
        self.damp_l = [[boardData objectForKey:DAMP_L] floatValue];
        self.damp_m = [[boardData objectForKey:DAMP_M] floatValue];
        self.damp_r = [[boardData objectForKey:DAMP_R] floatValue];
        
        [ANIMATIONMANAGER registerAnimationForName:ANIM_BROOM];
        [ANIMATIONMANAGER registerAnimationForName:ANIM_BROOM_BROKEN];
        [ANIMATIONMANAGER registerAnimationForName:ANIM_BROOM_RECOVER];
        
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
    [self.board addChildTo:BATCHNODE z:Z_Board];
    //Add board object to GameLayer
    [GAMELAYER addChild:self.board];
    return self.board;
}

-(id) getBoard
{
    return self.board;
}

@end

#import "Common.h"
#import "Board.h"

@interface BoardManager : NSObject

@property (nonatomic, assign) float freq_l;
@property (nonatomic, assign) float freq_m;
@property (nonatomic, assign) float freq_r;
@property (nonatomic, assign) float damp_l;
@property (nonatomic, assign) float damp_m;
@property (nonatomic, assign) float damp_r;


+(id) shared;
-(id) createBoardWithSpriteName:(NSString *)theName position:(CGPoint) pos;
-(id) getBoard;
@end

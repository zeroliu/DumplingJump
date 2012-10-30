#import "Common.h"
#import "Board.h"

@interface BoardManager : NSObject


+(id) shared;
-(id) createBoardWithSpriteName:(NSString *)theName position:(CGPoint) pos;
-(id) getBoard;
@end

#import "Common.h"

float randomFloat(float start, float end)
{
    float t = (arc4random() % 1000) / 1000.0;
    return t * (end - start) + start;
}

//start <= x < end
int randomInt(int start, int end)
{
    int t = arc4random() % (end - start);
    return start + t;
}
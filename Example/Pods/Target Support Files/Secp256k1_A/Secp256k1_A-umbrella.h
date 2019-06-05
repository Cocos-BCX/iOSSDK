#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "secp256k1.h"

FOUNDATION_EXPORT double Secp256k1_AVersionNumber;
FOUNDATION_EXPORT const unsigned char Secp256k1_AVersionString[];


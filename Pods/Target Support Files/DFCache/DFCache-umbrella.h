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

#import "DFCache.h"
#import "DFDiskCache.h"
#import "NSURL+DFExtendedFileAttributes.h"
#import "DFFileStorage.h"
#import "DFCacheImageDecoder.h"
#import "DFValueTransformer.h"
#import "DFValueTransformerFactory.h"

FOUNDATION_EXPORT double DFCacheVersionNumber;
FOUNDATION_EXPORT const unsigned char DFCacheVersionString[];


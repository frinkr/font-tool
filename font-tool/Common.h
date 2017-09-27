#import <AppKit/AppKit.h>

#ifdef __cplusplus
#  define FT_BEGIN_DECLS extern "C" {
#  define FT_END_DECLS }
#else
#  define FT_BEGIN_DECLS 
#  define FT_END_DECLS 
#endif


#define INVALID_CODE_POINT (0x110000)

#ifndef NSAppKitVersionNumber10_11_3
#  define NSAppKitVersionNumber10_11_3 1404.34
#endif

#define OS_IS_BELOW_SIERRA  (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_11_3)

typedef uint32_t codepoint_t;
typedef struct FT_FaceRec_ * OpaqueFTFace;

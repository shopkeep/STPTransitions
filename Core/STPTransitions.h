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

#import "STPBlockTransition.h"
#import "STPPresentationController.h"
#import "STPTransition.h"
#import "STPTransitionCenter.h"
#import "STPTransitions.h"
#import "UIGestureRecognizer+STPTransition.h"
#import "UINavigationController+STPTransitions.h"
#import "UIViewController+STPTransitions.h"

FOUNDATION_EXPORT double STPTransitionsVersionNumber;
FOUNDATION_EXPORT const unsigned char STPTransitionsVersionString[];

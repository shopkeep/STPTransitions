#import "UIViewController+STPTransitions.h"

#import "STPTransition.h"
#import "STPTransitionCenter.h"

#import <objc/runtime.h>

@interface STPViewControllerContextTransitioning : NSObject <UIViewControllerContextTransitioning>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIViewController *fromViewController;
@property (nonatomic, strong) UIViewController *toViewController;
@property (nonatomic, copy) void (^onCompletion)(BOOL finished);

@property (nonatomic, assign) CGRect initialFromFrame;
@property (nonatomic, assign) CGRect initialToFrame;

- (instancetype)initFromViewController:(UIViewController *)fromViewController
                      toViewController:(UIViewController *)toViewController;

@end

@implementation STPViewControllerContextTransitioning

- (instancetype)initFromViewController:(UIViewController *)fromViewController
                      toViewController:(UIViewController *)toViewController {
    self = [super init];
    if (self) {
        _fromViewController = fromViewController;
        _toViewController = toViewController;
        _initialFromFrame = fromViewController.view.frame;
        _initialToFrame = toViewController.view.frame;
    }
    return self;
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    UIViewController *viewController;
    if ([key isEqualToString:UITransitionContextFromViewControllerKey]) {
        viewController = self.fromViewController;
    } else if ([key isEqualToString:UITransitionContextToViewControllerKey]) {
        viewController = self.toViewController;
    }
    return viewController;
}

- (void)completeTransition:(BOOL)didComplete {
    self.onCompletion(didComplete);
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc {
    CGRect frame = CGRectZero;
    if (vc == self.fromViewController) {
        frame = self.initialFromFrame;
    } else if (vc == self.toViewController) {
        frame =self.initialToFrame;
    }
    return frame;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc {
    return self.initialToFrame;
}

- (BOOL)transitionWasCancelled {
    return NO;
}

- (BOOL)isAnimated {
    return YES;
}

- (BOOL)isInteractive {
    // TODO: Allow interactive transitions between child view controllers.
    return NO;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
}

- (void)finishInteractiveTransition {
}

- (void)cancelInteractiveTransition {
}

- (void)pauseInteractiveTransition {
}

- (nullable __kindof UIView *)viewForKey:(nonnull UITransitionContextViewKey)key {
    return nil;
}


- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationNone;
}

@synthesize targetTransform = _targetTransform;

@end

@implementation UIViewController (STPTransitions)

- (void)setSourceViewController:(UIViewController *)sourceViewController {
    objc_setAssociatedObject(self, @selector(sourceViewController), sourceViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)sourceViewController {
    return objc_getAssociatedObject(self, @selector(sourceViewController));
}

- (void)setFixInterfaceOrientationRotation:(BOOL)fixInterfaceOrientationRotation {
    objc_setAssociatedObject(self, @selector(fixInterfaceOrientationRotation), @(fixInterfaceOrientationRotation), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)fixInterfaceOrientationRotation {
    return [objc_getAssociatedObject(self, @selector(fixInterfaceOrientationRotation)) boolValue];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
              usingTransition:(STPTransition *)transition
                 onCompletion:(void (^)(void))completion {
    if (![self.transitioningDelegate isKindOfClass:STPTransitionCenter.class]) {
        self.transitioningDelegate = STPTransitionCenter.sharedInstance;
    }
    STPTransitionCenter *center = (STPTransitionCenter *)self.transitioningDelegate;
    [center setNextPushOrPresentTransition:transition fromViewController:self];
    viewControllerToPresent.sourceViewController = self;
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    viewControllerToPresent.transitioningDelegate = center;

    [self presentViewController:viewControllerToPresent animated:YES completion:completion];
}

- (void)dismissViewControllerUsingTransition:(STPTransition *)transition
                                onCompletion:(void (^)(void))completion {
    if (![self.transitioningDelegate isKindOfClass:STPTransitionCenter.class]) {
        self.transitioningDelegate = STPTransitionCenter.sharedInstance;
    }
    STPTransitionCenter *center = (STPTransitionCenter *)self.transitioningDelegate;
    [center setNextPopOrDismissTransition:transition fromViewController:self];
    transition.needsRotationFixForModals = YES;
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                     usingTransition:(STPTransition *)transition {
    [fromViewController willPerformTransitionAsOuterViewController:transition];
    [fromViewController willMoveToParentViewController:nil];
    [toViewController willPerformTransitionAsInnerViewController:transition];
    [self addChildViewController:toViewController];

    __weak __typeof(self) weakSelf = self;
    void (^onCompletion)(BOOL) = ^(BOOL finished) {
        [toViewController didMoveToParentViewController:weakSelf];
        [fromViewController removeFromParentViewController];
        if (transition.onCompletion) {
            transition.onCompletion(transition, YES);
        }
        [fromViewController didPerformTransitionAsOuterViewController:transition];
        [toViewController didPerformTransitionAsInnerViewController:transition];
    };

    if (transition) {
        STPViewControllerContextTransitioning *transitioningContext =
        [[STPViewControllerContextTransitioning alloc] initFromViewController:fromViewController
                                                             toViewController:toViewController];
        transitioningContext.containerView = self.view;
        transitioningContext.onCompletion = onCompletion;

        [transition animateTransition:transitioningContext];
    } else {
        [fromViewController.view removeFromSuperview];
        [self.view addSubview:toViewController.view];
        onCompletion(YES);
    }
}

- (void)willPerformTransitionAsInnerViewController:(STPTransition *)transition {}
- (void)didPerformTransitionAsInnerViewController:(STPTransition *)transition {}

- (void)willPerformTransitionAsOuterViewController:(STPTransition *)transition {}
- (void)didPerformTransitionAsOuterViewController:(STPTransition *)transition {}


@end

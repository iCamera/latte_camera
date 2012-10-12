/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <UIKit/UIKit.h>

// Required for the shadow, cast by the front view.
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	FrontViewPositionCenter,
	FrontViewPositionRight,
	FrontViewPositionRightMost,
	FrontViewPositionLeft,
	FrontViewPositionLeftMost
} FrontViewPosition;

@protocol LXUIRevealControllerDelegate;

@interface LXUIRevealController : UIViewController <UITableViewDelegate>

#pragma mark - Public Properties:
@property (strong, nonatomic) IBOutlet UIViewController *frontViewController;
@property (strong, nonatomic) IBOutlet UIViewController *leftViewController;
@property (strong, nonatomic) IBOutlet UIViewController *rightViewController;
@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;
@property (assign, nonatomic) id<LXUIRevealControllerDelegate> delegate;

// Defines how much of the rear view is shown.
@property (assign, nonatomic) CGFloat rearViewRevealWidth;

// Defines how much of an overdraw can occur when drawing further than 'rearViewRevealWidth'.
@property (assign, nonatomic) CGFloat maxRearViewRevealOverdraw;

// Defines the width of the rear views presentation mode.
@property (assign, nonatomic) CGFloat rearViewPresentationWidth;

// Leftmost point at which a reveal will be triggered if a user stops panning.
@property (assign, nonatomic) CGFloat revealViewTriggerWidth;

// Leftmost point at which a conceal will be triggered if a user stops panning.
@property (assign, nonatomic) CGFloat concealViewTriggerWidth;

// Velocity required for the controller to instantly toggle its state.
@property (assign, nonatomic) CGFloat quickFlickVelocity;

// Default duration for the revealToggle: animation.
@property (assign, nonatomic) NSTimeInterval toggleAnimationDuration;

// Defines the radius of the front view's shadow.
@property (assign, nonatomic) CGFloat frontViewShadowRadius;

#pragma mark - Public Methods:
- (id)initWithFrontViewController:(UIViewController *)aFrontViewController leftViewController:(UIViewController *)aLeftViewController rightViewController:(UIViewController *)aRightViewController;
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer;
- (void)revealLeft:(id)sender;
- (void)revealLeft:(id)sender animationDuration:(NSTimeInterval)animationDuration;
- (void)revealRight:(id)sender;
- (void)revealRight:(id)sender animationDuration:(NSTimeInterval)animationDuration;

- (void)setFrontViewController:(UIViewController *)frontViewController;
//- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

- (void)hideFrontView;
- (void)showFrontViewCompletely:(BOOL)completely;

@end

#pragma mark - Delegate Protocol:
@protocol LXUIRevealControllerDelegate<NSObject>

@optional

- (BOOL)revealController:(LXUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController;
- (BOOL)revealController:(LXUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController;

/* IMPORTANT: It is not guaranteed that 'didReveal...' will be called after 'willReveal...'! - DO NOT _under any circumstances_ make that assumption!
 */
- (void)revealController:(LXUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(LXUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(LXUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(LXUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(LXUIRevealController *)revealController willSwapToFrontViewController:(UIViewController *)frontViewController;
- (void)revealController:(LXUIRevealController *)revealController didSwapToFrontViewController:(UIViewController *)frontViewController;

#pragma mark New in 0.9.9
- (void)revealController:(LXUIRevealController *)revealController willResignRearViewControllerPresentationMode:(UIViewController *)rearViewController;
- (void)revealController:(LXUIRevealController *)revealController didResignRearViewControllerPresentationMode:(UIViewController *)rearViewController;

- (void)revealController:(LXUIRevealController *)revealController willEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController;
- (void)revealController:(LXUIRevealController *)revealController didEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController;

@end

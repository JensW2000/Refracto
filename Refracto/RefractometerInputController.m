//
//  RefractometerInputController.m
//  (Sub-)Controller for Input Section in Refractometer Tab
//


#import "RefractometerInputController.h"
#import "AppDelegate.h"
#import "NSDecimalNumber+Refracto.h"


#define kShowSettingsPopoverSegue  (@"showSettingsPopoverSegue")


@interface RefractometerInputController () <VerticalRecfractionPickerDelegate>

@property (weak, nonatomic) IBOutlet VerticalRefractionPicker *beforePicker;
@property (weak, nonatomic) IBOutlet VerticalRefractionPicker *currentPicker;

@property (weak, nonatomic) IBOutlet UILabel *beforeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;

@property (nonatomic) BOOL propagateUpdatesOnScroll;

@end


@implementation RefractometerInputController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.beforePicker.alignment = RefractionPickerAlignmentRight;
    self.currentPicker.alignment = RefractionPickerAlignmentLeft;
    self.propagateUpdatesOnScroll = YES;
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    AppDelegate *sharedAppDelegate = [AppDelegate appDelegate];
    self.beforePicker.refraction = sharedAppDelegate.recentBeforeRefraction;
    self.currentPicker.refraction = sharedAppDelegate.recentCurrentRefraction;

    if (UI_USER_INTERFACE_IDIOM () == UIUserInterfaceIdiomPad) {

        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(handleComputationDefaultsChanged:)
                   name:kRefractoComputationDefaultsChangedNotification
                 object:nil];
    }

    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.beforePicker);
}


- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)handleComputationDefaultsChanged:(NSNotification *)notification {

    [self.delegate refractionInputDidChangeToBefore:self.beforePicker.refraction current:self.currentPicker.refraction];
}


#pragma mark - iPad Rotation


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    self.propagateUpdatesOnScroll = NO;

    CGPoint beforeContentOffset = [self.beforePicker contentOffsetSnappedToTickMarker];
    CGPoint currentContentOffset = [self.currentPicker contentOffsetSnappedToTickMarker];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        [self.beforePicker handleSizeTransitionWithTargetContentOffset:beforeContentOffset];
        [self.currentPicker handleSizeTransitionWithTargetContentOffset:currentContentOffset];
    }
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {

                                     self.propagateUpdatesOnScroll = YES;
                                 }];
}


#pragma mark - Adaptive UIPopoverPresentation for Settings on iPad


- (IBAction)dismissSettings:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateNavigationItemForPresentedViewController:(UIViewController *)presentedViewController traitCollection:(UITraitCollection *)traits {

    if ([presentedViewController isKindOfClass:[UINavigationController class]]) {

        UINavigationController *navController = (UINavigationController *)presentedViewController;
        UIBarButtonItem *doneButton = nil;

        if (traits.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {

            doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                       target:self
                                                                       action:@selector(dismissSettings:)];
        }

        navController.topViewController.navigationItem.rightBarButtonItem = doneButton;
    }
    else if (presentedViewController != nil) {

        ALog(@"Presented viewcontroller (%@) must be of class UINavigationController", presentedViewController);
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:kShowSettingsPopoverSegue]) {

        UIViewController *destinationController = segue.destinationViewController;
        destinationController.preferredContentSize = CGSizeMake(340, 540);
        destinationController.popoverPresentationController.delegate = self;

        [self updateNavigationItemForPresentedViewController:destinationController traitCollection:self.traitCollection];

        UIPopoverPresentationController *popoverController = (UIPopoverPresentationController *)destinationController.presentationController;
        popoverController.sourceRect = CGRectInset(popoverController.sourceView.bounds, -5, -5);
    }
}


- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    [self updateNavigationItemForPresentedViewController:self.presentedViewController traitCollection:newCollection];
}


#pragma mark - VerticalRecfractionPickerDelegate


- (void)refractionPickerView:(VerticalRefractionPicker *)pickerView didSelectRefraction:(NSDecimalNumber *)refraction {

    if (self.propagateUpdatesOnScroll == NO)
        return;

    NSString *description = [[AppDelegate numberFormatterBrix] stringFromNumber:refraction];

    if (pickerView == self.beforePicker) {

        self.beforeLabel.text = description;
    }
    else if (pickerView == self.currentPicker) {

        self.currentLabel.text = description;
    }

    [self.delegate refractionInputDidChangeToBefore:self.beforePicker.refraction current:self.currentPicker.refraction];
}

@end

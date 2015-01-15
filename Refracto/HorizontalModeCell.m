//
//  HorizontalModeCell.m
//  Custom Cell for UICollectionView used as Mode Selector
//


#import "HorizontalModeCell.h"
#import "HorizontalModePicker.h"


@interface HorizontalModeCell ()

@property (strong, nonatomic) UILabel *label;

@end


@implementation HorizontalModeCell

- (instancetype)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {

        self.layer.doubleSided = NO;

        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 1;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.attributedText = [[NSAttributedString alloc] initWithString:@""];

        [self.contentView addSubview:self.label];
    }

    return self;
}


- (void)setSelected:(BOOL)selected {

    if (self.selected != selected) {

        [super setSelected:selected];

        NSDictionary *attributes = selected ? horizontalModeSelectedTextAttributes : horizontalModeTextAttributes;
        [self setText:self.label.attributedText.string attributes:attributes];
    }
}


- (void)setText:(NSString *)text attributes:(NSDictionary *)attributes {

    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDuration:0.3];
    [self.label.layer addAnimation:transition forKey:nil];

    self.label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end

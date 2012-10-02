//
//  SCImageCollectionViewItem.m
//  SSCatalog
//
//  Created by Sam Soffes on 5/3/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SCImageCollectionViewItem.h"
#import "UIImageView+AFNetworking.h"

@implementation SCImageCollectionViewItem

#pragma mark - Accessors

@synthesize imageURL = _imageURL;

- (void)setImageURL:(NSURL *)url {
	_imageURL = url;
	
	if (_imageURL) {
		[self.imageView setImageWithURL:url placeholderImage:nil];
	} else {
		self.imageView.image = nil;
	}
}


#pragma mark - Initializer

- (id)initWithReuseIdentifier:(NSString *)aReuseIdentifier {
	if ((self = [super initWithStyle:SSCollectionViewItemStyleImage reuseIdentifier:aReuseIdentifier])) {
		self.imageView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        
        self.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.imageView.layer.borderWidth = 5;
        UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:self.imageView.bounds];
        self.imageView.layer.masksToBounds = NO;
        self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.imageView.layer.shadowOpacity = 0.5f;
        self.imageView.layer.shadowRadius = 1.5f;
        self.imageView.layer.shadowPath = shadowPathPic.CGPath;
	}
	return self;
}


- (void)prepareForReuse {
	[super prepareForReuse];
	self.imageURL = nil;
}

@end

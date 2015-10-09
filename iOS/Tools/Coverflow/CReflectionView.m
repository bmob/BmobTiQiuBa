//
//	CReflectionView.m
//	Coverflow
//
//	Created by Jonathan Wight on 9/25/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//		  conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//		  of conditions and the following disclaimer in the documentation and/or other materials
//		  provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CReflectionView.h"

#import <QuartzCore/QuartzCore.h>

@interface CReflectionView ()
@property (readwrite, nonatomic, strong) CAGradientLayer *gradientLayer;
@end

#pragma mark -

@implementation CReflectionView

@synthesize gradientLayer = _gradientLayer;

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
		self.layer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
		self.layer.mask = self.gradientLayer;
        }
    return(self);
    }

- (id)initWithFrame:(CGRect)inFrame
    {
    if ((self = [super initWithFrame:inFrame]) != NULL)
        {
		self.layer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
		self.layer.mask = self.gradientLayer;
        }
    return(self);
    }

- (void)setFrame:(CGRect)frame
	{
	[super setFrame:frame];

	if (_gradientLayer)
		{
		_gradientLayer.frame = self.layer.bounds;
		}
	}

- (void)setImage:(UIImage *)image
	{
	_image = image;

	self.layer.contents = (__bridge id)[image CGImage];
	const CGFloat theHeight = self.bounds.size.height / _image.size.height;
	self.layer.contentsRect = (CGRect){
		.origin = { .x = 0.0f, .y = 1.0f - theHeight },
		.size = { .width = 1.0f, .height = theHeight },
		};
	}

- (CAGradientLayer *)gradientLayer
	{
	if (_gradientLayer == NULL)
		{
		_gradientLayer = [CAGradientLayer layer];
		_gradientLayer.frame = self.layer.bounds;
		_gradientLayer.colors = @[
			(__bridge id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
			(__bridge id)[UIColor colorWithWhite:1.0 alpha:0.8].CGColor,
			];
		}
	return(_gradientLayer);
	}

@end

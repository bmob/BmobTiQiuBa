//
//	CBetterCollectionViewCell.m
//	Coverflow
//
//	Created by Jonathan Wight on 9/24/12.
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

#import "CBetterCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

#import "CBetterCollectionViewLayoutAttributes.h"

@interface CBetterCollectionViewCell ()
@property (readwrite, nonatomic, strong) CALayer *shieldLayer;
#if DEBUG == 1
@property (readwrite, nonatomic, strong) UILabel *debugInfoLabel;
#endif
@end

#pragma mark -

@implementation CBetterCollectionViewCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
    {
    [super applyLayoutAttributes:layoutAttributes];

    CBetterCollectionViewLayoutAttributes *theLayoutAttributes = (CBetterCollectionViewLayoutAttributes *)layoutAttributes;
    if (self.shieldLayer == NULL)
        {
        self.shieldLayer = [self makeShieldLayer];
        self.shieldLayer.zPosition = INFINITY;
        [self.layer addSublayer:self.shieldLayer];
        }

    self.shieldLayer.opacity = theLayoutAttributes.shieldAlpha;

	#if DEBUG == 1
	if (theLayoutAttributes.debugInfo.length > 0)
		{
		if (self.debugInfoLabel == NULL)
			{
			self.debugInfoLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
			self.debugInfoLabel.numberOfLines = 0;
			self.debugInfoLabel.lineBreakMode = NSLineBreakByCharWrapping;
			self.debugInfoLabel.backgroundColor = [UIColor clearColor];
			self.debugInfoLabel.textColor = [UIColor redColor];
			[self addSubview:self.debugInfoLabel];
			}
		self.debugInfoLabel.text = theLayoutAttributes.debugInfo;

		}
	else
		{
		[self.debugInfoLabel removeFromSuperview];
		self.debugInfoLabel = NULL;
		}
	#endif /* DEBUG == 1 */
    }

#pragma mark -

- (CALayer *)makeShieldLayer
    {
    CALayer *theShield = [CALayer layer];
    theShield.frame = self.bounds;
    theShield.backgroundColor = [UIColor blackColor].CGColor;
    return(theShield);
    }

@end

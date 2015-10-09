//
//	CCoverflowCollectionViewLayout.m
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

#import "CCoverflowCollectionViewLayout.h"

#import "CInterpolator.h"
#import "CBetterCollectionViewLayoutAttributes.h"

// If we decide to make this vertical we could use these macros to help make it painless...
//#define XORY(axis, point) ((axis) ? (point.y) : (point.x))
//#define WORH(axis, size) ((axis) ? (size.height) : (size.width))

@interface CCoverflowCollectionViewLayout ()
@property (readwrite, nonatomic, strong) NSIndexPath *currentIndexPath;

@property (readwrite, nonatomic, assign) CGFloat centerOffset;
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) CInterpolator *scaleInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *positionoffsetInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *rotationInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *zOffsetInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *darknessInterpolator;
@end

@implementation CCoverflowCollectionViewLayout

+ (Class)layoutAttributesClass
    {
    return([CBetterCollectionViewLayoutAttributes class]);
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
		[self setup];
        }
    return self;
    }

- (void)awakeFromNib
	{
	[self setup];
	}

- (void)setup
	{
    self.cellSize = (CGSize){ 200.0f, 300.0f };
    self.cellSpacing = 40.0f;
	self.snapToCells = YES;

    self.positionoffsetInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0f):               @(-self.cellSpacing * 2.0f),
		@(-0.2f - FLT_EPSILON): @(  0.0f),
		}] interpolatorWithReflection:YES];

	self.rotationInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-0.5f):  @(50.0f),
		@(-0.0f): @( 0.0f),
		}] interpolatorWithReflection:YES];

	self.scaleInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0f): @(0.9),
		@(-0.5f): @(1.0f),
		}] interpolatorWithReflection:NO];

//	self.zOffsetInterpolator = [[CInterpolator interpolatorWithDictionary:@{
//		@(-9.0f):               @(9.0f),
//		@(-1.0f - FLT_EPSILON): @(1.0f),
//		@(-1.0f):               @(0.0f),
//		}] interpolatorWithReflection:NO];

	self.darknessInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-2.5f): @(0.5f),
		@(-0.5f): @(0.0f),
		}] interpolatorWithReflection:NO];
	}

- (void)prepareLayout
    {
    [super prepareLayout];

	self.centerOffset = (self.collectionView.bounds.size.width - self.cellSpacing) * 0.5f;

    self.cellCount = [self.collectionView numberOfItemsInSection:0];
	}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
    {
    return(YES);
    }

- (CGSize)collectionViewContentSize
	{
    const CGSize theSize = {
        .width = self.cellSpacing * self.cellCount + self.centerOffset * 2.0f,
        .height = self.collectionView.bounds.size.height,
        };
    return(theSize);
	}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
	{
    NSMutableArray *theLayoutAttributes = [NSMutableArray array];

	// Cells...
	// TODO -- 3 is a bit of a fudge to make sure we get all cells... Ideally we should compute the right number of extra cells to fetch...
    NSInteger theStart = MIN(MAX((NSInteger)floorf(CGRectGetMinX(rect) / self.cellSpacing) - 3, 0), self.cellCount);
    NSInteger theEnd = MIN(MAX((NSInteger)ceilf(CGRectGetMaxX(rect) / self.cellSpacing) + 3, 0), self.cellCount);

    for (NSInteger N = theStart; N != theEnd; ++N)
        {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:N inSection:0];

        UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (theAttributes != NULL)
            {
            [theLayoutAttributes addObject:theAttributes];
            }
        }

	// Decorations...
	[theLayoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:@"title" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];

    return(theLayoutAttributes);
	}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
	{
	// Capture some commonly used variables...
    const CGFloat theRow = indexPath.row;
	const CGRect theViewBounds = self.collectionView.bounds;

    CBetterCollectionViewLayoutAttributes *theAttributes = [CBetterCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	theAttributes.size = self.cellSize;

	// #########################################################################

	// Delta is distance from center of the view in cellSpacing units...
	const CGFloat theDelta = ((theRow + 0.5f) * self.cellSpacing + self.centerOffset - theViewBounds.size.width * 0.5f - self.collectionView.contentOffset.x) / self.cellSpacing;

	// TODO - we should write a getter for this that calculates the value. Setting it constantly is wasteful.
	if (roundf(theDelta) == 0)
		{
		self.currentIndexPath = indexPath;
		}

	// #########################################################################

    const CGFloat thePosition = (theRow + 0.5f) * (self.cellSpacing) + [self.positionoffsetInterpolator interpolatedValueForKey:theDelta];
	theAttributes.center = (CGPoint){ thePosition + self.centerOffset, CGRectGetMidY(theViewBounds) };

	// #########################################################################

	CATransform3D theTransform = CATransform3DIdentity;
	theTransform.m34 = 1.0f / -850.0f; // Magic Number is Magic.

    const CGFloat theScale = [self.scaleInterpolator interpolatedValueForKey:theDelta];
    theTransform = CATransform3DScale(theTransform, theScale, theScale, 1.0f);

	const CGFloat theRotation = [self.rotationInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DTranslate(theTransform, self.cellSize.width * (theDelta > 0.0f ? 0.5f : -0.5f), 0.0f, 0.0f);
	theTransform = CATransform3DRotate(theTransform, theRotation * (CGFloat)M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
	theTransform = CATransform3DTranslate(theTransform, self.cellSize.width * (theDelta > 0.0f ? -0.5f : 0.5f), 0.0f, 0.0f);

	const CGFloat theZOffset = [self.zOffsetInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DTranslate(theTransform, 0.0, 0.0, theZOffset);

	theAttributes.transform3D = theTransform;

	// #########################################################################

	theAttributes.shieldAlpha = [self.darknessInterpolator interpolatedValueForKey:theDelta];

    theAttributes.zIndex = self.cellCount - abs((int)(self.currentIndexPath.row-indexPath.row));

	// #########################################################################

    return(theAttributes);
	}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
	{
	UICollectionViewLayoutAttributes *theAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
	theAttributes.center = (CGPoint){ .x = CGRectGetMidX(self.collectionView.bounds), .y = CGRectGetMaxY(self.collectionView.bounds) - 25};
	theAttributes.size = (CGSize){ 200, 50 };
	theAttributes.zIndex = 1;
	return(theAttributes);
	}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
    {
    CGPoint theTargetContentOffset = proposedContentOffset;
    if (self.snapToCells == YES)
        {
        theTargetContentOffset.x = roundf(theTargetContentOffset.x / self.cellSpacing) * self.cellSpacing;
        theTargetContentOffset.x = MIN(theTargetContentOffset.x, (self.cellCount - 1) * self.cellSpacing);
        }
    return(theTargetContentOffset);
    }


@end

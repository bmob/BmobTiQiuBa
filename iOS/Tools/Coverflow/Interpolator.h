//
//	Interpolator.h
//	Coverflow
//
//	Created by Jonathan Wight on 9/10/12.
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

#ifndef __InterpolatorTest__Interpolator__
#define __InterpolatorTest__Interpolator__

#include <vector>

#include <CoreGraphics/CoreGraphics.h>

template <typename T> class Interpolator {
    public:
        struct KV { CGFloat k; T v; };
        std::vector <KV> _kv;

        void addKV(CGFloat k, T v)
            {
            const KV kv = { .k = k, .v = v };
            _kv.push_back(kv);
            }

        T interpolate(const CGFloat key) const
            {
            CGFloat theHighKey = 0.0;

            typename std::vector <KV>::const_iterator theIterator = _kv.begin();
            for(; theIterator != _kv.end(); ++theIterator)
                {
                theHighKey = theIterator->k;

                if (theHighKey == key)
                    {
                    return(theIterator->v);
                    }
                else if (theHighKey > key)
                    {
                    break;
                    }
                }

            if (theIterator == _kv.begin())
                {
                return(_kv.begin()->v);
                }
            else if (theIterator == _kv.end())
                {
                return((_kv.end() - 1)->v);
                }

            const CGFloat theLowKey = (theIterator - 1)->k;
            const T theLowValue = (theIterator - 1)->v;
            const T theHighValue = theIterator->v;

            const CGFloat theWeight = (key - theLowKey) / (theHighKey - theLowKey);

            const T theInterpolatedValue = interpolate_inner(theWeight, theLowValue, theHighValue);

            return(theInterpolatedValue);
            }

        CGPoint interpolate_inner(const CGFloat weight, const CGPoint &low, const CGPoint &high) const
            {
            const CGPoint value = {
                .x = weight * (high.x - low.x) + low.x,
                .y = weight * (high.y - low.y) + low.y,
                };
            return(value);
            }

        CGSize interpolate_inner(const CGFloat weight, const CGSize &low, const CGSize &high) const
            {
            const CGSize value = {
                .width = weight * (high.width - low.width) + low.width,
                .height = weight * (high.height - low.height) + low.height,
                };
            return(value);
            }

        CGAffineTransform interpolate_inner(const CGFloat weight, const CGAffineTransform &low, const CGAffineTransform &high) const
            {
            const CGAffineTransform value = {
                .a = weight * (high.a - low.a) + low.a,
                .b = weight * (high.b - low.b) + low.b,
                .c = weight * (high.c - low.c) + low.c,
                .d = weight * (high.d - low.d) + low.d,
                .tx = weight * (high.tx - low.tx) + low.tx,
                .ty = weight * (high.ty - low.ty) + low.ty,
                };
            return(value);
            }

        T interpolate_inner(const CGFloat weight, const CGFloat low, const CGFloat high) const
            {
            const CGFloat value = weight * (high - low) + low;
            return(value);
            }

    };

#endif /* defined(__InterpolatorTest__Interpolator__) */

pragma solidity ^0.4.11;

library Float {

    struct float32 {
        bytes4 data;
    }

    enum roundingModes { near_even, near_maxMag, minMag, min, max, odd }


    bytes1 constant flag_inexact = 0x01;
    bytes1 constant flag_underflow = 0x02;
    bytes1 constant flag_overflow = 0x04;
    bytes1 constant flag_division_by_zero = 0x08;
    bytes1 constant flag_invalid_operation = 0x10;

    //helper
    function countLeadingZeros( uint256 a ) internal returns ( uint16 r ) {

        if ( a == 0 ) {
            r = 256;
            return;
        }

        if ( a < 2**(256-128) ) {
            r = 128;
            a = a << 128;
        }
        if ( a < 2**(256-64) ) {
            r += 64;
            a = a << 64;
        }
        if ( a < 2**(256-32) ) {
            r += 32;
            a = a << 32;
        }
        if ( a < 2**(256-16) ) {
            r += 16;
            a = a << 16;
        }
        if ( a < 2**(256-8) ) {
            r += 8;
            a = a << 8;
        }
        if ( a < 2**(256-4) ) {
            r += 4;
            a = a << 4;
        }
        if ( a < 2**(256-2) ) {
            r += 2;
            a = a << 2;
        }
        if ( a < 2**(256-1) ) {
            r += 1;
        }
    }

    //Conversions from Integer to Floating-Point
    function uint_to_float32( uint a ) internal returns ( float32 r, bytes1 errorFlags ) {

        if ( a == 0 ) {
            return;
        }

        uint16 leadingZeros = countLeadingZeros( uint256(a) );
        uint16 exp = (127+255) - leadingZeros;
        bytes32 frac = bytes32( a ) << ( leadingZeros + 1 );

        if ( exp >= ((2**8)-1) ) {
            errorFlags |= flag_overflow;
            // TODO: Check IEEE-754 spec for what to do when overflow happens
            // inexact flag?
            //exp = (2**8)-1;
            return;
        }

        if ( ( frac & ((2**(256-23))-1) ) != 0 ) {
            errorFlags |= flag_inexact;
            // TODO: Implement proper rounding, for now just truncates
        }

        r.data = bytes4( (uint32( exp ) << 23) + uint32(frac >> (256-23)) );

    }
   
    function int_to_float32( int a ) internal returns ( float32 r, bytes1 errorFlags ) {

        if ( a == 0 ) {
            return;
        }

        bool isNegative = a < 0;
        uint256 absA = isNegative ? uint256( 0 - a ) : uint256( a );

        (r, errorFlags) = uint_to_float32( absA );

        if ( isNegative ) {
            r.data = bytes4( (uint32(1) << 31) + uint32(r.data) );
        }
    }

    //Conversions from Floating-Point to Integer
    function float32_to_uint( float32 a ) internal returns ( uint r, bytes1 errorFlags ) {

        if ( a.data << 1 == 0 ) {
            return;
            //TODO check what to do with negative 0
            // for now, treat it the same as 0
        }

        bool isNeg = a.data & 2**31 != 0;
        int16 exp = int16(uint8( a.data >> 23 )) - 127;
        uint24 sig = uint24( a.data | 2**23 );

        if ( exp == 128 ) {

            if ( sig > 2**23 ) {
                //NaN
                errorFlags |= flag_invalid_operation;
                return;
            }

            errorFlags |= flag_inexact;
            if ( isNeg ) {
                errorFlags |= flag_underflow;
            } else {
                errorFlags |= flag_overflow;
            }

            return;
        }

        if ( isNeg ) {
            errorFlags |= flag_underflow | flag_inexact;
            return;
        }

        if ( exp < 0 ) {
            errorFlags |= flag_inexact | flag_underflow;
            return;
        }

        if ( exp < 23 ) {
            if ( sig & ( uint24( (2**23) - 1 ) >> exp ) != 0 ) {
                errorFlags |= flag_inexact;
            }
            r = sig >> ( 23 - exp );
            return;
        }

        r = uint256( sig ) << ( exp - 23 );
    }

    function float32_to_int( float32 a ) internal returns ( int r, bytes1 errorFlags ) {

        if ( a.data == 0 ) {
            return;
        }

        bool isNegative = a.data & 2**31 != 0;
        float32 memory absA;
        absA.data = a.data & (2**31) - 1;
        uint ur;

        (ur, errorFlags) = float32_to_uint( absA );

        if ( int(ur) < 0 ) {
            r = 0;
            errorFlags = flag_overflow | flag_inexact;
            return;
        }

        if ( isNegative ) {
            r = 0 - int(ur);
        } else {
            r = int(ur);
        }
    }

    //Basic Arithmetic Functions
    function add( float32 a, float32 b ) internal returns ( float32 r, bytes1 errorFlags ) {
        //inf and -inf
        //NaN
        if ( a.data == 0 ) {
            r.data = b.data;
        }
        if ( b.data == 0 ) {
            r.data = a.data;
        }

        bool aIsNeg = a.data & 2**31 != 0;
        bool bIsNeg = b.data & 2**31 != 0;

        if ( aIsNeg != bIsNeg ) {
            //signs aren't the same
            float32 memory abs;
            if ( aIsNeg ) {
                abs.data = a.data & (2**31) - 1;
                ( r, errorFlags ) = sub( b, abs );
            } else {
                abs.data = b.data & (2**31) - 1;
                ( r, errorFlags ) = sub( a, abs );
            }
            return;
        }
        
        uint8 expA = uint8( a.data >> 23 );
        uint8 expB = uint8( b.data >> 23 );

        uint24 sigA = uint24( a.data | 2**23 );
        uint24 sigB = uint24( b.data | 2**23 );
        
        uint16 expR;
        uint32 sigR;

        if ( expA > expB ) {
            expR = expA;
            if ( (sigB & (2**(expA - expB)) - 1) != 0 ) {
                errorFlags |= flag_inexact;
            }
            sigB >> ( expA - expB );
        } else {
            expR = expB;
            if ( (sigA & (2**(expB - expA)) - 1) != 0 ) {
                errorFlags |= flag_inexact;
            }
            sigA >> ( expB - expA );
        }

        sigR = sigA + sigB;

        if ( sigR > (2**24) - 1 ) {
            expR += 1;
            if ( sigR & 1 == 1 ) {
                errorFlags |= flag_inexact;
            }
            sigR >> 1;
        }
        if ( expR >= (2**8) - 1 ) {
            errorFlags |= flag_overflow;
            return;
        }

        r.data = bytes4( (uint32(a.data) & 2**31) + (uint32( uint8(expR) ) << 23) + (uint24(sigR) & (2**23) - 1) );

    }

    function sub( float32 a, float32 b ) internal returns ( float32 r, bytes1 errorFlags ) {
        //inf and -inf
        //NaN

        if ( a.data == 0 ) {
            r.data = (b.data ^ 2**31);
        }
        if ( b.data == 0 ) {
            r.data = a.data;
        }

        bool aIsNeg = a.data & 2**31 != 0;
        bool bIsNeg = b.data & 2**31 != 0;

        if ( aIsNeg != bIsNeg ) {
            //signs aren't the same
            float32 memory negB;
            negB.data = b.data ^ (2**31);
            ( r, errorFlags ) = add( a, b );
            // TODO: different precision of + and neg
            return;
        }
        
        uint8 expA = uint8( a.data >> 23 );
        uint8 expB = uint8( b.data >> 23 );

        uint24 sigA = uint24( a.data | 2**23 );
        uint24 sigB = uint24( b.data | 2**23 );
        
        uint16 expR;
        uint32 sigR;

        if ( expA > expB ) {
            expR = expA;
            if ( (sigB & (2**(expA - expB)) - 1) != 0 ) {
                errorFlags |= flag_inexact;
            }
            sigB >> ( expA - expB );
        } else {
            expR = expB;
            if ( (sigA & (2**(expB - expA)) - 1) != 0 ) {
                errorFlags |= flag_inexact;
            }
            sigA >> ( expB - expA );
        }

        sigR = sigA - sigB;

        if ( sigR < (2**24) - 1 ) {
            expR -= 1;
            if ( sigR & 2**23 > 0 ) {
                errorFlags |= flag_inexact;
            }
            sigR << 1;
        }
        if ( expR >= (2**8) - 1 ) {
            errorFlags |= flag_overflow;
            return;
        }

        r.data = bytes4( (uint32(a.data) & 2**31) + (uint32( uint8(expR) ) << 23) + (uint24(sigR) & (2**23) - 1) );


    }

    /*
    function mul(float32 _a, float32 _b) internal returns (float32 r) {
    }
    
    function div(float32 _a, float32 _b) internal returns (float32 r) {
    }

    function sqrt(float32 _a) internal returns (float32 r) {
    }

    //Fused Multiply-Add Functions
    function mulAdd(float32 _a, float32 _b, float32 _c) internal returns (float32 r) {
    }

    //Remainder Functions
    function rem(float32 _a, float32 _b) internal returns (float32 r) {
    }
    
    //Round-to-Integer Functions
    // TODO: specify rounding mode
    function roundToInt(float32 a, roundingModes roundingMode, bool exac) internal returns (float32 r) {
    }

    //Comparison Functions
    function eq(float32 a, float32 b) internal returns (bool r) {
    }
    
    function le(float32 a, float32 b) internal returns (bool r) {
    }

    function lt(float32 a, float32 b) internal returns (bool r) {
    }

    //Signaling NaN Test Functions
    function isSignalingNaN(float32 a) internal returns (bool r) {
    }

    */
}

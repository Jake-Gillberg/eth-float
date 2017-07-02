pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Float.sol";

contract TestFloat2 {

    function test_float32_to_uint() {
        Float.float32 memory p;
        uint r;
        bytes1 errorFlags;

        p.data = 0x00000000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "0");
        Assert.equal( uint(errorFlags), uint(0x00), "0 flags" );
 
        p.data = 0x80000000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "-0");
        Assert.equal( uint(errorFlags), uint(0x00), "-0 flags" );
        
        p.data = 0x3f800000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 1, "1");
        Assert.equal( uint(errorFlags), uint(0x00), "1 flags" );

        p.data = 0xbf800000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "-1");
        Assert.equal( uint(errorFlags), uint(0x03), "-1 flags" );

        p.data = 0x7f800000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "Infinity");
        Assert.equal( uint(errorFlags), uint(0x05), "Infinity flags" );

        p.data = 0xff800000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "-Infinity");
        Assert.equal( uint(errorFlags), uint(0x03), "-Infinity flags" );

        p.data = 0x7f800001;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "NaN +" );
        Assert.equal( uint(errorFlags), uint(0x10), "NaN+ flags" );
        
        p.data = 0xffc00000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "NaN -" );
        Assert.equal( uint(errorFlags), uint(0x10), "NaN- flags" );

        p.data = 0x4b000000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 2**23, "2^23" );
        Assert.equal( uint(errorFlags), uint(0x00), "2^23 flags" );
        
        p.data = 0x4afffffe;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, (2**23)-1, "2^23 - 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "2^23 - 1 flags" );

        p.data = 0x4b000001;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, (2**23)+1, "2^23 + 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "2^23 + 1 flags" );

        p.data = 0x4b800000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 2**24, "2^24" );
        Assert.equal( uint(errorFlags), uint(0x00), "2^24 flags" );

        p.data = 0x4affffff;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, (2**23)-1, "cut off decimal (1)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (1) flags" );

        p.data = 0x3fc00000;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 1, "cut off decimal (2)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (2) flags" );

        p.data = 0x3f800001;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 1, "cut off decimal (3)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (3) flags" );
        
        p.data = 0x00000001;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "very small decimal" );
        Assert.equal( uint(errorFlags), uint(0x03), "very small decimal flags" );

        p.data = 0x7f7fffff;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, ((2**24)-1) * (2**(127-23)), "largest" );
        Assert.equal( uint(errorFlags), uint(0x00), "largest flags" );

        p.data = 0x372d0b49;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "random 1" );
        Assert.equal( uint(errorFlags), uint(0x03), "random 1" );

        p.data = 0x5418b8df;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, uint(0x98b8df) * (2**(41-23)), "random 2" );
        Assert.equal( uint(errorFlags), uint(0x00), "random 2" );

        p.data = 0xebfc679f;
        (r, errorFlags) = Float.float32_to_uint( p );
        Assert.equal( r, 0, "random 3" );
        Assert.equal( uint(errorFlags), uint(0x03), "random 3" );
    }

    function test_float32_to_int() {
        Float.float32 memory p;
        int r;
        bytes1 errorFlags;

        p.data = 0x00000000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "0");
        Assert.equal( uint(errorFlags), uint(0x00), "0 flags" );

        p.data = 0x80000000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "-0");
        Assert.equal( uint(errorFlags), uint(0x00), "-0 flags" );

        p.data = 0x3f800000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 1, "1");
        Assert.equal( uint(errorFlags), uint(0x00), "1 flags" );

        p.data = 0xbf800000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -1, "-1");
        Assert.equal( uint(errorFlags), uint(0x00), "-1 flags" );

        p.data = 0x7f800000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "Infinity");
        Assert.equal( uint(errorFlags), uint(0x05), "Infinity flags" );

        p.data = 0xff800000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "-Infinity");
        Assert.equal( uint(errorFlags), uint(0x05), "-Infinity flags" );

        p.data = 0x7f800001;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "NaN +" );
        Assert.equal( uint(errorFlags), uint(0x10), "NaN+ flags" );
        
        p.data = 0xffc00000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "NaN -" );
        Assert.equal( uint(errorFlags), uint(0x10), "NaN- flags" );

        p.data = 0xcb000000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -(2**23), "-2^23" );
        Assert.equal( uint(errorFlags), uint(0x00), "-2^23 flags" );
        
        p.data = 0xcafffffe;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -((2**23)-1), "-2^23 - 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "-2^23 - 1 flags" );

        p.data = 0xcb000001;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -((2**23)+1), "2^23 + 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "-2^23 + 1 flags" );

        p.data = 0xcb800000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -(2**24), "-2^24" );
        Assert.equal( uint(errorFlags), uint(0x00), "-2^24 flags" );

        p.data = 0xcaffffff;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -((2**23)-1), "cut off decimal (1)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (1) flags" );

        p.data = 0xbfc00000;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -1, "cut off decimal (2)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (2) flags" );

        p.data = 0xbf800001;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -1, "cut off decimal (3)" );
        Assert.equal( uint(errorFlags), uint(0x01), "cut off decimal (3) flags" );
        
        p.data = 0x80000001;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "very small decimal" );
        Assert.equal( uint(errorFlags), uint(0x03), "very small decimal flags" );

        p.data = 0x7f7fffff;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, ((2**24)-1) * (2**(127-23)), "largest" );
        Assert.equal( uint(errorFlags), uint(0x00), "largest flags" );

        p.data = 0xff7fffff;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -(((2**24)-1) * (2**(127-23))), "smallest" );
        Assert.equal( uint(errorFlags), uint(0x00), "smallest flags" );

        p.data = 0x4d8e1d34;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, int(uint(0x8e1d34) * (2**(28-23))), "random 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "random 1" );

        p.data = 0x060680eb;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, 0, "random 2" );
        Assert.equal( uint(errorFlags), uint(0x03), "random 2" );

        p.data = 0xc505e001;
        (r, errorFlags) = Float.float32_to_int( p );
        Assert.equal( r, -2142, "random 3" );
        Assert.equal( uint(errorFlags), uint(0x01), "random 3" );
    }
}

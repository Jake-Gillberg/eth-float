pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Float.sol";

contract TestFloat {

    function test_countLeadingZeros() {

        Assert.equal( uint(Float.countLeadingZeros( 0 )), uint(256), "max" );

        Assert.equal( uint(Float.countLeadingZeros( 1 )), uint(255), "max - 1" );

        Assert.equal( uint(Float.countLeadingZeros( 2**255 )), uint(0), "min" );

        Assert.equal( uint(Float.countLeadingZeros( 2**256 - 1 )), uint(0), "min with other bits" );

        Assert.equal( uint(Float.countLeadingZeros( 2**8 )), uint(247), "boundry" );

        Assert.equal( uint(Float.countLeadingZeros( (2**8) + 1 )), uint(247), "boundry + 1" );

        Assert.equal( uint(Float.countLeadingZeros( (2**8) - 1 )), uint(248), "boundry - 1" );

        Assert.equal( uint(Float.countLeadingZeros( 2**9 )), uint(246), "boundry power + 1" );

        Assert.equal( uint(Float.countLeadingZeros( 2**7 )), uint(248), "boundry power - 1" );
    }

    function test_uint_to_float32() {
        Float.float32 memory r;
        bytes1 errorFlags;

        //edge-case like scenarios
        (r, errorFlags) = Float.uint_to_float32( 0 );
        Assert.equal( uint(r.data), uint(0x00000000), "0" );
        Assert.equal( uint(errorFlags), uint(0x00), "0 flags" );

        (r, errorFlags) = Float.uint_to_float32( 1 );
        Assert.equal( uint(r.data), uint(0x3f800000), "1" );
        Assert.equal( uint(errorFlags), uint(0x00), "1 flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**24)-1 );
        Assert.equal( uint(r.data), uint(0x4B7FFFFF), "24 bits of precision" );
        Assert.equal( uint(errorFlags), uint(0x00), "24 bits of precision flags" );
        
        (r, errorFlags) = Float.uint_to_float32( (2**24)+2 );
        Assert.equal( uint(r.data), uint(0x4B800001), "maintain precision when possible" );
        Assert.equal( uint(errorFlags), uint(0x00), "maintain precision when possible flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**24)+1 );
        Assert.equal( uint(r.data), uint(0x4B800000), "min truncation" );
        Assert.equal( uint(errorFlags), uint(0x01), "min truncation flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**24) );
        Assert.equal( uint(r.data), uint(0x4B800000), "min truncation - 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "min truncation - 1 flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**128)-1 );
        Assert.equal( uint(r.data), uint(0x7f7fffff), "max before overflow" );
        Assert.equal( uint(errorFlags), uint(0x01), "max before overflow flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**128) );
        Assert.equal( uint(r.data), uint(0x00000000), "min overflow" );
        Assert.equal( uint(errorFlags), uint(0x04), "min overflow flags" );

        (r, errorFlags) = Float.uint_to_float32( (2**256)-1 );
        Assert.equal( uint(r.data), uint(0x00000000), "max uint" );
        Assert.equal( uint(errorFlags), uint(0x04), "max uint" );

        // random uint256
        (r, errorFlags) = Float.uint_to_float32( uint(0xBE18CFDD9A1CC2E3A11C36F3F6549250D6F0B37C2E465C0506F89480C33488CC) );
        Assert.equal( uint(r.data), uint(0x00000000), "rand 01" );
        Assert.equal( uint(errorFlags), uint(0x04), "rand 01 flags" );

        (r, errorFlags) = Float.uint_to_float32( uint(0xE01D9FD692A19D627091002F56FBA259D7DDDF5473568A5B577841CBDC3205AE) );
        Assert.equal( uint(r.data), uint(0x00000000), "rand 02" );
        Assert.equal( uint(errorFlags), uint(0x04), "rand 02 flags" );

        (r, errorFlags) = Float.uint_to_float32( uint(0x0DA682177FEB707D4C3D691C1B934CD55993F97AD299CCAA84CB1B2B093798B3) );
        Assert.equal( uint(r.data), uint(0x00000000), "rand 03" );
        Assert.equal( uint(errorFlags), uint(0x04), "rand 03 flags" );

        // random uint256 without causing overflow (between 0 and 2^128-1)
        (r, errorFlags) = Float.uint_to_float32( 124192159465685481260683144897186324242 );
        Assert.equal( uint(r.data), uint(0x7ebadd14), "rand 11" );
        Assert.equal( uint(errorFlags), uint(0x01), "rand 11 flags" );

        (r, errorFlags) = Float.uint_to_float32( 501070869885445250800398932056126227 );
        Assert.equal( uint(r.data), uint(0x7ac10167), "rand 12" );
        Assert.equal( uint(errorFlags), uint(0x01), "rand 12 flags" );

        (r, errorFlags) = Float.uint_to_float32( 291713207871704001931586441341940319518 );
        Assert.equal( uint(r.data), uint(0x7f5b75eb), "rand 13" );
        Assert.equal( uint(errorFlags), uint(0x01), "rand 13 flags" );
    }

    function test_int_to_float32() {
        Float.float32 memory r;
        bytes1 errorFlags;

        (r, errorFlags) = Float.int_to_float32( 0 );
        Assert.equal( uint(r.data), uint(0x00000000), "0" );
        Assert.equal( uint(errorFlags), uint(0x00), "0 flags" );

        (r, errorFlags) = Float.int_to_float32( 1 );
        Assert.equal( uint(r.data), uint(0x3f800000), "1" );
        Assert.equal( uint(errorFlags), uint(0x00), "1 flags" );

        (r, errorFlags) = Float.int_to_float32( -1 );
        Assert.equal( uint(r.data), uint(0xBf800000), "-1" );
        Assert.equal( uint(errorFlags), uint(0x00), "-1 flags" );

        (r, errorFlags) = Float.int_to_float32( (2**24)-1 );
        Assert.equal( uint(r.data), uint(0x4B7FFFFF), "24 bits of precision" );
        Assert.equal( uint(errorFlags), uint(0x00), "24 bits of precision flags" );

        (r, errorFlags) = Float.int_to_float32( -((2**24)-1) );
        Assert.equal( uint(r.data), uint(0xCB7FFFFF), "24 bits of precision (neg)" );
        Assert.equal( uint(errorFlags), uint(0x00), "24 bits of precision (neg) flags" );
        
        (r, errorFlags) = Float.int_to_float32( (2**24)+2 );
        Assert.equal( uint(r.data), uint(0x4b800001), "maintain precision when possible" );
        Assert.equal( uint(errorFlags), uint(0x00), "maintain precision when possible flags" );

        (r, errorFlags) = Float.int_to_float32( -((2**24)+2) );
        Assert.equal( uint(r.data), uint(0xCb800001), "maintain precision when possible (neg)" );
        Assert.equal( uint(errorFlags), uint(0x00), "maintain precision when possible (neg) flags" );

        (r, errorFlags) = Float.int_to_float32( (2**24)+1 );
        Assert.equal( uint(r.data), uint(0x4B800000), "min truncation" );
        Assert.equal( uint(errorFlags), uint(0x01), "min truncation flags" );

        (r, errorFlags) = Float.int_to_float32( -((2**24)+1) );
        Assert.equal( uint(r.data), uint(0xCB800000), "min truncation (neg)" );
        Assert.equal( uint(errorFlags), uint(0x01), "min truncation (neg) flags" );

        (r, errorFlags) = Float.int_to_float32( (2**24) );
        Assert.equal( uint(r.data), uint(0x4B800000), "min truncation - 1" );
        Assert.equal( uint(errorFlags), uint(0x00), "min truncation - 1 flags" );

        (r, errorFlags) = Float.int_to_float32( -(2**24) );
        Assert.equal( uint(r.data), uint(0xCB800000), "min truncation - 1 (neg)" );
        Assert.equal( uint(errorFlags), uint(0x00), "min truncation - 1 (neg) flags" );

        (r, errorFlags) = Float.int_to_float32( (2**128)-1 );
        Assert.equal( uint(r.data), uint(0x7f7fffff), "max before overflow" );
        Assert.equal( uint(errorFlags), uint(0x01), "max before overflow flags" );

        (r, errorFlags) = Float.int_to_float32( -((2**128)-1) );
        Assert.equal( uint(r.data), uint(0xff7fffff), "max before overflow (neg)" );
        Assert.equal( uint(errorFlags), uint(0x01), "max before overflow (neg) flags" );

        (r, errorFlags) = Float.int_to_float32( (2**128) );
        Assert.equal( uint(r.data), uint(0x00000000), "min overflow" );
        Assert.equal( uint(errorFlags), uint(0x04), "min overflow flags" );
        
        (r, errorFlags) = Float.int_to_float32( -(2**128) );
        Assert.equal( uint(r.data), uint(0x80000000), "min (neg) overflow" );
        Assert.equal( uint(errorFlags), uint(0x04), "min (neg) overflow flags" );

        (r, errorFlags) = Float.int_to_float32( (2**255)-1 );
        Assert.equal( uint(r.data), uint(0x00000000), "max int" );
        Assert.equal( uint(errorFlags), uint(0x04), "max int" );

        (r, errorFlags) = Float.int_to_float32( -(2**255) );
        Assert.equal( uint(r.data), uint(0x80000000), "min int" );
        Assert.equal( uint(errorFlags), uint(0x04), "min int" );
    }
}

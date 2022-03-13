%builtins range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from contracts.lib.sha256.sha256 import sha256
from contracts.lib.bls_12_381.bls_12_381_gt import (
    GTPoint, g12, gt_two, gt_three, gt_negone, gt_negtwo, gt_negthree)
from contracts.lib.bls_12_381.bls_12_381_pair import gt_linefunc, pairing
from contracts.lib.bls_12_381.bls_12_381_field import (
    fq12_is_zero, FQ2, nondet_fq12, FQ12, assert_fq12_is_equal)
from contracts.lib.bls_12_381.bls_12_381_g1 import g1, G1Point
from contracts.lib.bls_12_381.bls_12_381_g2 import G2Point
from contracts.lib.bigint.bigint6 import BigInt6

# @Notice Testing the equality of two pairings derived from bls12-381 curves.
# @dev Specifically ompares pairings of e(g1, signature) and e(public_key, hashed_msg) from the Drand Network.
# @param {generator_1} is the first entry in the cyclic group G1 of the bls12-381 curves.
# @param {signature} is deserialized G2 point of the signature in the third entry of extra/payload.json
# @param {pub_key} is the deserialized G1 point of public key public_key in extra/drand.json
# @param {msg_on_curve} is the previous_signature (3rd in extras/payload.json) + round (3rd entry in extras/payload.json) hashed to the bls12-381 curve
func test_verify{range_check_ptr}() -> ():
    alloc_locals

    let (generator_1) = g1()

    let signature = G2Point(
        x=FQ2(
        e0=BigInt6(d0=0x44a90aa5dff92a77,
            d1=0x2e803ed372a9090f,
            d2=0x96e7e7dad0bd209f,
            d3=0xfbd8d23251dea400,
            d4=0xa1346c30d4619ec0,
            d5=0xd0e391e5505516
            ),
        e1=BigInt6(d0=0xe6d4f2357e7774d8,
            d1=0x6ccb3947043c7761,
            d2=0x8b575259f0a78179,
            d3=0xf3bc9900c0c5ea87,
            d4=0xbe93d7c260a61337,
            d5=0xcc7a7ad2637bdd8)
        ),
        y=FQ2(
        e0=BigInt6(d0=0x226834999d4ae2c8,
            d1=0x581172c81dca9836,
            d2=0xbb5d477c344eb6db,
            d3=0x7e1a44d515aaa42c,
            d4=0x2c69fa57738e12b4,
            d5=0x19c2af934e94fa5b),
        e1=BigInt6(d0=0x5b0eadb3105a5737,
            d1=0x6f79ce1ca37b6c0a,
            d2=0xc4d3277ab087cc6f,
            d3=0xcdf6b408cba33a52,
            d4=0x3f95f90b2fbb3136,
            d5=0x17a063d0e408f9a7
            )
        ))

    let pub_key = G1Point(
        BigInt6(d0=0x5cb38790fd530c16,
        d1=0x7817fc679976fff5,
        d2=0x154f95c7143ba1c1,
        d3=0xf0ae6acdf3d0e747,
        d4=0xedce6ecc21dbf440,
        d5=0x120177419e0bfb75),
        BigInt6(d0=0xbaac93d50ce72271,
        d1=0x8c22631a7918fd8e,
        d2=0xdd595f13570725ce,
        d3=0x51ac582950405194,
        d4=0xe1c8c3fad0059c0,
        d5=0xbbc3efc5008a26a))

    let msg_on_curve = G2Point(
        x=FQ2(
        e0=BigInt6(d0=0x44a90aa5dff92a77,
            d1=0x2e803ed372a9090f,
            d2=0x96e7e7dad0bd209f,
            d3=0xfbd8d23251dea400,
            d4=0xa1346c30d4619ec0,
            d5=0xd0e391e5505516
            ),
        e1=BigInt6(d0=0xe6d4f2357e7774d8,
            d1=0x6ccb3947043c7761,
            d2=0x8b575259f0a78179,
            d3=0xf3bc9900c0c5ea87,
            d4=0xbe93d7c260a61337,
            d5=0xcc7a7ad2637bdd8)
        ),
        y=FQ2(
        e0=BigInt6(d0=0x226834999d4ae2c8,
            d1=0x581172c81dca9836,
            d2=0xbb5d477c344eb6db,
            d3=0x7e1a44d515aaa42c,
            d4=0x2c69fa57738e12b4,
            d5=0x19c2af934e94fa5b),
        e1=BigInt6(d0=0x5b0eadb3105a5737,
            d1=0x6f79ce1ca37b6c0a,
            d2=0xc4d3277ab087cc6f,
            d3=0xcdf6b408cba33a52,
            d4=0x3f95f90b2fbb3136,
            d5=0x17a063d0e408f9a7
            )
        ))

    let (pair_one) = pairing(signature, generator_1)
    let (pair_two) = pairing(msg_on_curve, pub_key)

    assert_fq12_is_equal(pair_one, pair_two)
    return ()
end

func fq12_ex() -> (res : FQ12):
    return (
        FQ12(
        e0=BigInt6(1, 0, 0, 0, 0, 0), e1=BigInt6(0, 0, 0, 0, 0, 0), e2=BigInt6(0, 0, 0, 0, 0, 0),
        e3=BigInt6(0, 0, 0, 0, 0, 0), e4=BigInt6(0, 0, 0, 0, 0, 0), e5=BigInt6(0, 0, 0, 0, 0, 0),
        e6=BigInt6(0, 0, 0, 0, 0, 0), e7=BigInt6(0, 0, 0, 0, 0, 0), e8=BigInt6(0, 0, 0, 0, 0, 0),
        e9=BigInt6(0, 0, 0, 0, 0, 0), eA=BigInt6(0, 0, 0, 0, 0, 0), eB=BigInt6(0, 0, 0, 0, 0, 0),
        ))
end

# @notice Testing the ability to do perform calculations in a hint and subsequently assigning the result to an FQ12 struct
func test_nondet_fq12{range_check_ptr}() -> ():
    alloc_locals
    let (ex) = fq12_ex()
    let a = ex
    let b = ex

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bn128_field import FQ, FQ12
        from utils.bls_12_381_utils import parse_fq12, print_g12
        a = FQ12(list(map(FQ, parse_fq12(ids.a))))
        b = FQ12(list(map(FQ, parse_fq12(ids.b))))
        value = res = list(map(lambda x: x.n, (a*b).coeffs))
        # print("a*b =", value)
    %}

    let slope = nondet_fq12()

    return ()
end

# @notice Testing the equality functionality for an FQ12 struct
func test_fq12_equality{range_check_ptr}():
    alloc_locals

    let (ex) = fq12_ex()

    assert_fq12_is_equal(ex, ex)

    return ()
end

func main{range_check_ptr}() -> ():
    # test_nondet_fq12()
    # test_fq12_equality()
    test_verify()
    %{ print("all test passed") %}
    return ()
end

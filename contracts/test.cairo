%builtins range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from contracts.lib.sha256.sha256 import sha256
from contracts.lib.bls_12_381.bls_12_381_gt import g12, fq12_mul
from contracts.lib.bls_12_381.bls_12_381_pair import gt_linefunc, pairing
from contracts.lib.bls_12_381.bls_12_381_field import (
    fq12_is_zero, FQ2, nondet_fq12, FQ12, assert_fq12_is_equal, fq12_one)
from contracts.lib.bls_12_381.bls_12_381_g1 import g1, G1Point, g1_negone
from contracts.lib.bls_12_381.bls_12_381_g2 import G2Point, g2, g2_negone
from contracts.lib.bigint.bigint6 import BigInt6

# @Notice Testing the equality of two pairings derived from bls12-381 curves.
# @dev Specifically ompares pairings of e(g0, signature) and e(public_key, hashed_msg) from the Drand Network.
# @dev This takes a stupendous amount of time to run. If there is no error message, it's working.
# @param {generator_1} is the first entry in the cyclic group G1 of the bls12-381 curves.
# @param {signature} is deserialized G2 point of the signature in the third entry of extra/payload.json
# @param {pub_key} is the deserialized G1 point of public key public_key in extra/drand.json
# @param {msg_on_curve} is the previous_signature (3rd in extras/payload.json) + round (3rd entry in extras/payload.json) hashed to the bls12-381 curve
func test_verify_drand{range_check_ptr}() -> ():
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
        BigInt6(d0=0x292a3eb471a1d39,
        d1=0x7c2ab3ba8daf726,
        d2=0xb8703ffe83f431fd,
        d3=0x2369b63bc443d62a,
        d4=0x4526ab3ee2c6de3b,
        d5=0x404d215f7fed88d),
        BigInt6(d0=0x62596164f17f315a,
        d1=0xe2d76aef51f0f53b,
        d2=0x661e99e62e8ded37,
        d3=0x90808068823775cf,
        d4=0xbfa37496e2216355,
        d5=0x1787bddc978a21ca,))

    let msg_on_curve = G2Point(
        x=FQ2(
        e0=BigInt6(d0=0xacd9300650fa34,
            d1=0x8fff96bd982fed37,
            d2=0x9e2ab6072ff14600,
            d3=0x5489db58e07950e5,
            d4=0x808ec3a0409ec2a6,
            d5=0x93a5cce944fd7df,
            ),
        e1=BigInt6(d0=0xef81d20147c9ada0,
            d1=0x6535cd00fb18d345,
            d2=0x3b536eb63e04169d,
            d3=0x5e941fd496569f89,
            d4=0xf31263d42788482d,
            d5=0x11d4af9cf1f8c1e5,)
        ),
        y=FQ2(
        e0=BigInt6(d0=0xef26514e218ed3d7,
            d1=0x1d17345fe2e46b77,
            d2=0x9a397b42c2cbc6fa,
            d3=0x6e20e964fcd72aa4,
            d4=0x16d1bfdd2f21abd3,
            d5=0x148f26e95cf65d3a,),
        e1=BigInt6(d0=0xf15f6f2f3d00e5d6,
            d1=0xdcf19d2505933224,
            d2=0x52d3d860c4408edd,
            d3=0xfd20fcf81f4203ee,
            d4=0x88ede49d6291965d,
            d5=0x93bba4c9bcc5345,
            )
        ))
    let (pair_two) = pairing(msg_on_curve, pub_key)
    let (pair_one) = pairing(signature, generator_1)

    %{
        import sys, os
        from utils.bls_12_381_utils import print_fq12
        print(print_fq12("pair one", ids.pair_one))
        print("\n")
        print(print_fq12("pair two", ids.pair_two))
    %}

    assert_fq12_is_equal(pair_one, pair_two)

    return ()
end

func test_pairing_g1_mul_g2{range_check_ptr}() -> ():
    alloc_locals

    let (g_one) = g1()
    let (g_two) = g2()

    let (p1) = pairing(g_two, g_one)

    let desired_res = FQ12(
        e0=BigInt6(
        d0=1990975770884977028,
        d1=7767446592321502476,
        d2=16522345575435859632,
        d3=7644128085240456452,
        d4=11812039377315346276,
        d5=1595905830484019293,
        ),
        e1=BigInt6(
        d0=17885520176185831091,
        d1=5423534911467814785,
        d2=7504391331950224140,
        d3=2973556989001439003,
        d4=17874209731732675292,
        d5=476266876225452569,
        ),
        e2=BigInt6(
        d0=7677718715906000350,
        d1=15886597298094223646,
        d2=4581604490783232357,
        d3=9891841006135631689,
        d4=16685808909381775029,
        d5=898623410661343278,
        ),
        e3=BigInt6(
        d0=7246854971180863950,
        d1=2169887353992836472,
        d2=11430352139935480427,
        d3=9060736263656947316,
        d4=4807270687175777966,
        d5=109343983754950473,
        ),
        e4=BigInt6(
        d0=6999268678892249388,
        d1=10082433060938123587,
        d2=14060541885863151935,
        d3=4795961101061980583,
        d4=14192757544331031054,
        d5=1349352447261079491,
        ),
        e5=BigInt6(
        d0=17836131686739309765,
        d1=17108181119067608983,
        d2=15718011700245005585,
        d3=6675610338348864162,
        d4=16514759222970747599,
        d5=271480512774086705,
        ),
        e6=BigInt6(
        d0=4195467559401864831,
        d1=17826116083402014040,
        d2=11799215460093230448,
        d3=7662434289347384139,
        d4=6604795441874810821,
        d5=1530345683333496352,
        ),
        e7=BigInt6(
        d0=6170547824364410940,
        d1=5074553090179170658,
        d2=10068443902566038546,
        d3=17091902581826223961,
        d4=11746071311482025310,
        d5=1258767931794638597,
        ),
        e8=BigInt6(
        d0=714383951174429535,
        d1=4701333142292108801,
        d2=18185012512246210661,
        d3=246438992448698353,
        d4=8241596464302165885,
        d5=1648015829812454654,
        ),
        e9=BigInt6(
        d0=11882945526034394317,
        d1=15744607383066929664,
        d2=3691113978165864391,
        d3=18054759390624281060,
        d4=3894456018756502861,
        d5=728126088523876721,
        ),
        eA=BigInt6(
        d0=16512580089937471943,
        d1=11880175777650688844,
        d2=1057922167372043599,
        d3=2665440020709392870,
        d4=9221161676179572894,
        d5=1229590397142942377,
        ),
        eB=BigInt6(
        d0=6439019714097769582,
        d1=6683188422782918368,
        d2=15497754192530577565,
        d3=10833202628680126770,
        d4=16931670167157974043,
        d5=408860661728802227,
        ))

    assert_fq12_is_equal(p1, desired_res)
    return ()
end

func test_pairing_negative{range_check_ptr}() -> ():
    alloc_locals

    let (g_one) = g1()
    let (g_two) = g2()
    let (g_negone) = g1_negone()

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bls_12_381_utils import print_g1, print_g2
        cwd = os.getcwd()
        sys.path.append(cwd)
        print(print_g1("g1 ", ids.g_one))
        print(print_g2("g2 ", ids.g_two))
        print(print_g1("neg g_one ", ids.g_negone))
    %}

    let (p1) = pairing(g_two, g_one)
    let (p2) = pairing(g_two, g_negone)

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bls_12_381_utils import print_fq12
        print(print_fq12("p1 ", ids.p1))
        print(print_fq12("p2 ", ids.p2))
    %}

    let (res) = fq12_mul(p1, p2)

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bls_12_381_utils import print_fq12
        print(print_fq12("res ", ids.res))
    %}

    let (fq_12_one) = fq12_one()
    assert_fq12_is_equal(res, fq_12_one)

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
        from utils.bls_12_381_field import FQ, FQ12
        from utils.bls_12_381_utils import parse_fq12, print_g12
        a = FQ12(list(map(FQ, parse_fq12(ids.a))))
        b = FQ12(list(map(FQ, parse_fq12(ids.b))))
        value = res = list(map(lambda x: x.n, (a*b).coeffs))
        # print("a*b =", value)
    %}

    let (slope) = nondet_fq12()
    assert_fq12_is_equal(slope, ex)
    return ()
end

# @notice Testing the equality functionality for an FQ12 struct
func test_fq12_equality{range_check_ptr}():
    alloc_locals

    let (ex) = fq12_ex()

    assert_fq12_is_equal(ex, ex)

    return ()
end

func pairing_test{range_check_ptr}():
    alloc_locals
    let (local pt_g1 : G1Point) = g1()
    let (local pt_ng1 : G1Point) = g1_negone()
    let (local pt_g2 : G2Point) = g2()
    let (local pt_ng2 : G2Point) = g2_negone()
    let (local p1 : FQ12) = pairing(pt_g2, pt_g1)
    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)

        from utils.bls_12_381_field import FQ, FQ12
        from utils.bls_12_381_utils import parse_fq12, print_g12
        res = FQ12(list(map(FQ, parse_fq12(ids.p1))))
        print("pair(g2, g1) =", res)
    %}
    let (local pn1 : FQ12) = pairing(pt_g2, pt_ng1)
    let (local np1 : FQ12) = pairing(pt_ng2, pt_g1)
    let (local mul1) = fq12_mul(p1, pn1)
    let (local mul2) = fq12_mul(p1, np1)
    %{
        res_pn1 = FQ12(list(map(FQ, parse_fq12(ids.pn1))))
        res_np1 = FQ12(list(map(FQ, parse_fq12(ids.np1))))
        print("pair(g2, -g1) =", res_pn1)
        print("pair(-g2, g1) =", res_np1)
        mul1 = FQ12(list(map(FQ, parse_fq12(ids.mul1))))
        mul2 = FQ12(list(map(FQ, parse_fq12(ids.mul1))))
        print("pair(g2, g1) * pair(g2, -g1) =", mul1)
        print("pair(g2, g1) * pair(-g2, g1) =", mul2)
    %}

    %{ print("pairing test passed") %}
    return ()
end

func main{range_check_ptr}() -> ():
    # test_nondet_fq12()
    # test_fq12_equality()
    # test_verify_drand()
    # test_pairing_negative()
    %{
        import time
        tic = time.perf_counter()
    %}
    pairing_test()
    %{
        tac = time.perf_counter()
        print(f"Pairing computed in {tac - tic:0.4f} seconds")
    %}

    %{ print("all test passed") %}
    return ()
end

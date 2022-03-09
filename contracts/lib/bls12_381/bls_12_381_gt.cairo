from bigint import BigInt6, nondet_bigint6, bigint_mul
from contracts.lib.bls_12_381.alt_bn128_field import (
    fq_zero, is_zero, FQ12, nondet_fq12, fq12_eq_zero, fq12_sum, fq12_diff, fq12_is_zero, fq12_zero,
    unreducedFQ12)
from alt_bn128_g1 import G1Point
from alt_bn128_g2 import g2, G2Point

struct GTPoint:
    member x : FQ12
    member y : FQ12
end

func fq12_mul{range_check_ptr}(a : FQ12, b : FQ12) -> (res : FQ12):
    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bn128_field import FQ, FQ12
        from utils.bn128_utils import parse_fq12, print_g12
        a = FQ12(list(map(FQ, parse_fq12(ids.a))))
        b = FQ12(list(map(FQ, parse_fq12(ids.b))))
        value = res = list(map(lambda x: x.n, (a*b).coeffs))
        # print("a*b =", value)
    %}
    let (res) = nondet_fq12()
    # TODO CHECKS
    return (res=res)
end

func gt_doubling_slope{range_check_ptr}(pt : GTPoint) -> (slope : FQ12):
    %{
        from utils.bn128_field import FQ, FQ12
        from utils.bn128_utils import parse_fq12

        # Compute the slope.
        x = FQ12(list(map(FQ, parse_fq12(ids.pt.x))))
        y = FQ12(list(map(FQ, parse_fq12(ids.pt.y))))

        slope = (3 * x ** 2) / (2 * y)
        value = list(map(lambda x: x.n, slope.coeffs))
    %}
    let (slope : FQ12) = nondet_fq12()
    # TODO VERIFY
    return (slope=slope)
end

func gt_slope{range_check_ptr}(pt0 : GTPoint, pt1 : GTPoint) -> (slope : FQ12):
    %{
        from utils.bn128_field import FQ, FQ12
        from utils.bn128_utils import parse_fq12

        # Compute the slope.
        x0 = FQ12(list(map(FQ, parse_fq12(ids.pt0.x))))
        y0 = FQ12(list(map(FQ, parse_fq12(ids.pt0.y))))
        x1 = FQ12(list(map(FQ, parse_fq12(ids.pt1.x))))
        y1 = FQ12(list(map(FQ, parse_fq12(ids.pt1.y))))

        slope = (y0 - y1) / (x0 - x1)
        value = list(map(lambda x: x.n, slope.coeffs))
    %}
    let (slope) = nondet_fq12()

    # TODO verify
    return (slope)
end

# Given a point 'pt' on the elliptic curve, computes pt + pt.
func gt_double{range_check_ptr}(pt : GTPoint) -> (res : GTPoint):
    let (x_is_zero) = fq12_eq_zero(pt.x)
    if x_is_zero == 1:
        return (res=pt)
    end

    let (slope : FQ12) = gt_doubling_slope(pt)
    let (slope_sqr : FQ12) = fq12_mul(slope, slope)
    %{
        from utils.bn128_field import FQ, FQ12
        from utils.bn128_utils import parse_fq12

        # Compute the slope.
        x = FQ12(list(map(FQ, parse_fq12(ids.pt.x))))
        y = FQ12(list(map(FQ, parse_fq12(ids.pt.y))))
        slope = FQ12(list(map(FQ, parse_fq12(ids.slope))))
        res = slope ** 2 - x * 2
        value = new_x = list(map(lambda x: x.n, res.coeffs))
    %}
    let (new_x : FQ12) = nondet_fq12()

    %{
        new_x = FQ12(list(map(FQ, parse_fq12(ids.new_x))))
        res = slope * (x - new_x) - y
        value = new_x = list(map(lambda x: x.n, res.coeffs))
    %}
    let (new_y : FQ12) = nondet_fq12()

    # VERIFY
    # verify_zero5(
    #     UnreducedBigInt5(
    #     d0=slope_sqr.d0 - new_x.d0 - 2 * pt.x.d0,
    #     d1=slope_sqr.d1 - new_x.d1 - 2 * pt.x.d1,
    #     d2=slope_sqr.d2 - new_x.d2 - 2 * pt.x.d2,
    #     d3=slope_sqr.d3,
    #     d4=slope_sqr.d4))

    # let (x_diff_slope : UnreducedBigInt5) = bigint_mul(
    #     BigInt6(d0=pt.x.d0 - new_x.d0, d1=pt.x.d1 - new_x.d1, d2=pt.x.d2 - new_x.d2), slope)

    # verify_zero5(
    #     UnreducedBigInt5(
    #     d0=x_diff_slope.d0 - pt.y.d0 - new_y.d0,
    #     d1=x_diff_slope.d1 - pt.y.d1 - new_y.d1,
    #     d2=x_diff_slope.d2 - pt.y.d2 - new_y.d2,
    #     d3=x_diff_slope.d3,
    #     d4=x_diff_slope.d4))

    return (GTPoint(new_x, new_y))
end

func fast_gt_add{range_check_ptr}(pt0 : GTPoint, pt1 : GTPoint) -> (res : GTPoint):
    let (pt0_x_is_zero) = fq12_eq_zero(pt0.x)
    if pt0_x_is_zero == 1:
        return (pt1)
    end
    let (pt1_x_is_zero) = fq12_eq_zero(pt1.x)
    if pt1_x_is_zero == 1:
        return (pt1)
    end

    let (slope : FQ12) = gt_slope(pt0, pt1)
    let (slope_sqr : FQ12) = fq12_mul(slope, slope)

    %{
        from utils.bn128_field import FQ, FQ12
        from utils.bn128_utils import parse_fq12

        # Compute the slope.
        x0 = FQ12(list(map(FQ, parse_fq12(ids.pt0.x))))
        x1 = FQ12(list(map(FQ, parse_fq12(ids.pt1.x))))
        y0 = FQ12(list(map(FQ, parse_fq12(ids.pt0.y))))
        slope = FQ12(list(map(FQ, parse_fq12(ids.slope))))

        res = slope ** 2 - x0 - x1
        value = new_x = list(map(lambda x: x.n, res.coeffs))
    %}
    let (new_x : FQ12) = nondet_fq12()

    %{
        new_x = res
        res = slope * (x0 - new_x) - y0
        value = new_x = list(map(lambda x: x.n, res.coeffs))
    %}
    let (new_y : FQ12) = nondet_fq12()

    # verify_zero5(
    #     UnreducedBigInt5(
    #     d0=slope_sqr.d0 - new_x.d0 - pt0.x.d0 - pt1.x.d0,
    #     d1=slope_sqr.d1 - new_x.d1 - pt0.x.d1 - pt1.x.d1,
    #     d2=slope_sqr.d2 - new_x.d2 - pt0.x.d2 - pt1.x.d2,
    #     d3=slope_sqr.d3,
    #     d4=slope_sqr.d4))

    # let (x_diff_slope : UnreducedBigInt5) = bigint_mul(
    #     BigInt6(d0=pt0.x.d0 - new_x.d0, d1=pt0.x.d1 - new_x.d1, d2=pt0.x.d2 - new_x.d2), slope)

    # verify_zero5(
    #     UnreducedBigInt5(
    #     d0=x_diff_slope.d0 - pt0.y.d0 - new_y.d0,
    #     d1=x_diff_slope.d1 - pt0.y.d1 - new_y.d1,
    #     d2=x_diff_slope.d2 - pt0.y.d2 - new_y.d2,
    #     d3=x_diff_slope.d3,
    #     d4=x_diff_slope.d4))

    return (GTPoint(new_x, new_y))
end

func gt_add{range_check_ptr}(pt0 : GTPoint, pt1 : GTPoint) -> (res : GTPoint):
    let (x_diff) = fq12_diff(pt0.x, pt1.x)
    let (same_x : felt) = fq12_is_zero(x_diff)
    if same_x == 0:
        return fast_gt_add(pt0, pt1)
    end

    # We have pt0.x = pt1.x. This implies pt0.y = ±pt1.y.
    # Check whether pt0.y = -pt1.y.
    let (y_sum) = fq12_sum(pt0.x, pt0.y)
    let (opposite_y : felt) = fq12_is_zero(y_sum)
    if opposite_y != 0:
        # pt0.y = -pt1.y.
        # Note that the case pt0 = pt1 = 0 falls into this branch as well.
        let (zero_12) = fq12_zero()
        let ZERO_POINT = GTPoint(zero_12, zero_12)
        return (ZERO_POINT)
    else:
        # pt0.y = pt1.y.
        return gt_double(pt0)
    end
end

# ### CASTING G1 INTO GT

func g1_to_gt{range_check_ptr}(pt : G1Point) -> (res : GTPoint):
    # Point should not be zero
    alloc_locals
    let (x_iszero) = is_zero(pt.x)
    let (y_iszero) = is_zero(pt.y)
    assert x_iszero + y_iszero = 0

    let (zero : BigInt6) = fq_zero()
    return (
        GTPoint(
        x=FQ12(pt.x, zero, zero, zero,
            zero, zero, zero, zero,
            zero, zero, zero, zero),
        y=FQ12(pt.y, zero, zero, zero,
            zero, zero, zero, zero,
            zero, zero, zero, zero)))
end

# ### TWISTING G2 INTO GT

func twist{range_check_ptr}(P : G2Point) -> (res : GTPoint):
    let (zero : BigInt6) = fq_zero()
    tempvar x0 = P.x.e0
    tempvar x1 = P.x.e1

    let xx = BigInt6(
        d0=x0.d0 - 9 * x1.d0,
        d1=x0.d1 - 9 * x1.d1,
        d2=x0.d2 - 9 * x1.d2,
        d3=x0.d3 - 9 * x1.d3,
        d4=x0.d4 - 9 * x1.d4,
        d5=x0.d5 - 9 * x1.d5)
    let nxw2 = FQ12(zero, zero, xx, zero, zero, zero, zero, zero, x1, zero, zero, zero)

    tempvar y0 = P.y.e0
    tempvar y1 = P.y.e1
    let yy = BigInt6(
        d0=y0.d0 - 9 * y1.d0,
        d1=y0.d1 - 9 * y1.d1,
        d2=y0.d2 - 9 * y1.d2,
        d3=y0.d3 - 9 * y1.d3,
        d4=y0.d4 - 9 * y1.d4,
        d5=y0.d5 - 9 * y1.d5)
    let nyw3 = FQ12(zero, zero, zero, yy, zero, zero, zero, zero, zero, y1, zero, zero)

    return (res=GTPoint(x=nxw2, y=nyw3))
end

# CONSTANTS
func g12{range_check_ptr}() -> (res : GTPoint):
    let g2_tmp : G2Point = g2()
    let res : GTPoint = twist(g2_tmp)
    return (res=res)
end

func gt_two() -> (res : GTPoint):
    return (
        GTPoint(
        FQ12(
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0x4ea401a473348a22,
                d1=0x4ee9cd781eb70894,
                d2=0xaf43cbf47739b252,
                d3=0x2807259ae7bd1fed,
                d4=0x00,
                d5=0x00),
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0x9957ed8c3928ad79,
                d1=0x6db86431c6d83584,
                d2=0xb60121b83a733370,
                d3=0x203e205db4f19b37,
                d4=0x00,
                d5=0x00),
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            ),
        FQ12(
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            BigInt6(d0=0x3adf74ac770f63af,
                d1=0x5cfca6612b11258f,
                d2=0x36c5a6f8c78f2856,
                d3=0x125dfc2389e068e4,
                d4=0x00,
                d5=0x00), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            BigInt6(d0=0x98e185f0509de152,
                d1=0x3505566b4edf48d4,
                d2=0x722b8c153931579d,
                d3=0x195e8aa5b7827463,
                d4=0x00,
                d5=0x00), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0), BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0),
            )))
end

func gt_three() -> (res : GTPoint):
    return (
        GTPoint(
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0x98e185f0509de152,
                d1=0x3505566b4edf48d4,
                d2=0x722b8c153931579d,
                d3=0x195e8aa5b7827463,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0xc9824f32ffb66e85,
                d1=0xbc04156b6878a0a7,
                d2=0x735191cd5dcfe4eb,
                d3=0x1014772f57bb9742,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            ),
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0x32a1b85386b9b39c,
                d1=0x37039a5a1633bbd9,
                d2=0x9beb72787eb6f4bb,
                d3=0x22e32ee3d607b095,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0x452aeaca147711b2,
                d1=0xdd9453ac49b55441,
                d2=0x922ffcc2f38d3323,
                d3=0x021e2335f3354bb7,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            )))
end

func gt_negone() -> (res : GTPoint):
    return (
        GTPoint(
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0x1c78c659ed78407e,
                d1=0xddcda4df1e9eaff8,
                d2=0xd6949f86240cb7f7,
                d3=0x23f336fd559fb538,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0x97e485b7aef312c2,
                d1=0xf1aa493335a9e712,
                d2=0x7260bfb731fb5d25,
                d3=0x198e9393920d483a,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            ),
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0x7a0c59ab1abfd742,
                d1=0x235168d4819a6885,
                d2=0x4e97afe1a2213756,
                d3=0x0e0e2b3a5ea16610,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0xe673b13a075a65ec,
                d1=0xdb36395df7be3b99,
                d2=0xcbb1ac09187524c7,
                d3=0x275dc4a288d1afb3,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            )))
end

func gt_negtwo() -> (res : GTPoint):
    return (
        GTPoint(
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0x4ea401a473348a22,
                d1=0x4ee9cd781eb70894,
                d2=0xaf43cbf47739b252,
                d3=0x2807259ae7bd1fed,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0x9957ed8c3928ad79,
                d1=0x6db86431c6d83584,
                d2=0xb60121b83a733370,
                d3=0x203e205db4f19b37,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            ),
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0x0141176a616d9998,
                d1=0x3a84c4303d60a4fe,
                d2=0x818a9ebdb9f23007,
                d3=0x1e06524f57513745,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0xa33f062687df1bf5,
                d1=0x627c1426199281b8,
                d2=0x4624b9a1485000c0,
                d3=0x1705c3cd29af2bc6,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            )))
end

func gt_negthree() -> (res : GTPoint):
    return (
        GTPoint(
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0xb1abd5802108dd1d,
                d1=0xb7ddc67a3db217c1,
                d2=0x6cf7d91219c76e2d,
                d3=0x067b0926dbad9db7,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0xc9824f32ffb66e85,
                d1=0xbc04156b6878a0a7,
                d2=0x735191cd5dcfe4eb,
                d3=0x1014772f57bb9742,
                d4=0x00,
                d5=0x00),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            ),
        FQ12(
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0x097ed3c351c349ab,
                d1=0x607dd037523e0eb4,
                d2=0x1c64d33e02ca63a2,
                d3=0x0d811f8f0b29ef94,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            BigInt3(d0=0xf6f5a14cc405eb95,
                d1=0xb9ed16e51ebc764b,
                d2=0x262048f38df42539,
                d3=0x2e462b3cedfc5472,
                d4=0x00,
                d5=0x00), BigInt3(d0=0, d1=0, d2=0), BigInt3(d0=0, d1=0, d2=0),
            )))
end

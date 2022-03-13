from contracts.lib.bigint.bigint6 import (
    BigInt6, UnreducedBigInt6, nondet_bigint6, UnreducedBigInt10, bigint_mul, solve_for_y)
from contracts.lib.bls_12_381.bls_12_381_field import is_zero, verify_zero10
from contracts.lib.bls_12_381.bls_12_381_def import P0, P1, P2

# Represents a point on the elliptic curve.
# The zero point is represented using pt.x=0, as there is no point on the curve with this x value.
struct G1Point:
    member x : BigInt6
    member y : BigInt6
end

# Returns the slope of the elliptic curve at the given point.
# The slope is used to compute pt + pt.
# Assumption: pt != 0.
func compute_doubling_slope{range_check_ptr}(pt : G1Point) -> (slope : BigInt6):
    # Note that y cannot be zero: assume that it is, then pt = -pt, so 2 * pt = 0, which
    # contradicts the fact that the size of the curve is odd.
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        from starkware.python.math_utils import div_mod

        P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47

        # Compute the slope.
        x = pack(ids.pt.x, PRIME)
        y = pack(ids.pt.y, PRIME)
        value = slope = div_mod(3 * x ** 2, 2 * y, P)
    %}
    let (slope : BigInt6) = nondet_bigint6()

    let (x_sqr : UnreducedBigInt10) = bigint_mul(pt.x, pt.x)
    let (slope_y : UnreducedBigInt10) = bigint_mul(slope, pt.y)

    verify_zero10(
        UnreducedBigInt10(
        d0=3 * x_sqr.d0 - 2 * slope_y.d0,
        d1=3 * x_sqr.d1 - 2 * slope_y.d1,
        d2=3 * x_sqr.d2 - 2 * slope_y.d2,
        d3=3 * x_sqr.d3 - 2 * slope_y.d3,
        d4=3 * x_sqr.d4 - 2 * slope_y.d4,
        d5=3 * x_sqr.d5 - 2 * slope_y.d5,
        d6=3 * x_sqr.d6 - 2 * slope_y.d6,
        d7=3 * x_sqr.d7 - 2 * slope_y.d7,
        d8=3 * x_sqr.d8 - 2 * slope_y.d8,
        d9=3 * x_sqr.d9 - 2 * slope_y.d9
        ))

    return (slope=slope)
end

# Returns the slope of the line connecting the two given points.
# The slope is used to compute pt0 + pt1.
# Assumption: pt0.x != pt1.x (mod field prime).
func compute_slope{range_check_ptr}(pt0 : G1Point, pt1 : G1Point) -> (slope : BigInt6):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        from starkware.python.math_utils import div_mod

        P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
        # Compute the slope.
        x0 = pack(ids.pt0.x, PRIME)
        y0 = pack(ids.pt0.y, PRIME)
        x1 = pack(ids.pt1.x, PRIME)
        y1 = pack(ids.pt1.y, PRIME)
        value = slope = div_mod(y0 - y1, x0 - x1, P)
    %}
    let (slope) = nondet_bigint6()

    let x_diff = BigInt6(
        d0=pt0.x.d0 - pt1.x.d0,
        d1=pt0.x.d1 - pt1.x.d1,
        d2=pt0.x.d2 - pt1.x.d2,
        d3=pt0.x.d3 - pt1.x.d3,
        d4=pt0.x.d4 - pt1.x.d4,
        d5=pt0.x.d5 - pt1.x.d5)
    let (x_diff_slope : UnreducedBigInt10) = bigint_mul(x_diff, slope)

    verify_zero10(
        UnreducedBigInt10(
        d0=x_diff_slope.d0 - pt0.y.d0 + pt1.y.d0,
        d1=x_diff_slope.d1 - pt0.y.d1 + pt1.y.d1,
        d2=x_diff_slope.d2 - pt0.y.d2 + pt1.y.d2,
        d3=x_diff_slope.d3 - pt0.y.d3 + pt1.y.d3,
        d4=x_diff_slope.d4 - pt0.y.d4 + pt1.y.d4,
        d5=x_diff_slope.d5 - pt0.y.d5 + pt1.y.d5,
        d6=x_diff_slope.d6,
        d7=x_diff_slope.d7,
        d8=x_diff_slope.d8,
        d9=x_diff_slope.d9))

    return (slope)
end

# Given a point 'pt' on the elliptic curve, computes pt + pt.
func ec_double{range_check_ptr}(pt : G1Point) -> (res : G1Point):
    if pt.x.d0 == 0:
        if pt.x.d1 == 0:
            if pt.x.d2 == 0:
                return (pt)
            end
        end
    end

    let (slope : BigInt6) = compute_doubling_slope(pt)
    let (slope_sqr : UnreducedBigInt10) = bigint_mul(slope, slope)

    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack

        P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
        slope = pack(ids.slope, PRIME)
        x = pack(ids.pt.x, PRIME)
        y = pack(ids.pt.y, PRIME)

        value = new_x = (pow(slope, 2, P) - 2 * x) % P
    %}
    let (new_x : BigInt6) = nondet_bigint6()

    %{ value = new_y = (slope * (x - new_x) - y) % P %}
    let (new_y : BigInt6) = nondet_bigint6()

    verify_zero10(
        UnreducedBigInt10(
        d0=slope_sqr.d0 - new_x.d0 - 2 * pt.x.d0,
        d1=slope_sqr.d1 - new_x.d1 - 2 * pt.x.d1,
        d2=slope_sqr.d2 - new_x.d2 - 2 * pt.x.d2,
        d3=slope_sqr.d3 - new_x.d3 - 2 * pt.x.d3,
        d4=slope_sqr.d4 - new_x.d4 - 2 * pt.x.d4,
        d5=slope_sqr.d5 - new_x.d5 - 2 * pt.x.d5,
        d6=slope_sqr.d6,
        d7=slope_sqr.d7,
        d8=slope_sqr.d8,
        d9=slope_sqr.d9))

    let (x_diff_slope : UnreducedBigInt10) = bigint_mul(
        BigInt6(d0=pt.x.d0 - new_x.d0, d1=pt.x.d1 - new_x.d1, d2=pt.x.d2 - new_x.d2, d3=pt.x.d3 - new_x.d3, d4=pt.x.d4 - new_x.d4, d5=pt.x.d5 - new_x.d5),
        slope)

    verify_zero10(
        UnreducedBigInt10(
        d0=x_diff_slope.d0 - pt.y.d0 - new_y.d0,
        d1=x_diff_slope.d1 - pt.y.d1 - new_y.d1,
        d2=x_diff_slope.d2 - pt.y.d2 - new_y.d2,
        d3=x_diff_slope.d3 - pt.y.d3 - new_y.d3,
        d4=x_diff_slope.d4 - pt.y.d4 - new_y.d4,
        d5=x_diff_slope.d5 - pt.y.d5 - new_y.d5,
        d6=x_diff_slope.d6,
        d7=x_diff_slope.d7,
        d8=x_diff_slope.d8,
        d9=x_diff_slope.d9))

    return (G1Point(new_x, new_y))
end

# Adds two points on the elliptic curve.
# Assumption: pt0.x != pt1.x (however, pt0 = pt1 = 0 is allowed).
# Note that this means that the function cannot be used if pt0 = pt1
# (use ec_double() in this case) or pt0 = -pt1 (the result is 0 in this case).
func fast_ec_add{range_check_ptr}(pt0 : G1Point, pt1 : G1Point) -> (res : G1Point):
    if pt0.x.d0 == 0:
        if pt0.x.d1 == 0:
            if pt0.x.d2 == 0:
                return (pt1)
            end
        end
    end
    if pt1.x.d0 == 0:
        if pt1.x.d1 == 0:
            if pt1.x.d2 == 0:
                return (pt0)
            end
        end
    end

    let (slope : BigInt6) = compute_slope(pt0, pt1)
    let (slope_sqr : Unreduced10) = bigint_mul(slope, slope)

    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack

        P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
        slope = pack(ids.slope, PRIME)
        x0 = pack(ids.pt0.x, PRIME)
        x1 = pack(ids.pt1.x, PRIME)
        y0 = pack(ids.pt0.y, PRIME)

        value = new_x = (pow(slope, 2, P) - x0 - x1) % P
    %}
    let (new_x : BigInt6) = nondet_bigint6()

    %{ value = new_y = (slope * (x0 - new_x) - y0) % P %}
    let (new_y : BigInt6) = nondet_bigint6()

    verify_zero10(
        UnreducedBigInt10(
        d0=slope_sqr.d0 - new_x.d0 - pt0.x.d0 - pt1.x.d0,
        d1=slope_sqr.d1 - new_x.d1 - pt0.x.d1 - pt1.x.d1,
        d2=slope_sqr.d2 - new_x.d2 - pt0.x.d2 - pt1.x.d2,
        d3=slope_sqr.d3 - new_x.d3 - pt0.x.d3 - pt1.x.d3,
        d4=slope_sqr.d4 - new_x.d4 - pt0.x.d4 - pt1.x.d4,
        d5=slope_sqr.d5 - new_x.d5 - pt0.x.d5 - pt1.x.d5,
        d6=slope_sqr.d6,
        d7=slope_sqr.d7,
        d8=slope_sqr.d8,
        d9=slope_sqr.d9))

    let (x_diff_slope : UnreducedBigInt10) = bigint_mul(
        BigInt6(d0=pt0.x.d0 - new_x.d0, d1=pt0.x.d1 - new_x.d1, d2=pt0.x.d2 - new_x.d2, d3=pt0.x.d3 - new_x.d3, d4=pt0.x.d4 - new_x.d4, d5=pt0.x.d5 - new_x.d5),
        slope)

    verify_zero10(
        UnreducedBigInt10(
        d0=x_diff_slope.d0 - pt0.y.d0 - new_y.d0,
        d1=x_diff_slope.d1 - pt0.y.d1 - new_y.d1,
        d2=x_diff_slope.d2 - pt0.y.d2 - new_y.d2,
        d3=x_diff_slope.d3 - pt0.y.d3 - new_y.d3,
        d4=x_diff_slope.d4 - pt0.y.d4 - new_y.d4,
        d5=x_diff_slope.d5 - pt0.y.d5 - new_y.d5,
        d6=x_diff_slope.d6,
        d7=x_diff_slope.d7,
        d8=x_diff_slope.d8,
        d9=x_diff_slope.d9))

    return (G1Point(new_x, new_y))
end

# Same as fast_ec_add, except that the cases pt0 = ±pt1 are supported.
func ec_add{range_check_ptr}(pt0 : G1Point, pt1 : G1Point) -> (res : G1Point):
    let x_diff = BigInt6(
        d0=pt0.x.d0 - pt1.x.d0,
        d1=pt0.x.d1 - pt1.x.d1,
        d2=pt0.x.d2 - pt1.x.d2,
        d3=pt0.x.d3 - pt1.x.d3,
        d4=pt0.x.d4 - pt1.x.d4,
        d5=pt0.x.d5 - pt1.x.d5)
    let (same_x : felt) = is_zero(x_diff)
    if same_x == 0:
        # pt0.x != pt1.x so we can use fast_ec_add.
        return fast_ec_add(pt0, pt1)
    end

    # We have pt0.x = pt1.x. This implies pt0.y = ±pt1.y.
    # Check whether pt0.y = -pt1.y.
    let y_sum = BigInt6(
        d0=pt0.y.d0 + pt1.y.d0,
        d1=pt0.y.d1 + pt1.y.d1,
        d2=pt0.y.d2 + pt1.y.d2,
        d3=pt0.y.d3 + pt1.y.d3,
        d4=pt0.y.d4 + pt1.y.d4,
        d5=pt0.y.d5 + pt1.y.d5)
    let (opposite_y : felt) = is_zero(y_sum)
    if opposite_y != 0:
        # pt0.y = -pt1.y.
        # Note that the case pt0 = pt1 = 0 falls into this branch as well.
        let ZERO_POINT = G1Point(BigInt6(0, 0, 0, 0, 0, 0), BigInt6(0, 0, 0, 0, 0, 0))
        return (ZERO_POINT)
    else:
        # pt0.y = pt1.y.
        return ec_double(pt0)
    end
end

# Given 0 <= m < 250, a scalar and a point on the elliptic curve, pt,
# verifies that 0 <= scalar < 2**m and returns (2**m * pt, scalar * pt).
func ec_mul_inner{range_check_ptr}(pt : G1Point, scalar : felt, m : felt) -> (
        pow2 : G1Point, res : G1Point):
    if m == 0:
        assert scalar = 0
        let ZERO_POINT = G1Point(BigInt6(0, 0, 0, 0, 0, 0), BigInt6(0, 0, 0, 0, 0, 0))
        return (pow2=pt, res=ZERO_POINT)
    end

    alloc_locals
    let (double_pt : G1Point) = ec_double(pt)
    %{ memory[ap] = (ids.scalar % PRIME) % 2 %}
    jmp odd if [ap] != 0; ap++
    return ec_mul_inner(pt=double_pt, scalar=scalar / 2, m=m - 1)

    odd:
    let (local inner_pow2 : G1Point, inner_res : G1Point) = ec_mul_inner(
        pt=double_pt, scalar=(scalar - 1) / 2, m=m - 1)
    # Here inner_res = (scalar - 1) / 2 * double_pt = (scalar - 1) * pt.
    # Assume pt != 0 and that inner_res = ±pt. We obtain (scalar - 1) * pt = ±pt =>
    # scalar - 1 = ±1 (mod N) => scalar = 0 or 2.
    # In both cases (scalar - 1) / 2 cannot be in the range [0, 2**(m-1)), so we get a
    # contradiction.
    let (res : G1Point) = fast_ec_add(pt0=pt, pt1=inner_res)
    return (pow2=inner_pow2, res=res)
end

func ec_mul{range_check_ptr}(pt : G1Point, scalar : BigInt6) -> (res : G1Point):
    alloc_locals
    let (pow2_0 : G1Point, local res0 : G1Point) = ec_mul_inner(pt, scalar.d0, 64)
    let (pow2_1 : G1Point, local res1 : G1Point) = ec_mul_inner(pow2_0, scalar.d1, 64)
    let (pow2_2 : G1Point, local res2 : G1Point) = ec_mul_inner(pow2_1, scalar.d2, 64)
    let (pow2_3 : G1Point, local res3 : G1Point) = ec_mul_inner(pow2_2, scalar.d3, 64)
    let (pow2_4 : G1Point, local res4 : G1Point) = ec_mul_inner(pow2_3, scalar.d4, 64)
    let (pow2_5 : G1Point, local res5 : G1Point) = ec_mul_inner(pow2_4, scalar.d5, 64)

    let (_, local res2 : G1Point) = ec_mul_inner(pow2_4, scalar.d4, 64)

    let (res_add_1 : G1Point) = ec_add(res0, res1)
    let (res_add_2 : G1Point) = ec_add(res_add_1, res2)
    let (res_add_3 : G1Point) = ec_add(res_add_2, res3)
    let (res_add_4 : G1Point) = ec_add(res_add_3, res4)
    let (res_add_5 : G1Point) = ec_add(res_add_4, res5)
    return (res_add_5)
end

# CONSTANTS
func g1() -> (res : G1Point):
    return (
        res=G1Point(BigInt6(d0=0x5cb38790fd530c16,
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
            d5=0xbbc3efc5008a26a)))
end

func g1_two() -> (res : G1Point):
    return (
        G1Point(
        BigInt6(d0=0xd3c208c16d87cfd3,
            d1=0xd97816a916871ca8,
            d2=0x9b85045b68181585,
            d3=0x030644e72e131a02,
            d4=0x00,
            d5=0x00),
        BigInt6(d0=0xff3ebf7a5a18a2c4,
            d1=0x68a6a449e3538fc7,
            d2=0xe7845f96b2ae9c0a,
            d3=0x15ed738c0e0a7c92,
            d4=0x00,
            d5=0x00,)))
end

func g1_three() -> (res : G1Point):
    return (
        G1Point(
        BigInt6(d0=0xf2d355961915abf0,
            d1=0x9315d84715b8e679,
            d2=0xf40232bcb1b6bd15,
            d3=0x0769bf9ac56bea3f,
            d4=0x00,
            d5=0x00),
        BigInt6(d0=0xcdf1ff3dd9fe2261,
            d1=0x319e63b40b9c5b57,
            d2=0x554fdb7c8d086475,
            d3=0x2ab799bee0489429,
            d4=0x00,
            d5=0x00,)))
end

func g1_negone() -> (res : G1Point):
    return (
        G1Point(
        BigInt6(0x1, 0x0, 0x0, 0x0, 0x0, 0x0),
        BigInt6(d0=0x3c208c16d87cfd45,
            d1=0x97816a916871ca8d,
            d2=0xb85045b68181585d,
            d3=0x30644e72e131a029,
            d4=0x00,
            d5=0x00)))
end

func g1_negtwo() -> (res : G1Point):
    return (
        G1Point(
        BigInt6(d0=0xd3c208c16d87cfd3,
            d1=0xd97816a916871ca8,
            d2=0x9b85045b68181585,
            d3=0x030644e72e131a02,
            d4=0x00,
            d5=0x00,),
        BigInt6(d0=0x3ce1cc9c7e645a83,
            d1=0x2edac647851e3ac5,
            d2=0xd0cbe61fced2bc53,
            d3=0x1a76dae6d3272396,
            d4=0x00,
            d5=0x00,)))
end

func g1_negthree() -> (res : G1Point):
    return (
        G1Point(
        BigInt6(d0=0xf2d355961915abf0,
            d1=0x9315d84715b8e679,
            d2=0xf40232bcb1b6bd15,
            d3=0x0769bf9ac56bea3f,
            d4=0x00,
            d5=0x00),
        BigInt6(d0=0x6e2e8cd8fe7edae6,
            d1=0x65e306dd5cd56f35,
            d2=0x63006a39f478f3e8,
            d3=0x05acb4b400e90c00,
            d4=0x00,
            d5=0x00,)))
end

# @param compressed An array of length 3 defining the 3 limbs of the x - coordinate of a field element
# @return point_g1 a G1 point derived from the compressed x coordinate
# @dev Given x find y by performing y = sqrt(x^3 + 4)
func from_compressed(compressed : felt*) -> (fe : G1Point):
    alloc_locals
    let x = BigInt6(
        d0=compressed[0],
        d1=compressed[1],
        d2=compressed[2],
        d3=compressed[3],
        d4=compressed[4],
        d5=compressed[5])
    let (y) = solve_for_y(x)

    return (G1Point(x=x, y=y))
end

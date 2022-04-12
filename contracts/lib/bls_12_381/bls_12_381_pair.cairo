from contracts.lib.bigint.bigint6 import BigInt6, nondet_bigint6, bigint_mul, UnreducedBigInt10
from contracts.lib.bls_12_381.bls_12_381_def import P0, P1, P2, P3, P4, P5
from contracts.lib.bls_12_381.bls_12_381_field import (
    is_zero, FQ12, verify_zero10, fq12_is_zero, nondet_fq12, fq12_one, fq12_diff, fq12_pow_12,
    fq12_pow_3, fq12_zero)
from contracts.lib.bls_12_381.bls_12_381_g1 import G1Point, compute_doubling_slope, compute_slope
from contracts.lib.bls_12_381.bls_12_381_g2 import G2Point
from contracts.lib.bls_12_381.bls_12_381_gt import (
    GTPoint, gt_slope, gt_doubling_slope, twist, g1_to_gt, fq12_mul, gt_double, gt_add)

const ate_loop_count = 15132376222941642752
const log_ate_loop_count = 62

from starkware.cairo.common.registers import get_label_location

func get_loop_count_bits(index : felt) -> (bits : felt):
    let (data) = get_label_location(bits)
    let bit_array = cast(data, felt*)
    return (bit_array[index])

    bits:
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 1
    dw 0
    dw 1
    dw 1
end

func gt_linehelp{range_check_ptr}(pt0 : GTPoint, pt1 : GTPoint, t : GTPoint, slope : FQ12) -> (
        res : FQ12):
    %{
        import sys, os 
        cwd = os.getcwd()
        sys.path.append(cwd)

        from utils.bls_12_381_field import FQ, FQ12
        from utils.bls_12_381_utils import parse_fq12

        x1 = FQ12(list(map(FQ, parse_fq12(ids.pt1.x))))
        y1 = FQ12(list(map(FQ, parse_fq12(ids.pt1.y))))
        xt = FQ12(list(map(FQ, parse_fq12(ids.t.x))))
        yt = FQ12(list(map(FQ, parse_fq12(ids.t.y))))

        res = (slope * (xt - x1) - (yt - y1))
        value = list(map(lambda x: x.n, res.coeffs))
    %}
    let (res : FQ12) = nondet_fq12()
    # TODO VERIFY
    # let (x_diff_slope : UnreducedBigInt5) = bigint_mul(
    #     BigInt6(d0=t.x.d0 - pt1.x.d0, d1=t.x.d1 - pt1.x.d1, d2=t.x.d2 - pt1.x.d2), slope)

    # verify_zero5(
    #     UnreducedBigInt5(
    #     d0=x_diff_slope.d0 - t.y.d0 + pt0.x.d0 - res.d0,
    #     d1=x_diff_slope.d1 - t.y.d1 + pt0.x.d1 - res.d1,
    #     d2=x_diff_slope.d2 - t.y.d2 + pt0.x.d2 - res.d2,
    #     d3=x_diff_slope.d3,
    #     d4=x_diff_slope.d4))

    return (res)
end

func gt_linefunc{range_check_ptr}(pt0 : GTPoint, pt1 : GTPoint, t : GTPoint) -> (res : FQ12):
    let (x_diff : FQ12) = fq12_diff(pt0.x, pt1.x)
    let (same_x : felt) = fq12_is_zero(x_diff)
    if same_x == 0:
        let (slope : FQ12) = gt_slope(pt0, pt1)
        let (res : FQ12) = gt_linehelp(pt0, pt1, t, slope)
        return (res=res)
    else:
        let (y_diff : FQ12) = fq12_diff(pt0.y, pt1.y)
        let (same_y : felt) = fq12_is_zero(y_diff)
        if same_y == 1:
            let (slope : FQ12) = gt_doubling_slope(pt0)
            let (res : FQ12) = gt_linehelp(pt0, pt1, t, slope)
            return (res=res)
        else:
            let (res : FQ12) = fq12_diff(t.x, pt0.x)
            return (res=res)
        end
    end
end

func miller_loop{range_check_ptr}(Q : GTPoint, P : GTPoint, R : GTPoint, n : felt, f : FQ12) -> (
        res : FQ12):
    # END OF LOOP
    if n == 0:
        alloc_locals
        let modulus = BigInt6(P0, P1, P2, P3, P4, P5)
        let (_, local q1x) = fq12_pow_3(Q.x, modulus)
        let (_, local q1y) = fq12_pow_3(Q.y, modulus)
        let Q1 = GTPoint(q1x, q1y)

        let (local lfRQ1P : FQ12) = gt_linefunc(R, Q1, P)
        let (local newR : GTPoint) = gt_add(R, Q1)

        let (_, local nq2x) = fq12_pow_3(q1x, modulus)
        let (_, local q2y) = fq12_pow_3(q1y, modulus)
        let (zero) = fq12_zero()
        let (nq2y) = fq12_diff(zero, q2y)
        let nQ2 = GTPoint(nq2x, nq2y)

        let (local lfnQ2P : FQ12) = gt_linefunc(newR, nQ2, P)
        let (local f_1 : FQ12) = fq12_mul(f, lfRQ1P)
        let (f_2 : FQ12) = fq12_mul(f_1, lfnQ2P)
        # final exponentiation
        return final_exponentiation(f_2)
    end

    alloc_locals
    # inner loop
    let (bit) = get_loop_count_bits(n - 1)

    let (local lfRRP : FQ12) = gt_linefunc(R, R, P)
    let (local f_sqr : FQ12) = fq12_mul(f, f)

    let (local f_sqr_l : FQ12) = fq12_mul(f_sqr, lfRRP)
    let (twoR : GTPoint) = gt_double(R)
    if bit == 0:
        return miller_loop(Q=Q, P=P, R=twoR, n=n - 1, f=f_sqr_l)
    else:
        let (local lfRQP : FQ12) = gt_linefunc(twoR, Q, P)
        let (local new_f : FQ12) = fq12_mul(f_sqr_l, lfRQP)
        let (twoRpQ : GTPoint) = gt_add(twoR, Q)
        return miller_loop(Q=Q, P=P, R=twoRpQ, n=n - 1, f=new_f)
    end
end

func pairing{range_check_ptr}(Q : G2Point, P : G1Point) -> (res : FQ12):
    alloc_locals
    let (local twisted_Q : GTPoint) = twist(Q)

    %{
        import sys, os
        cwd = os.getcwd()
        sys.path.append(cwd)
        from utils.bls_12_381_utils import print_g12
        #print(print_g12("twisted Q ", ids.twisted_Q))
    %}

    let (local f : FQ12) = fq12_one()
    let (cast_P : GTPoint) = g1_to_gt(P)
    return miller_loop(Q=twisted_Q, P=cast_P, R=twisted_Q, n=log_ate_loop_count + 1, f=f)
end

func final_exponentiation{range_check_ptr}(x : FQ12) -> (res : FQ12):
    let final_exponent = FQ12(
        BigInt6(d0=13888179539520353552, d1=2736365793188772644, d2=4901882085076497545, d3=10245553439104930208, d4=4511887080475820137, d5=2480409176607337344),
        BigInt6(d0=7491311674952552729, d1=12627961533348287191, d2=1902740738850035229, d3=16552853404220568088, d4=17749692270577155004, d5=8355907080853396142),
        BigInt6(d0=12678135500496842026, d1=7098571539536849364, d2=3327947655793360153, d3=11873713615627332211, d4=7802877230125030369, d5=641915628298532677),
        BigInt6(d0=3881609722968250647, d1=11249322799995919414, d2=18058893281066492080, d3=4595194751216736125, d4=11871971152968339127, d5=1998895880436366502),
        BigInt6(d0=295166022682814325, d1=5314136997805809680, d2=5841891136602770199, d3=5297154307268841244, d4=7892597592728393666, d5=10520493313907660076),
        BigInt6(d0=5506754723648041365, d1=729492017680017069, d2=14221577116471104653, d3=3697251610284461008, d4=4276839558483564345, d5=8234049346028861093),
        BigInt6(d0=1331406716696671284, d1=7035876910678343977, d2=10231208758192608862, d3=10832054233467916867, d4=4678801762122007570, d5=11259182200316998186),
        BigInt6(d0=2671065110652931339, d1=6443457631868993567, d2=1181213584422670866, d3=540426529652661732, d4=14168138660929274355, d5=1876976240925558419),
        BigInt6(d0=3822893308372794038, d1=15161101599416757469, d2=15244853756049405526, d3=1815655748564036365, d4=12759810536953810568, d5=549682019421756068),
        BigInt6(d0=12188965709320368920, d1=16377245936516679279, d2=2020657000646437620, d3=14443869205620723471, d4=526432671088280412, d5=13883155048605675162),
        BigInt6(d0=3488476121674984873, d1=15062068461581975340, d2=1694625696763886147, d3=8314694538774779049, d4=15318848170138863568, d5=5290071543889396115),
        BigInt6(d0=15909007155382823360, d1=49159605, d2=0, d3=0, d4=0, d5=0))

    return fq12_pow_12(x, final_exponent)
end

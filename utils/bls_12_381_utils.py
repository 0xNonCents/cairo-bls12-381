from typing import List

from starkware.cairo.common.math_utils import as_int
from .bls_12_381_field import field_modulus
from .bls_12_381_curve import curve_order
PRIME = field_modulus
BASE_PRIME = curve_order


def split(num: int) -> List[int]:
    BASE = 2 ** 64
    a = []
    for _ in range(6):
        num, residue = divmod(num, BASE)
        a.append(residue)
    assert num == 0
    return a


def pack(z):

    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5

    return sum(as_int(limb, PRIME) * 2 ** (64 * i) for i, limb in enumerate(limbs)) % BASE_PRIME


def pack_from_arr(z):

    limbs = z

    return sum(as_int(limb, PRIME) * 2 ** (64 * i) for i, limb in enumerate(limbs)) % BASE_PRIME


def print_fq(name, e):
    print(name, pack(e))


def parse_fq2(e):
    e0, e1 = pack(e.e0), pack(e.e1)
    return [e0, e1]


def print_fq2(name, e):
    res = parse_fq2(e)
    print(name, res)


def parse_fq12(e):
    e0, e1, e2, e3 = pack(e.e0), pack(e.e1), pack(e.e2), pack(e.e3)
    e4, e5, e6, e7 = pack(e.e4), pack(e.e5), pack(e.e6), pack(e.e7)
    e8, e9, eA, eB = pack(e.e8), pack(e.e9), pack(e.eA), pack(e.eB)
    return [e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, eA, eB]


def print_fq12(name, e):
    res = parse_fq12(e)
    print(name, res)


def print_g1(name, e):
    print(name)
    print_fq("  x", e.x)
    print_fq("  y", e.y)


def print_g2(name, e):
    print(name)
    print_fq2("  x", e.x)
    print_fq2("  y", e.y)


def print_g12(name, e):
    print(name)
    print_fq12("  x", e.x)
    print_fq12("  y", e.y)


def cairo_final_exponent():
    num = (field_modulus ** 12 - 1) // curve_order
    BASE = 2 ** (64 * 6)
    a = []
    for _ in range(12):
        num, residue = divmod(num, BASE)
        a.append(residue)
    assert num == 0

    res = "FQ12(\n\t"
    for i in range(12):
        res += cairo_bigint6(a[i])
        res += ", "
        if i % 3 == 2:
            res += '\n\t'
    res += ')'

    print(res)

    return res


def cairo_bigint6_arr(arr):
    print("FQ12(")
    for i, x in enumerate(arr):
        print('e{i}=')
        cairo_bigint6(x)
        print(', ')


def cairo_bigint6(x):
    res = 'BigInt6('
    tmp = []
    for i, x in enumerate(split(x)):
        tmp.append(f'd{i}={x}')
    res += ",\n ".join(tmp) + ")"
    return res

def cairo_bigint6_g2(g2):
    x = g2[0]
    y = g2[1]
    print("G2Point(")
    print("x=FQ2(e0="+ cairo_bigint6(x.coeffs[0].n) + ',')
    print("e1=" + cairo_bigint6(x.coeffs[1].n))
    print("),")
    print("y=FQ2(e0=" +cairo_bigint6(y.coeffs[0].n))
    print(",e1=" +cairo_bigint6(y.coeffs[1].n))
    print("))")

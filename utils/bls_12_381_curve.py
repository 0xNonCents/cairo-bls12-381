# https://github.com/ethereum/py_ecc/blob/a1d18addb439d7659a9cbac861bf1518371f0afd/py_ecc/bls12_381/bls12_381_curve.py
from .bls_12_381_field import field_modulus, FQ, FQ2, FQ12

curve_order = 52435875175126190479447740508185965837690552500527637822603658699938581184513

# Curve order should be prime
assert pow(2, curve_order, curve_order) == 2
# Curve order should be a factor of field_modulus**12 - 1
assert (field_modulus ** 12 - 1) % curve_order == 0

# Curve is y**2 = x**3 + 4
b = FQ(4)
# Twisted curve over FQ**2
b2 = FQ2([4, 4])
# Extension curve over FQ**12; same b value as over FQ
b12 = FQ12([4] + [0] * 11)

# Generator for curve over FQ
G1 = (FQ(3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507),
      FQ(1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569))
# Generator for twisted curve over FQ2
G2 = (FQ2([352701069587466618187139116011060144890029952792775240219908644239793785735715026873347600343865175952761926303160, 3059144344244213709971259814753781636986470325476647558659373206291635324768958432433509563104347017837885763365758]),
      FQ2([1985150602287291935568054521177171638300868978215655730859378665066344726373823718423869104263333984641494340347905, 927553665492332455747201965776037880757740193453592970025027978793976877002675564980949289727957565575433344219582]))

# Check if a point is the point at infinity


def is_inf(pt):
    return pt is None

# Check that a point is on the curve defined by y**2 == x**3 + b


def is_on_curve(pt, b):
    if is_inf(pt):
        return True
    x, y = pt
    return y**2 - x**3 == b


assert is_on_curve(G1, b)
assert is_on_curve(G2, b2)

# Elliptic curve doubling


def double(pt):
    x, y = pt
    l = 3 * x**2 / (2 * y)
    newx = l**2 - 2 * x
    newy = -l * newx + l * x - y
    return newx, newy

# Elliptic curve addition


def add(p1, p2):
    if p1 is None or p2 is None:
        return p1 if p2 is None else p2
    x1, y1 = p1
    x2, y2 = p2
    if x2 == x1 and y2 == y1:
        return double(p1)
    elif x2 == x1:
        return None
    else:
        l = (y2 - y1) / (x2 - x1)
    newx = l**2 - x1 - x2
    newy = -l * newx + l * x1 - y1
    assert newy == (-l * newx + l * x2 - y2)
    return (newx, newy)

# Elliptic curve point multiplication


def multiply(pt, n):
    if n == 0:
        return None
    elif n == 1:
        return pt
    elif not n % 2:
        return multiply(double(pt), n // 2)
    else:
        return add(multiply(double(pt), int(n // 2)), pt)


def eq(p1, p2):
    return p1 == p2


# "Twist" a point in E(FQ2) into a point in E(FQ12)
w = FQ12([0, 1] + [0] * 10)

# Convert P => -P


def neg(pt):
    if pt is None:
        return None
    x, y = pt
    return (x, -y)


def twist(pt):
    if pt is None:
        return None
    _x, _y = pt
    # Field isomorphism from Z[p] / x**2 to Z[p] / x**2 - 18*x + 82
    xcoeffs = [_x.coeffs[0] - _x.coeffs[1], _x.coeffs[1]]
    ycoeffs = [_y.coeffs[0] - _y.coeffs[1], _y.coeffs[1]]

    # Isomorphism into subfield of Z[p] / w**12 - 18 * w**6 + 82,
    # where w**6 = x
    nx = FQ12([xcoeffs[0]] + [0] * 5 + [xcoeffs[1]] + [0] * 5)
    ny = FQ12([ycoeffs[0]] + [0] * 5 + [ycoeffs[1]] + [0] * 5)
    # Divide x coord by w**2 and y coord by w**3

    res = (nx / w ** 2, ny / w**3)
    return res


G12 = twist(G2)
# Check that the twist creates a point that is on the curve
assert is_on_curve(G12, b12)

#1295966280564920301633669126993182664460442447255135566892593574072190111457594458882525666368533822152770435497189 3059144344244213709971259814753781636986470325476647558659373206291635324768958432433509563104347017837885763365758
#2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279893
#352701069587466618187139116011060144890029952792775240219908644239793785735715026873347600343865175952761926303160  1353221637328373545892060349371360746048220186341936159219732281025920769516621702780080981380240920942561918531299
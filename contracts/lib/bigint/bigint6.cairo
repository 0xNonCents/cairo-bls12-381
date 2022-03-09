# The base of the representation.
const BASE = 2 ** 64

const BASE_SECOND = (2 ** (64 * 2))

const BASE_THIRD = (2 ** (64 * 3))

const BASE_FOURTH = (2 ** (64 * 4))

const BASE_FIFTH = (2 ** (64 * 5))

const BASE_SIXTH = (2 ** (64 * 6))

const BASE_SEVENTH = (2 ** (64 * 7))

# Represents an integer defined by
#   d0 + BASE * d1 + BASE**2 * d2 + BASE**3 * d3 + BASE**4 * d4 + BASE**5 * d5
# Note that the limbs (d_i) are NOT restricted to the range [0, BASE) and in particular they
# can be negative.
# In most cases this is used to represent a secp256k1 field element.
struct UnreducedBigInt6:
    member d0 : felt
    member d1 : felt
    member d2 : felt
    member d3 : felt
    member d4 : felt
    member d5 : felt
end

# Same as UnreducedBigInt6, except that d0, d1 and d2 must be in the range [0, 3 * BASE).
# In most cases this is used to represent a secp256k1 field element.
struct BigInt6:
    member d0 : felt
    member d1 : felt
    member d2 : felt
    member d3 : felt
    member d4 : felt
    member d5 : felt
end

# Represents a big integer: sum_i(BASE**i * d_i).
# Note that the limbs (d_i) are NOT restricted to the range [0, BASE) and in particular they
# can be negative.
struct UnreducedBigInt10:
    member d0 : felt
    member d1 : felt
    member d2 : felt
    member d3 : felt
    member d4 : felt
    member d5 : felt
    member d6 : felt
    member d7 : felt
    member d8 : felt
    member d9 : felt
end

func solve_for_y(n : BigInt6) -> (res : BigInt6):
    alloc_locals
    local y : BigInt6
    %{
        from starkware.python.math_utils import isqrt
        n = (ids.n.d5 * ids.BASE_FIFTH ) + (ids.n.d4 * ids.BASE_FOURTH ) + (ids.n.d3 * ids.BASE_THIRD ) + (ids.n.d2 * ids.BASE_SECOND ) + (ids.n.d1 * ids.BASE) + ids.n.d0

        temp = (n * n * n)
        root = isqrt((n * n * n) + 4)

        root, residue = divmod(root, ids.BASE)
        ids.y.d0 = residue

        root, residue = divmod(root, ids.BASE)
        ids.y.d1 = residue

        root, residue = divmod(root, ids.BASE)
        ids.y.d2 = residue

        root, residue = divmod(root, ids.BASE)
        ids.y.d3 = residue

        root, residue = divmod(root, ids.BASE)
        ids.y.d4 = residue

        root, residue = divmod(root, ids.BASE)
        ids.y.d5 = residue
    %}
    return (y)
end

func bigint_mul(x : BigInt6, y : BigInt6) -> (res : UnreducedBigInt10):
    return (
        UnreducedBigInt10(
        d0=x.d0 * y.d0,
        d1=x.d0 * y.d1 + x.d1 * y.d0,
        d2=x.d0 * y.d2 + x.d2 * y.d0 + x.d1 * y.d1,
        d3=x.d0 * y.d3 + x.d3 * y.d0 + x.d1 * y.d2 + x.d2 * y.d1,
        d4=x.d0 * y.d4 + x.d4 * y.d0 + x.d1 * y.d3 + x.d3 * y.d1 + x.d2 * y.d2,
        d5=x.d0 * y.d5 + x.d5 * y.d0 + x.d1 * y.d4 + x.d4 * y.d1 + x.d2 * y.d3 + x.d3 * y.d2,
        d6=x.d1 * y.d5 + x.d5 * y.d1 + x.d2 * y.d4 + x.d4 * y.d2 + x.d3 * y.d3,
        d7=x.d2 * y.d5 + x.d5 * y.d2 + x.d3 * y.d4 + x.d3 * y.d4,
        d8=x.d3 * y.d5 + x.d5 * y.d3 + x.d4 * y.d4,
        d9=x.d5 * y.d4 + x.d4 * y.d5,
        d10=x.d5 * y.d5,
        ))
end

# Returns a BigInt6 instance whose value is controlled by a prover hint.
#
# Soundness guarantee: each limb is in the range [0, 3 * BASE).
# Completeness guarantee (honest prover): the value is in reduced form and in particular,
# each limb is in the range [0, BASE).
#
# Hint arguments: value.
func nondet_bigint6{range_check_ptr}() -> (res : BigInt6):
    # The result should be at the end of the stack after the function returns.
    let res : BigInt6 = [cast(ap + 5, BigInt6*)]
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import split
        segments.write_arg(ids.res.address_, split(value))
    %}
    # The maximal possible sum of the limbs, assuming each of them is in the range [0, BASE).
    const MAX_SUM = 5 * (BASE - 1)
    assert [range_check_ptr] = MAX_SUM - (res.d0 + res.d1 + res.d2)

    # Prepare the result at the end of the stack.
    tempvar range_check_ptr = range_check_ptr + 7
    [range_check_ptr - 6] = res.d0; ap++
    [range_check_ptr - 5] = res.d1; ap++
    [range_check_ptr - 4] = res.d2; ap++
    [range_check_ptr - 3] = res.d3; ap++
    [range_check_ptr - 2] = res.d4; ap++
    [range_check_ptr - 1] = res.d5; ap++
    static_assert &res + BigInt6.SIZE == ap
    return (res=res)
end

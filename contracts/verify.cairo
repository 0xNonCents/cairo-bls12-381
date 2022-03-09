%builtins range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from contracts.lib.sha256.sha256 import sha256

const SIGNATURE_LENGTH = 22

const SIGNATURE_BYTES = 4 * SIGNATURE_LENGTH

const PREHASH_BYTES = 4 + SIGNATURE_BYTES

struct payload:
    member round : felt
    member sig : felt*
    member sig_len : felt
    member result : felt
end

func verify{range_check_ptr}(sig : felt*, sig_len : felt) -> (res : felt*):
    alloc_locals
    # TODO append the bytes of the signature to the previous round, then sha256 hash
    # TODO call sha256 contract when creating this contract
    let (local sha256_ptr_start : felt*) = alloc()
    let sha256_ptr = sha256_ptr_start

    # Hashed = array of 2 128 bit numbers
    let (hashed : felt*) = sha256{sha256_ptr=sha256_ptr}(sig, SIGNATURE_BYTES)

    # hashed to G1

    # compare pairings of e(g1, signature) and e(public_key, hashed)

    return (hashed)
end

func main{range_check_ptr}() -> ():
    alloc_locals
    let (local arr) = alloc()
    assert [arr + 0] = 119142591
    assert [arr + 1] = 3061203119
    assert [arr + 2] = 4173996443
    assert [arr + 3] = 4193436964
    assert [arr + 4] = 241215601
    assert [arr + 5] = 479628691
    assert [arr + 6] = 923613432
    assert [arr + 7] = 2067328291
    assert [arr + 8] = 1250714502
    assert [arr + 9] = 1052253987
    assert [arr + 10] = 1325196635
    assert [arr + 11] = 74741892
    assert [arr + 12] = 2349719589
    assert [arr + 13] = 1383808308
    assert [arr + 14] = 1994385504
    assert [arr + 15] = 1663835001
    assert [arr + 16] = 2505104976
    assert [arr + 17] = 2797163524
    assert [arr + 18] = 1676278630
    assert [arr + 19] = 3355536265
    assert [arr + 20] = 3226115922
    assert [arr + 21] = 3669870984
    assert [arr + 22] = 3868484545

    let (h) = verify(arr, 22)

    return ()
end

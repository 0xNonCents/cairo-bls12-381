# Declare this file as a StarkNet contract and set the required
# builtins.
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin

@contract_interface
namespace ISha256:
    func compute_sha256(input_len : felt, input : felt*, n_bytes : felt):
    end
end

@storage_var
func prev_sig() -> (res : felt):
end

@storage_var
func pub_key() -> (res : felt):
end

const SIGNATURE_LENGTH = 22

const SIGNATURE_BYTES = 4 * SIGNATURE_LENGTH

const PREHASH_BYTES = 4 + SIGNATURE_BYTES

struct payload:
    member round : felt
    member sig : felt
    member result : felt
end

func verify{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(pload : payload) -> (
        res : felt):
    # append the bytes of the signature to the previous round, then sha256 hash

    let msg_unhashed = pload.round + prev_sig.read()
end

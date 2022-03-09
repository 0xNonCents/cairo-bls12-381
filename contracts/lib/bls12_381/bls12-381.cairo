from starkware.cairo.common.alloc import alloc

# r1  = r mod p
func r1() -> (r1 : felt*):
    alloc_locals

    let (local r1) = alloc()
    assert [r1 + 0] = 0x760900000002fffd
    assert [r1 + 1] = 0xebf4000bc40c0002
    assert [r1 + 2] = 0x5f48985753c758ba
    assert [r1 + 3] = 0x77ce585370525745
    assert [r1 + 4] = 0x5c071a97a256ec6d
    assert [r1 + 5] = 0x15f65ec3fa80e493

    return (r1)
end

# BLS12-381 implemented in Cairo
A lot of code from [Tekkac's bn128 implementation](https://github.com/tekkac/cairo-alt_bn128)

## Some key differences
- Uses BLS12-381 curve parameters
- Substituting BigInt3 for BigInt6(6 limbs of 64 bits)

## To Run
```
git clone https://github.com/0xNonCents/cairo-bls12-381
cd cairo-bls12-381
make
```

BLS12-381 parameters from [py_ecc](https://github.com/ethereum/py_ecc/tree/a1d18addb439d7659a9cbac861bf1518371f0afd/py_ecc/bls12_381)

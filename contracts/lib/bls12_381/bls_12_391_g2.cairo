from contracts.lib.bigint.bigint6 import BigInt6
from contracts.lib.bls_12_381.alt_bn128_field import FQ2

func g2() -> (res : G2Point):
    return (
        res=G2Point(
        x=FQ2(
            e0=BigInt6(d0=0xe5ac7d055d042b7e,
                d1=0x334cf11213945d57,
                d2=0xb5da61bbdc7f5049,
                d3=0x596bd0d09920b61a,
                d4=0x01,
                d5=0x00),
            e1=BigInt6(d0=0xd48056c8c121bdb8,
                d1=0x0bac0326a805bbef,
                d2=0xb4510b647ae3d177,
                d3=0xc6e47ad4fa403b02,
                d4=0x01,
                d5=0x00),
            ),
        y=FQ2(
            e0=BigInt6(d0=0xaaa9075ff05f79be,
                d1=0x3f370d275cec1da1,
                d2=0x267492ab572e99ab,
                d3=0xcb3e287e85a763af,
                d4=0x01,
                d5=0x00),
            e1=BigInt6(d0=0xe193548608b82801,
                d1=0x923ac9cc3baca289,
                d2=0x6d429a695160d12c,
                d3=0xadfd9baa8cbdd3a7,
                d4=0x02,
                d5=0x00),
            )
        ))
end

#include "SM2mul_asm_lib.h"
#include <ctime>
#include <cstdio>
#include <string>

/// <summary>
/// 输入a的蒙哥马利域表示，得到a的模逆的蒙哥马利域表示。即，f(a*2^256 (mod p)) = (a^(-1))*2^256 (mod p)
/// </summary>
/// <param name="a"></param>
/// <param name="result"></param>
void asm_almost_mod_inv_pro(uint64_t* a, uint64_t* result) {

    uint64_t p[4] = { 0xfffffffeffffffff, 0xffffffffffffffff, 0xffffffff00000000, 0xffffffffffffffff };

    uint64_t k((uint64_t)_uint256_inv_pre_pro(a, p, result));

    //这里得到了r = (a^(-1)) * (2 ^ k) ( mod p )，k >= 256


    _sm2_mul_ori(result, p_pre_2exp_inv + 4 * (k - 256), result);

    return;
}

//|| 一  [(0)(4)] || 三 [(8)(12)] ||  五 [(16)(20)]||  七 [(24)(28)] ||  九 [(32)(36)] ||  十一 [(40)(44)] ||  十三 [(48)(52)] || 十五 [(56)(60)]  |
//||十七[(64)(68)]||十九[(72)(76)]||二十一[(80)(84)]||二十三[(88)(92)]||二十五[(96)(100)]||二十七[(104)(108)]||二十九[(112)(116)]||三十一[(120)(124)]|
/// <summary>
/// 对仿射点p的预处理，得到p的1倍到31奇数倍点的蒙哥马利域仿射坐标。
/// </summary>
/// <param name="p"></param>
/// <param name="p_pre"></param>
void p_to_p32_pre(uint64_t p[], uint64_t p_pre[]) {
    uint64_t p1[8], p2[12], lambda[48];

    _sm2_mul_to_mm(p, p1);
    _sm2_mul_to_mm(p + 4, p1 + 4);
    std::memcpy(p_pre, p1, 64);

    std::memcpy(p_pre + 120, p_pre, 32);
    _uint256_p_sub(p_pre + 4, p_pre + 124);

    jacobian_point_double_z1_equ_1(p1, p2);


    jacobian_point_add_z1_equ_z2_lambda(p2, p1, p_pre + 8, lambda);

    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 8, p_pre + 16, lambda);
    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 16, p_pre + 24, lambda + 8);
    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 24, p_pre + 32, lambda + 16);
    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 32, p_pre + 40, lambda + 24);
    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 40, p_pre + 48, lambda + 32);
    jacobian_point_add_z1_equ_z2_lambda(p2, p_pre + 48, p_pre + 56, lambda + 40);

    asm_almost_mod_inv_pro(p2 + 8, p2 + 8);

    p_j2a_pre(p2, p_pre, lambda);

    return;
}

/// <summary>
/// 点的乘法函数。result = k*a
/// </summary>
/// <param name="k"></param>
/// <param name="a"></param>
/// <param name="result"></param>
void scalar_multiplication_nome_wmbNAF(uint64_t k[], uint64_t a[], uint64_t result[]) {
    uint8_t k_pre[257];
    int i(asm_k_to_k_wmbNAF_pre(k, k_pre)), j, j_max, j_0;

    uint64_t A_pre[128];

    p_to_p32_pre(a, A_pre);


    //show_uint256(A_pre, 32);
    //putchar(10);

    uint64_t temp[12] = {
        0x0000000000000000u, 0x0000000000000000u, 0x0000000000000000u, 0x0000000000000000u,
        0x0000000000000000u, 0x0000000000000000u, 0x0000000000000000u, 0x0000000000000000u,
        0x0000000100000000u, 0x0000000000000000u, 0x00000000ffffffffu, 0x0000000000000001u
    };

    memcpy(temp, A_pre + ((k_pre[i] >> 1) << 3), 64);

    //show_uint256(temp, 2);

    i--;

    for (; i >= 0; i--) {
        j_max = k_pre[i] >> 1;
        j_0 = (k_pre[i] & 1);
        if (j_0 != 0) {
            _sm2_point_double_stack4(temp);
            jacobian_point_double_add(temp, A_pre + (j_max << 3), temp);
        }
        else if (j_max == 0) {
            jacobian_point_tripling(temp, temp);
        }
        else {
            j_0 = (j_max & 3);
            j_max = j_max >> 2;

            for (j = 0; j != j_max; j++) {
                _sm2_point_double_stack4(temp);
            }

            switch (j_0)
            {
            case 0:
                break;
            case 1:
                _sm2_point_double_stack1(temp);
                break;
            case 2:
                _sm2_point_double_stack2(temp);
                break;
            case 3:
                _sm2_point_double_stack3(temp);
                break;
            default:
                break;
            }
        }
    }

    asm_almost_mod_inv_pro(temp + 8, temp + 8);
    _sm2_sqr(temp + 8, result + 4);
    _sm2_mul_ori(temp, result + 4, result);
    _sm2_mul_ori(temp + 4, result + 4, result + 4);
    _sm2_mul_ori(temp + 8, result + 4, result + 4);

    _sm2_mul_mm_to(result, result);
    _sm2_mul_mm_to(result + 4, result + 4);

    return;
}

/// <summary>
/// 平平无奇的测试函数，测试了SM2标准文件中给出的一组结果，正确的result是
/// fdac1efaa770e463 5885ca1bbfb360a5 84b238fb2902ecf0 9ddc935f60bf4f9b
/// b89aa9263d5632f6 ee82222e4d63198e 78e095c24042cbe7 15c23f711422d74c
/// </summary>
/// <param name="i_0">测试时的运算次数</param>
void test_scalar_multiplication_nome(const int& i_0) {
    int i, s, t;

    uint64_t a0[8] = {
        0x09F9DF311E5421A1u, 0x50DD7D161E4BC5C6u, 0x72179FAD1833FC07u, 0x6BB08FF356F35020u,
        0xCCEA490CE26775A5u, 0x2DC6EA718CC1AA60u, 0x0AED05FBF35E084Au, 0x6632F6072DA9AD13u
    };

    uint64_t k[4] = {
        0xA756E53127F3F43Bu, 0x851C47CFEEFD9E43u, 0xA2D133CA258EF4EAu, 0x73FBF4683ACDA13Au
    };

    uint64_t result[8];

    s = clock();
    for (i = 0; i != i_0; i++) {
        //k[3] += rand();
        //scalar_multiplication_nome_32(k, a0, result);
        scalar_multiplication_nome_wmbNAF(k, a0, result);

    }
    t = clock();
    t -= s;
    printf("%d\n", t);

    for (uint64_t i = 0; i != 2; i++) {
        printf("%016llx %016llx %016llx %016llx\n", result[i << 2], result[(i << 2) + 1], result[(i << 2) + 2], result[(i << 2) + 3]);
    }

    return;
}

int main() {

    int i(10000);

    test_scalar_multiplication_nome(i);

    return 0;
}

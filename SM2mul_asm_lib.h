#pragma once
#include <cstdint>

extern "C"
{
	inline int __fastcall asm_k_to_k_wmbNAF_pre(void* k, void* k_pre);

	inline void __fastcall _sm2_mul_to_mm(void* a, void* result);
	inline void __fastcall _sm2_mul_mm_to(void* a, void* result);
	inline void __fastcall _uint256_p_sub(void* a, void* result);
	inline void __fastcall jacobian_point_double_z1_equ_1(uint64_t a[], uint64_t result[]);
	inline void __fastcall jacobian_point_add_z1_equ_z2_lambda(uint64_t a[], uint64_t b[], uint64_t result[], uint64_t lambda[]);
	inline uint64_t __fastcall _uint256_inv_pre_pro(void* a, void* p, void* result);
	inline void __fastcall _sm2_mul_ori(void* a, void* b, void* result);
	inline void __fastcall p_j2a_pre(uint64_t p2[], uint64_t p_pre[], uint64_t lambda[]);

	inline void __fastcall _sm2_point_double_stack1(void* a);
	inline void __fastcall _sm2_point_double_stack2(void* a);
	inline void __fastcall _sm2_point_double_stack3(void* a);
	inline void __fastcall _sm2_point_double_stack4(void* a);

	inline void __fastcall jacobian_point_tripling(uint64_t* uint256a, uint64_t* result);
	inline void __fastcall jacobian_point_double_add(uint64_t* uint256a, uint64_t* uint256b, uint64_t* result);

	inline void __fastcall _sm2_sqr(void* a, void* result);
}

//SM2参数：素数p的预计算结果
uint64_t p_pre_2exp_inv[1028] = {
0x0000000400000002u, 0x0000000100000001u, 0x00000002FFFFFFFFu, 0x0000000200000003u,
0x8000000180000001u, 0x0000000080000000u, 0x8000000100000000u, 0x0000000100000001u,
0xC000000040000000u, 0x8000000040000000u, 0x4000000000000000u, 0x8000000080000000u,
0x6000000020000000u, 0x4000000020000000u, 0x2000000000000000u, 0x4000000040000000u,
0x3000000010000000u, 0x2000000010000000u, 0x1000000000000000u, 0x2000000020000000u,
0x1800000008000000u, 0x1000000008000000u, 0x0800000000000000u, 0x1000000010000000u,
0x0C00000004000000u, 0x0800000004000000u, 0x0400000000000000u, 0x0800000008000000u,
0x0600000002000000u, 0x0400000002000000u, 0x0200000000000000u, 0x0400000004000000u,
0x0300000001000000u, 0x0200000001000000u, 0x0100000000000000u, 0x0200000002000000u,
0x0180000000800000u, 0x0100000000800000u, 0x0080000000000000u, 0x0100000001000000u,
0x00C0000000400000u, 0x0080000000400000u, 0x0040000000000000u, 0x0080000000800000u,
0x0060000000200000u, 0x0040000000200000u, 0x0020000000000000u, 0x0040000000400000u,
0x0030000000100000u, 0x0020000000100000u, 0x0010000000000000u, 0x0020000000200000u,
0x0018000000080000u, 0x0010000000080000u, 0x0008000000000000u, 0x0010000000100000u,
0x000C000000040000u, 0x0008000000040000u, 0x0004000000000000u, 0x0008000000080000u,
0x0006000000020000u, 0x0004000000020000u, 0x0002000000000000u, 0x0004000000040000u,
0x0003000000010000u, 0x0002000000010000u, 0x0001000000000000u, 0x0002000000020000u,
0x0001800000008000u, 0x0001000000008000u, 0x0000800000000000u, 0x0001000000010000u,
0x0000C00000004000u, 0x0000800000004000u, 0x0000400000000000u, 0x0000800000008000u,
0x0000600000002000u, 0x0000400000002000u, 0x0000200000000000u, 0x0000400000004000u,
0x0000300000001000u, 0x0000200000001000u, 0x0000100000000000u, 0x0000200000002000u,
0x0000180000000800u, 0x0000100000000800u, 0x0000080000000000u, 0x0000100000001000u,
0x00000C0000000400u, 0x0000080000000400u, 0x0000040000000000u, 0x0000080000000800u,
0x0000060000000200u, 0x0000040000000200u, 0x0000020000000000u, 0x0000040000000400u,
0x0000030000000100u, 0x0000020000000100u, 0x0000010000000000u, 0x0000020000000200u,
0x0000018000000080u, 0x0000010000000080u, 0x0000008000000000u, 0x0000010000000100u,
0x000000C000000040u, 0x0000008000000040u, 0x0000004000000000u, 0x0000008000000080u,
0x0000006000000020u, 0x0000004000000020u, 0x0000002000000000u, 0x0000004000000040u,
0x0000003000000010u, 0x0000002000000010u, 0x0000001000000000u, 0x0000002000000020u,
0x0000001800000008u, 0x0000001000000008u, 0x0000000800000000u, 0x0000001000000010u,
0x0000000C00000004u, 0x0000000800000004u, 0x0000000400000000u, 0x0000000800000008u,
0x0000000600000002u, 0x0000000400000002u, 0x0000000200000000u, 0x0000000400000004u,
0x0000000300000001u, 0x0000000200000001u, 0x0000000100000000u, 0x0000000200000002u,
0x0000000180000000u, 0x8000000100000000u, 0x8000000080000000u, 0x0000000100000001u,
0x8000000040000000u, 0x4000000080000000u, 0x3FFFFFFFC0000000u, 0x8000000080000000u,
0x4000000020000000u, 0x2000000040000000u, 0x1FFFFFFFE0000000u, 0x4000000040000000u,
0x2000000010000000u, 0x1000000020000000u, 0x0FFFFFFFF0000000u, 0x2000000020000000u,
0x1000000008000000u, 0x0800000010000000u, 0x07FFFFFFF8000000u, 0x1000000010000000u,
0x0800000004000000u, 0x0400000008000000u, 0x03FFFFFFFC000000u, 0x0800000008000000u,
0x0400000002000000u, 0x0200000004000000u, 0x01FFFFFFFE000000u, 0x0400000004000000u,
0x0200000001000000u, 0x0100000002000000u, 0x00FFFFFFFF000000u, 0x0200000002000000u,
0x0100000000800000u, 0x0080000001000000u, 0x007FFFFFFF800000u, 0x0100000001000000u,
0x0080000000400000u, 0x0040000000800000u, 0x003FFFFFFFC00000u, 0x0080000000800000u,
0x0040000000200000u, 0x0020000000400000u, 0x001FFFFFFFE00000u, 0x0040000000400000u,
0x0020000000100000u, 0x0010000000200000u, 0x000FFFFFFFF00000u, 0x0020000000200000u,
0x0010000000080000u, 0x0008000000100000u, 0x0007FFFFFFF80000u, 0x0010000000100000u,
0x0008000000040000u, 0x0004000000080000u, 0x0003FFFFFFFC0000u, 0x0008000000080000u,
0x0004000000020000u, 0x0002000000040000u, 0x0001FFFFFFFE0000u, 0x0004000000040000u,
0x0002000000010000u, 0x0001000000020000u, 0x0000FFFFFFFF0000u, 0x0002000000020000u,
0x0001000000008000u, 0x0000800000010000u, 0x00007FFFFFFF8000u, 0x0001000000010000u,
0x0000800000004000u, 0x0000400000008000u, 0x00003FFFFFFFC000u, 0x0000800000008000u,
0x0000400000002000u, 0x0000200000004000u, 0x00001FFFFFFFE000u, 0x0000400000004000u,
0x0000200000001000u, 0x0000100000002000u, 0x00000FFFFFFFF000u, 0x0000200000002000u,
0x0000100000000800u, 0x0000080000001000u, 0x000007FFFFFFF800u, 0x0000100000001000u,
0x0000080000000400u, 0x0000040000000800u, 0x000003FFFFFFFC00u, 0x0000080000000800u,
0x0000040000000200u, 0x0000020000000400u, 0x000001FFFFFFFE00u, 0x0000040000000400u,
0x0000020000000100u, 0x0000010000000200u, 0x000000FFFFFFFF00u, 0x0000020000000200u,
0x0000010000000080u, 0x0000008000000100u, 0x0000007FFFFFFF80u, 0x0000010000000100u,
0x0000008000000040u, 0x0000004000000080u, 0x0000003FFFFFFFC0u, 0x0000008000000080u,
0x0000004000000020u, 0x0000002000000040u, 0x0000001FFFFFFFE0u, 0x0000004000000040u,
0x0000002000000010u, 0x0000001000000020u, 0x0000000FFFFFFFF0u, 0x0000002000000020u,
0x0000001000000008u, 0x0000000800000010u, 0x00000007FFFFFFF8u, 0x0000001000000010u,
0x0000000800000004u, 0x0000000400000008u, 0x00000003FFFFFFFCu, 0x0000000800000008u,
0x0000000400000002u, 0x0000000200000004u, 0x00000001FFFFFFFEu, 0x0000000400000004u,
0x0000000200000001u, 0x0000000100000002u, 0x00000000FFFFFFFFu, 0x0000000200000002u,
0x0000000100000000u, 0x8000000080000001u, 0x000000007FFFFFFFu, 0x8000000100000001u,
0x8000000000000000u, 0x4000000040000000u, 0x7FFFFFFFC0000000u, 0x4000000080000000u,
0x4000000000000000u, 0x2000000020000000u, 0x3FFFFFFFE0000000u, 0x2000000040000000u,
0x2000000000000000u, 0x1000000010000000u, 0x1FFFFFFFF0000000u, 0x1000000020000000u,
0x1000000000000000u, 0x0800000008000000u, 0x0FFFFFFFF8000000u, 0x0800000010000000u,
0x0800000000000000u, 0x0400000004000000u, 0x07FFFFFFFC000000u, 0x0400000008000000u,
0x0400000000000000u, 0x0200000002000000u, 0x03FFFFFFFE000000u, 0x0200000004000000u,
0x0200000000000000u, 0x0100000001000000u, 0x01FFFFFFFF000000u, 0x0100000002000000u,
0x0100000000000000u, 0x0080000000800000u, 0x00FFFFFFFF800000u, 0x0080000001000000u,
0x0080000000000000u, 0x0040000000400000u, 0x007FFFFFFFC00000u, 0x0040000000800000u,
0x0040000000000000u, 0x0020000000200000u, 0x003FFFFFFFE00000u, 0x0020000000400000u,
0x0020000000000000u, 0x0010000000100000u, 0x001FFFFFFFF00000u, 0x0010000000200000u,
0x0010000000000000u, 0x0008000000080000u, 0x000FFFFFFFF80000u, 0x0008000000100000u,
0x0008000000000000u, 0x0004000000040000u, 0x0007FFFFFFFC0000u, 0x0004000000080000u,
0x0004000000000000u, 0x0002000000020000u, 0x0003FFFFFFFE0000u, 0x0002000000040000u,
0x0002000000000000u, 0x0001000000010000u, 0x0001FFFFFFFF0000u, 0x0001000000020000u,
0x0001000000000000u, 0x0000800000008000u, 0x0000FFFFFFFF8000u, 0x0000800000010000u,
0x0000800000000000u, 0x0000400000004000u, 0x00007FFFFFFFC000u, 0x0000400000008000u,
0x0000400000000000u, 0x0000200000002000u, 0x00003FFFFFFFE000u, 0x0000200000004000u,
0x0000200000000000u, 0x0000100000001000u, 0x00001FFFFFFFF000u, 0x0000100000002000u,
0x0000100000000000u, 0x0000080000000800u, 0x00000FFFFFFFF800u, 0x0000080000001000u,
0x0000080000000000u, 0x0000040000000400u, 0x000007FFFFFFFC00u, 0x0000040000000800u,
0x0000040000000000u, 0x0000020000000200u, 0x000003FFFFFFFE00u, 0x0000020000000400u,
0x0000020000000000u, 0x0000010000000100u, 0x000001FFFFFFFF00u, 0x0000010000000200u,
0x0000010000000000u, 0x0000008000000080u, 0x000000FFFFFFFF80u, 0x0000008000000100u,
0x0000008000000000u, 0x0000004000000040u, 0x0000007FFFFFFFC0u, 0x0000004000000080u,
0x0000004000000000u, 0x0000002000000020u, 0x0000003FFFFFFFE0u, 0x0000002000000040u,
0x0000002000000000u, 0x0000001000000010u, 0x0000001FFFFFFFF0u, 0x0000001000000020u,
0x0000001000000000u, 0x0000000800000008u, 0x0000000FFFFFFFF8u, 0x0000000800000010u,
0x0000000800000000u, 0x0000000400000004u, 0x00000007FFFFFFFCu, 0x0000000400000008u,
0x0000000400000000u, 0x0000000200000002u, 0x00000003FFFFFFFEu, 0x0000000200000004u,
0x0000000200000000u, 0x0000000100000001u, 0x00000001FFFFFFFFu, 0x0000000100000002u,
0x0000000100000000u, 0x0000000080000000u, 0x80000000FFFFFFFFu, 0x8000000080000001u,
0x8000000000000000u, 0x0000000040000000u, 0x4000000000000000u, 0x4000000040000000u,
0x4000000000000000u, 0x0000000020000000u, 0x2000000000000000u, 0x2000000020000000u,
0x2000000000000000u, 0x0000000010000000u, 0x1000000000000000u, 0x1000000010000000u,
0x1000000000000000u, 0x0000000008000000u, 0x0800000000000000u, 0x0800000008000000u,
0x0800000000000000u, 0x0000000004000000u, 0x0400000000000000u, 0x0400000004000000u,
0x0400000000000000u, 0x0000000002000000u, 0x0200000000000000u, 0x0200000002000000u,
0x0200000000000000u, 0x0000000001000000u, 0x0100000000000000u, 0x0100000001000000u,
0x0100000000000000u, 0x0000000000800000u, 0x0080000000000000u, 0x0080000000800000u,
0x0080000000000000u, 0x0000000000400000u, 0x0040000000000000u, 0x0040000000400000u,
0x0040000000000000u, 0x0000000000200000u, 0x0020000000000000u, 0x0020000000200000u,
0x0020000000000000u, 0x0000000000100000u, 0x0010000000000000u, 0x0010000000100000u,
0x0010000000000000u, 0x0000000000080000u, 0x0008000000000000u, 0x0008000000080000u,
0x0008000000000000u, 0x0000000000040000u, 0x0004000000000000u, 0x0004000000040000u,
0x0004000000000000u, 0x0000000000020000u, 0x0002000000000000u, 0x0002000000020000u,
0x0002000000000000u, 0x0000000000010000u, 0x0001000000000000u, 0x0001000000010000u,
0x0001000000000000u, 0x0000000000008000u, 0x0000800000000000u, 0x0000800000008000u,
0x0000800000000000u, 0x0000000000004000u, 0x0000400000000000u, 0x0000400000004000u,
0x0000400000000000u, 0x0000000000002000u, 0x0000200000000000u, 0x0000200000002000u,
0x0000200000000000u, 0x0000000000001000u, 0x0000100000000000u, 0x0000100000001000u,
0x0000100000000000u, 0x0000000000000800u, 0x0000080000000000u, 0x0000080000000800u,
0x0000080000000000u, 0x0000000000000400u, 0x0000040000000000u, 0x0000040000000400u,
0x0000040000000000u, 0x0000000000000200u, 0x0000020000000000u, 0x0000020000000200u,
0x0000020000000000u, 0x0000000000000100u, 0x0000010000000000u, 0x0000010000000100u,
0x0000010000000000u, 0x0000000000000080u, 0x0000008000000000u, 0x0000008000000080u,
0x0000008000000000u, 0x0000000000000040u, 0x0000004000000000u, 0x0000004000000040u,
0x0000004000000000u, 0x0000000000000020u, 0x0000002000000000u, 0x0000002000000020u,
0x0000002000000000u, 0x0000000000000010u, 0x0000001000000000u, 0x0000001000000010u,
0x0000001000000000u, 0x0000000000000008u, 0x0000000800000000u, 0x0000000800000008u,
0x0000000800000000u, 0x0000000000000004u, 0x0000000400000000u, 0x0000000400000004u,
0x0000000400000000u, 0x0000000000000002u, 0x0000000200000000u, 0x0000000200000002u,
0x0000000200000000u, 0x0000000000000001u, 0x0000000100000000u, 0x0000000100000001u,
0x8000000080000000u, 0x0000000000000000u, 0x8000000000000000u, 0x8000000080000000u,
0x4000000040000000u, 0x0000000000000000u, 0x4000000000000000u, 0x4000000040000000u,
0x2000000020000000u, 0x0000000000000000u, 0x2000000000000000u, 0x2000000020000000u,
0x1000000010000000u, 0x0000000000000000u, 0x1000000000000000u, 0x1000000010000000u,
0x0800000008000000u, 0x0000000000000000u, 0x0800000000000000u, 0x0800000008000000u,
0x0400000004000000u, 0x0000000000000000u, 0x0400000000000000u, 0x0400000004000000u,
0x0200000002000000u, 0x0000000000000000u, 0x0200000000000000u, 0x0200000002000000u,
0x0100000001000000u, 0x0000000000000000u, 0x0100000000000000u, 0x0100000001000000u,
0x0080000000800000u, 0x0000000000000000u, 0x0080000000000000u, 0x0080000000800000u,
0x0040000000400000u, 0x0000000000000000u, 0x0040000000000000u, 0x0040000000400000u,
0x0020000000200000u, 0x0000000000000000u, 0x0020000000000000u, 0x0020000000200000u,
0x0010000000100000u, 0x0000000000000000u, 0x0010000000000000u, 0x0010000000100000u,
0x0008000000080000u, 0x0000000000000000u, 0x0008000000000000u, 0x0008000000080000u,
0x0004000000040000u, 0x0000000000000000u, 0x0004000000000000u, 0x0004000000040000u,
0x0002000000020000u, 0x0000000000000000u, 0x0002000000000000u, 0x0002000000020000u,
0x0001000000010000u, 0x0000000000000000u, 0x0001000000000000u, 0x0001000000010000u,
0x0000800000008000u, 0x0000000000000000u, 0x0000800000000000u, 0x0000800000008000u,
0x0000400000004000u, 0x0000000000000000u, 0x0000400000000000u, 0x0000400000004000u,
0x0000200000002000u, 0x0000000000000000u, 0x0000200000000000u, 0x0000200000002000u,
0x0000100000001000u, 0x0000000000000000u, 0x0000100000000000u, 0x0000100000001000u,
0x0000080000000800u, 0x0000000000000000u, 0x0000080000000000u, 0x0000080000000800u,
0x0000040000000400u, 0x0000000000000000u, 0x0000040000000000u, 0x0000040000000400u,
0x0000020000000200u, 0x0000000000000000u, 0x0000020000000000u, 0x0000020000000200u,
0x0000010000000100u, 0x0000000000000000u, 0x0000010000000000u, 0x0000010000000100u,
0x0000008000000080u, 0x0000000000000000u, 0x0000008000000000u, 0x0000008000000080u,
0x0000004000000040u, 0x0000000000000000u, 0x0000004000000000u, 0x0000004000000040u,
0x0000002000000020u, 0x0000000000000000u, 0x0000002000000000u, 0x0000002000000020u,
0x0000001000000010u, 0x0000000000000000u, 0x0000001000000000u, 0x0000001000000010u,
0x0000000800000008u, 0x0000000000000000u, 0x0000000800000000u, 0x0000000800000008u,
0x0000000400000004u, 0x0000000000000000u, 0x0000000400000000u, 0x0000000400000004u,
0x0000000200000002u, 0x0000000000000000u, 0x0000000200000000u, 0x0000000200000002u,
0x0000000100000001u, 0x0000000000000000u, 0x0000000100000000u, 0x0000000100000001u,
0x8000000000000000u, 0x8000000000000000u, 0x0000000000000000u, 0x8000000080000000u,
0x4000000000000000u, 0x4000000000000000u, 0x0000000000000000u, 0x4000000040000000u,
0x2000000000000000u, 0x2000000000000000u, 0x0000000000000000u, 0x2000000020000000u,
0x1000000000000000u, 0x1000000000000000u, 0x0000000000000000u, 0x1000000010000000u,
0x0800000000000000u, 0x0800000000000000u, 0x0000000000000000u, 0x0800000008000000u,
0x0400000000000000u, 0x0400000000000000u, 0x0000000000000000u, 0x0400000004000000u,
0x0200000000000000u, 0x0200000000000000u, 0x0000000000000000u, 0x0200000002000000u,
0x0100000000000000u, 0x0100000000000000u, 0x0000000000000000u, 0x0100000001000000u,
0x0080000000000000u, 0x0080000000000000u, 0x0000000000000000u, 0x0080000000800000u,
0x0040000000000000u, 0x0040000000000000u, 0x0000000000000000u, 0x0040000000400000u,
0x0020000000000000u, 0x0020000000000000u, 0x0000000000000000u, 0x0020000000200000u,
0x0010000000000000u, 0x0010000000000000u, 0x0000000000000000u, 0x0010000000100000u,
0x0008000000000000u, 0x0008000000000000u, 0x0000000000000000u, 0x0008000000080000u,
0x0004000000000000u, 0x0004000000000000u, 0x0000000000000000u, 0x0004000000040000u,
0x0002000000000000u, 0x0002000000000000u, 0x0000000000000000u, 0x0002000000020000u,
0x0001000000000000u, 0x0001000000000000u, 0x0000000000000000u, 0x0001000000010000u,
0x0000800000000000u, 0x0000800000000000u, 0x0000000000000000u, 0x0000800000008000u,
0x0000400000000000u, 0x0000400000000000u, 0x0000000000000000u, 0x0000400000004000u,
0x0000200000000000u, 0x0000200000000000u, 0x0000000000000000u, 0x0000200000002000u,
0x0000100000000000u, 0x0000100000000000u, 0x0000000000000000u, 0x0000100000001000u,
0x0000080000000000u, 0x0000080000000000u, 0x0000000000000000u, 0x0000080000000800u,
0x0000040000000000u, 0x0000040000000000u, 0x0000000000000000u, 0x0000040000000400u,
0x0000020000000000u, 0x0000020000000000u, 0x0000000000000000u, 0x0000020000000200u,
0x0000010000000000u, 0x0000010000000000u, 0x0000000000000000u, 0x0000010000000100u,
0x0000008000000000u, 0x0000008000000000u, 0x0000000000000000u, 0x0000008000000080u,
0x0000004000000000u, 0x0000004000000000u, 0x0000000000000000u, 0x0000004000000040u,
0x0000002000000000u, 0x0000002000000000u, 0x0000000000000000u, 0x0000002000000020u,
0x0000001000000000u, 0x0000001000000000u, 0x0000000000000000u, 0x0000001000000010u,
0x0000000800000000u, 0x0000000800000000u, 0x0000000000000000u, 0x0000000800000008u,
0x0000000400000000u, 0x0000000400000000u, 0x0000000000000000u, 0x0000000400000004u,
0x0000000200000000u, 0x0000000200000000u, 0x0000000000000000u, 0x0000000200000002u,
0x0000000100000000u, 0x0000000100000000u, 0x0000000000000000u, 0x0000000100000001u,
0x8000000000000000u, 0x000000007FFFFFFFu, 0xFFFFFFFF80000000u, 0x8000000080000000u,
0x4000000000000000u, 0x000000003FFFFFFFu, 0xFFFFFFFFC0000000u, 0x4000000040000000u,
0x2000000000000000u, 0x000000001FFFFFFFu, 0xFFFFFFFFE0000000u, 0x2000000020000000u,
0x1000000000000000u, 0x000000000FFFFFFFu, 0xFFFFFFFFF0000000u, 0x1000000010000000u,
0x0800000000000000u, 0x0000000007FFFFFFu, 0xFFFFFFFFF8000000u, 0x0800000008000000u,
0x0400000000000000u, 0x0000000003FFFFFFu, 0xFFFFFFFFFC000000u, 0x0400000004000000u,
0x0200000000000000u, 0x0000000001FFFFFFu, 0xFFFFFFFFFE000000u, 0x0200000002000000u,
0x0100000000000000u, 0x0000000000FFFFFFu, 0xFFFFFFFFFF000000u, 0x0100000001000000u,
0x0080000000000000u, 0x00000000007FFFFFu, 0xFFFFFFFFFF800000u, 0x0080000000800000u,
0x0040000000000000u, 0x00000000003FFFFFu, 0xFFFFFFFFFFC00000u, 0x0040000000400000u,
0x0020000000000000u, 0x00000000001FFFFFu, 0xFFFFFFFFFFE00000u, 0x0020000000200000u,
0x0010000000000000u, 0x00000000000FFFFFu, 0xFFFFFFFFFFF00000u, 0x0010000000100000u,
0x0008000000000000u, 0x000000000007FFFFu, 0xFFFFFFFFFFF80000u, 0x0008000000080000u,
0x0004000000000000u, 0x000000000003FFFFu, 0xFFFFFFFFFFFC0000u, 0x0004000000040000u,
0x0002000000000000u, 0x000000000001FFFFu, 0xFFFFFFFFFFFE0000u, 0x0002000000020000u,
0x0001000000000000u, 0x000000000000FFFFu, 0xFFFFFFFFFFFF0000u, 0x0001000000010000u,
0x0000800000000000u, 0x0000000000007FFFu, 0xFFFFFFFFFFFF8000u, 0x0000800000008000u,
0x0000400000000000u, 0x0000000000003FFFu, 0xFFFFFFFFFFFFC000u, 0x0000400000004000u,
0x0000200000000000u, 0x0000000000001FFFu, 0xFFFFFFFFFFFFE000u, 0x0000200000002000u,
0x0000100000000000u, 0x0000000000000FFFu, 0xFFFFFFFFFFFFF000u, 0x0000100000001000u,
0x0000080000000000u, 0x00000000000007FFu, 0xFFFFFFFFFFFFF800u, 0x0000080000000800u,
0x0000040000000000u, 0x00000000000003FFu, 0xFFFFFFFFFFFFFC00u, 0x0000040000000400u,
0x0000020000000000u, 0x00000000000001FFu, 0xFFFFFFFFFFFFFE00u, 0x0000020000000200u,
0x0000010000000000u, 0x00000000000000FFu, 0xFFFFFFFFFFFFFF00u, 0x0000010000000100u,
0x0000008000000000u, 0x000000000000007Fu, 0xFFFFFFFFFFFFFF80u, 0x0000008000000080u,
0x0000004000000000u, 0x000000000000003Fu, 0xFFFFFFFFFFFFFFC0u, 0x0000004000000040u,
0x0000002000000000u, 0x000000000000001Fu, 0xFFFFFFFFFFFFFFE0u, 0x0000002000000020u,
0x0000001000000000u, 0x000000000000000Fu, 0xFFFFFFFFFFFFFFF0u, 0x0000001000000010u,
0x0000000800000000u, 0x0000000000000007u, 0xFFFFFFFFFFFFFFF8u, 0x0000000800000008u,
0x0000000400000000u, 0x0000000000000003u, 0xFFFFFFFFFFFFFFFCu, 0x0000000400000004u,
0x0000000200000000u, 0x0000000000000001u, 0xFFFFFFFFFFFFFFFEu, 0x0000000200000002u,
0x0000000100000000u, 0x0000000000000000u, 0xFFFFFFFFFFFFFFFFu, 0x0000000100000001u,
0x8000000000000000u, 0x0000000000000000u, 0x7FFFFFFF80000000u, 0x0000000080000000u,
0x4000000000000000u, 0x0000000000000000u, 0x3FFFFFFFC0000000u, 0x0000000040000000u,
0x2000000000000000u, 0x0000000000000000u, 0x1FFFFFFFE0000000u, 0x0000000020000000u,
0x1000000000000000u, 0x0000000000000000u, 0x0FFFFFFFF0000000u, 0x0000000010000000u,
0x0800000000000000u, 0x0000000000000000u, 0x07FFFFFFF8000000u, 0x0000000008000000u,
0x0400000000000000u, 0x0000000000000000u, 0x03FFFFFFFC000000u, 0x0000000004000000u,
0x0200000000000000u, 0x0000000000000000u, 0x01FFFFFFFE000000u, 0x0000000002000000u,
0x0100000000000000u, 0x0000000000000000u, 0x00FFFFFFFF000000u, 0x0000000001000000u,
0x0080000000000000u, 0x0000000000000000u, 0x007FFFFFFF800000u, 0x0000000000800000u,
0x0040000000000000u, 0x0000000000000000u, 0x003FFFFFFFC00000u, 0x0000000000400000u,
0x0020000000000000u, 0x0000000000000000u, 0x001FFFFFFFE00000u, 0x0000000000200000u,
0x0010000000000000u, 0x0000000000000000u, 0x000FFFFFFFF00000u, 0x0000000000100000u,
0x0008000000000000u, 0x0000000000000000u, 0x0007FFFFFFF80000u, 0x0000000000080000u,
0x0004000000000000u, 0x0000000000000000u, 0x0003FFFFFFFC0000u, 0x0000000000040000u,
0x0002000000000000u, 0x0000000000000000u, 0x0001FFFFFFFE0000u, 0x0000000000020000u,
0x0001000000000000u, 0x0000000000000000u, 0x0000FFFFFFFF0000u, 0x0000000000010000u,
0x0000800000000000u, 0x0000000000000000u, 0x00007FFFFFFF8000u, 0x0000000000008000u,
0x0000400000000000u, 0x0000000000000000u, 0x00003FFFFFFFC000u, 0x0000000000004000u,
0x0000200000000000u, 0x0000000000000000u, 0x00001FFFFFFFE000u, 0x0000000000002000u,
0x0000100000000000u, 0x0000000000000000u, 0x00000FFFFFFFF000u, 0x0000000000001000u,
0x0000080000000000u, 0x0000000000000000u, 0x000007FFFFFFF800u, 0x0000000000000800u,
0x0000040000000000u, 0x0000000000000000u, 0x000003FFFFFFFC00u, 0x0000000000000400u,
0x0000020000000000u, 0x0000000000000000u, 0x000001FFFFFFFE00u, 0x0000000000000200u,
0x0000010000000000u, 0x0000000000000000u, 0x000000FFFFFFFF00u, 0x0000000000000100u,
0x0000008000000000u, 0x0000000000000000u, 0x0000007FFFFFFF80u, 0x0000000000000080u,
0x0000004000000000u, 0x0000000000000000u, 0x0000003FFFFFFFC0u, 0x0000000000000040u,
0x0000002000000000u, 0x0000000000000000u, 0x0000001FFFFFFFE0u, 0x0000000000000020u,
0x0000001000000000u, 0x0000000000000000u, 0x0000000FFFFFFFF0u, 0x0000000000000010u,
0x0000000800000000u, 0x0000000000000000u, 0x00000007FFFFFFF8u, 0x0000000000000008u,
0x0000000400000000u, 0x0000000000000000u, 0x00000003FFFFFFFCu, 0x0000000000000004u,
0x0000000200000000u, 0x0000000000000000u, 0x00000001FFFFFFFEu, 0x0000000000000002u,
0x0000000100000000u, 0x0000000000000000u, 0x00000000FFFFFFFFu, 0x0000000000000001u
};

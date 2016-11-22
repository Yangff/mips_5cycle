#include <cstdio>

FILE *fasm;
FILE *fstd;

void check(int i, unsigned int val) {
	fprintf(fstd, "%u\n", val);
	fprintf(fasm, "break %d\n", i + 16);
}

void set_val(unsigned int a, unsigned int b){
	fprintf(fasm, "xor $s3, $0, $0\n");
	fprintf(fasm, "li $s1, %u\n", a);
	fprintf(fasm, "li $s2, %u\n", b);
}

void set_val(unsigned int a){
	fprintf(fasm, "li $s1, %u\n", a);
	fprintf(fasm, "xor $s2, $0, $0\n");
	fprintf(fasm, "xor $s3, $0, $0\n");
}

int main(){
	fasm = fopen("test_all.asm", "w");
	fstd = fopen("test_all.std", "w");
	// add ok
	set_val(123456, 654321);
	fprintf(fasm, "add $s3, $s1, $s2\n");
	check(3, 123456 + 654321);

	// add break
	set_val(0x7FFFFFFF, 0x7FFFFF);
	fprintf(fasm, "add $s3, $s1, $s2\n");
	check(3, 0);
	// addu
	set_val(0x7FFFFFFF, 0x7FFFFF);
	fprintf(fasm, "addu $s3, $s1, $s2\n");
	check(3, 0x7FFFFFFFU+0x7FFFFFU);

	// sub ok
	set_val(123456, 654321);
	fprintf(fasm, "sub $s3, $s1, $s2\n");
	check(3, 123456 - 654321);

	// sub break
	set_val(0x80000000u, 0x7FFFFF);
	fprintf(fasm, "sub $s3, $s1, $s2\n");
	check(3, 0);

	// subu
	set_val(0x80000000U, 0x7FFFFF);
	fprintf(fasm, "subu $s3, $s1, $s2\n");
	check(3, 0x80000000U - 0x7FFFFF);

	// slt
	set_val(1,2);
	fprintf(fasm, "slt $s3, $s1, $s2\n");
	check(3, 1);
	// slt
	set_val(2,1);
	fprintf(fasm, "slt $s3, $s1, $s2\n");
	check(3, 0);
	// slt
	set_val(1,1);
	fprintf(fasm, "slt $s3, $s1, $s2\n");
	check(3, 0);
	// slt
	set_val(123232,211111111);
	fprintf(fasm, "slt $s3, $s1, $s2\n");
	check(3, 1);
	// slt
	set_val(-1,1);
	fprintf(fasm, "slt $s3, $s1, $s2\n");
	check(3, 1);
	// sltu
	set_val((unsigned int)(-1),1);
	fprintf(fasm, "sltu $s3, $s1, $s2\n");
	check(3, 0);

	//  wire dc_ins_sll;
	set_val(100, 0);
	fprintf(fasm, "sll $s3, $s1, 10\n");
	check(3, 100 << 10);
	set_val(100, 10);
	fprintf(fasm, "sllv $s3, $s1, $s2\n");
	check(3, 100 << 10);

	// srl 
	set_val(1024, 0);
	fprintf(fasm, "srl $s3, $s1, 1\n");
	check(3, 512);
	set_val(1024, 1);
	fprintf(fasm, "srlv $s3, $s1, $s2\n");
	check(3, 512);

	// sra
	set_val(0xFFFFFFF0, 0);
	fprintf(fasm, "sra $s3, $s1, 8\n");
	check(3, 0xFFFFFFFF);
	set_val(0xFFFFFFF0, 8);
	fprintf(fasm, "srav $s3, $s1, $s2\n");
	check(3, 0xFFFFFFFF);

	set_val(0xA4B2592F, 0xCA092DE1);
	fprintf(fasm, "and $s3, $s1, $s2\n");
	check(3, 0xA4B2592F & 0xCA092DE1);

	set_val(0xA4B2592F, 0xCA092DE1);
	fprintf(fasm, "or $s3, $s1, $s2\n");
	check(3, 0xA4B2592F | 0xCA092DE1);

	set_val(0xA4B2592F, 0xCA092DE1);
	fprintf(fasm, "xor $s3, $s1, $s2\n");
	check(3, 0xA4B2592F ^ 0xCA092DE1);

	set_val(0xA4B2592F, 0xCA092DE1);
	fprintf(fasm, "nor $s3, $s1, $s2\n");
	check(3, ~(0xA4B2592F | 0xCA092DE1));

	set_val(0x101bc670);
	fprintf(fasm, "addi $s3, $s1, 1024\n");
	check(3, 0x101bc670 + 1024);

	set_val(0x7fffffff);
	fprintf(fasm, "addi $s3, $s1, 1024\n");
	check(3, 0);

	set_val(0x7fffffff);
	fprintf(fasm, "addiu $s3, $s1, 1024\n");
	check(3, 0x7fffffffu + 1024u);

	set_val(0xA301B41C);
	fprintf(fasm, "andi $s3, $s1, 1024\n");
	check(3, 0xA301B41C & 1024);

	set_val(0xA301B41C);
	fprintf(fasm, "ori $s3, $s1, 1024\n");
	check(3, 0xA301B41C | 1024);

	set_val(0xA301B41C);
	fprintf(fasm, "xori $s3, $s1, 1024\n");
	check(3, 0xA301B41C ^ 1024);

	set_val(0);
	fprintf(fasm, "lui $s3, 1024\n");
	check(3, 1024 << 16);

	set_val(20);
	fprintf(fasm, "slti $s3, $s1, 1024\n");
	check(3, 1);

	set_val(2048);
	fprintf(fasm, "slti $s3, $s1, 1024\n");
	check(3, 0);

	set_val(-1);
	fprintf(fasm, "slti $s3, $s1, 1024\n");
	check(3, 1);

	set_val(-1);
	fprintf(fasm, "sltiu $s3, $s1, 1024\n");
	check(3, 0);

	set_val(100);
	fprintf(fasm, "sb $s1, 0($0)\n");
	set_val(101);
	fprintf(fasm, "sb $s1, 1($0)\n");
	set_val(102);
	fprintf(fasm, "sb $s1, 2($0)\n");
	set_val(103);
	fprintf(fasm, "sb $s1, 3($0)\n");
	fprintf(fasm, "lw $s3, 0($0)\n");
	fprintf(fasm, "lb $s4, 0($0)\n");
	fprintf(fasm, "lb $s5, 1($0)\n");
	fprintf(fasm, "lb $s6, 2($0)\n");
	fprintf(fasm, "lb $s7, 3($0)\n");
	check(3, 0x64656667);
	check(4, 0x64);
	check(5, 0x65);
	check(6, 0x66);
	check(7, 0x67);

	set_val(0x307F);
	fprintf(fasm, "sh $s1, 0($0)\n");
	set_val(0x3129);
	fprintf(fasm, "sh $s1, 2($0)\n");
	fprintf(fasm, "lw $s3, 0($0)\n");
	fprintf(fasm, "lh $s4, 0($0)\n");
	fprintf(fasm, "lh $s5, 2($0)\n");
	check(3, 0x307F3129);
	check(4, 0x307F);
	check(5, 0x3129);	

	fclose(fasm);
	fclose(fstd);
}

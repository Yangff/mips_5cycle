xor $s3, $0, $0
li $s1, 123456
li $s2, 654321
add $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2147483647
li $s2, 8388607
add $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2147483647
li $s2, 8388607
addu $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 123456
li $s2, 654321
sub $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2147483648
li $s2, 8388607
sub $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2147483648
li $s2, 8388607
subu $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 1
li $s2, 2
slt $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2
li $s2, 1
slt $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 1
li $s2, 1
slt $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 123232
li $s2, 211111111
slt $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 4294967295
li $s2, 1
slt $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 4294967295
li $s2, 1
sltu $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 100
li $s2, 0
sll $s3, $s1, 10
break 19
xor $s3, $0, $0
li $s1, 100
li $s2, 10
sllv $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 1024
li $s2, 0
srl $s3, $s1, 1
break 19
xor $s3, $0, $0
li $s1, 1024
li $s2, 1
srlv $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 4294967280
li $s2, 0
sra $s3, $s1, 8
break 19
xor $s3, $0, $0
li $s1, 4294967280
li $s2, 8
srav $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2763151663
li $s2, 3389599201
and $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2763151663
li $s2, 3389599201
or $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2763151663
li $s2, 3389599201
xor $s3, $s1, $s2
break 19
xor $s3, $0, $0
li $s1, 2763151663
li $s2, 3389599201
nor $s3, $s1, $s2
break 19
li $s1, 270255728
xor $s2, $0, $0
xor $s3, $0, $0
addi $s3, $s1, 1024
break 19
li $s1, 2147483647
xor $s2, $0, $0
xor $s3, $0, $0
addi $s3, $s1, 1024
break 19
li $s1, 2147483647
xor $s2, $0, $0
xor $s3, $0, $0
addiu $s3, $s1, 1024
break 19
li $s1, 2734797852
xor $s2, $0, $0
xor $s3, $0, $0
andi $s3, $s1, 1024
break 19
li $s1, 2734797852
xor $s2, $0, $0
xor $s3, $0, $0
ori $s3, $s1, 1024
break 19
li $s1, 2734797852
xor $s2, $0, $0
xor $s3, $0, $0
xori $s3, $s1, 1024
break 19
li $s1, 0
xor $s2, $0, $0
xor $s3, $0, $0
lui $s3, 1024
break 19
li $s1, 20
xor $s2, $0, $0
xor $s3, $0, $0
slti $s3, $s1, 1024
break 19
li $s1, 2048
xor $s2, $0, $0
xor $s3, $0, $0
slti $s3, $s1, 1024
break 19
li $s1, 4294967295
xor $s2, $0, $0
xor $s3, $0, $0
slti $s3, $s1, 1024
break 19
li $s1, 4294967295
xor $s2, $0, $0
xor $s3, $0, $0
sltiu $s3, $s1, 1024
break 19
li $s1, 100
xor $s2, $0, $0
xor $s3, $0, $0
sb $s1, 0($0)
li $s1, 101
xor $s2, $0, $0
xor $s3, $0, $0
sb $s1, 1($0)
li $s1, 102
xor $s2, $0, $0
xor $s3, $0, $0
sb $s1, 2($0)
li $s1, 103
xor $s2, $0, $0
xor $s3, $0, $0
sb $s1, 3($0)
lw $s3, 0($0)
lb $s4, 0($0)
lb $s5, 1($0)
lb $s6, 2($0)
lb $s7, 3($0)
break 19
break 20
break 21
break 22
break 23
li $s1, 12415
xor $s2, $0, $0
xor $s3, $0, $0
sh $s1, 0($0)
li $s1, 12585
xor $s2, $0, $0
xor $s3, $0, $0
sh $s1, 2($0)
lw $s3, 0($0)
lh $s4, 0($0)
lh $s5, 2($0)
break 19
break 20
break 21

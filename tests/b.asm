li $s1, 100
li $s2, 100

beq $s1, $s2, ok1
break 33
ok1:

li $s2, 101

beq $s1, $s2, failed1
j ok2
failed1:
break 34
ok2:

bne $s1, $s2, ok3
break 35
ok3:

li $s2, 100
bne $s1, $s2, failed2
j ok4
failed2:
break 36
ok4:

li $s1, 0

blez $s1, ok5
break 37
ok5:

li $s1, -1

blez $s1, ok6
break 38
ok6:


li $s1, 0

bltz $s1, failed3
j ok7
failed3:
break 39
ok7:

li $s1, -1

bltz $s1, ok8
break 40
ok8:






li $s1, 0

bgez $s1, ok9
break 41
ok9:

li $s1, 1

bgez $s1, ok10
break 42
ok10:


li $s1, 0

bgtz $s1, failed4
j ok11
failed4:
break 43
ok11:

li $s1, 1

bgtz $s1, ok12
break 44
ok12:

jal func
j ok13
func:
jr $ra
break 45
ok13:

la $t2, func1
jalr $t1, $t2
j ok14
func1:
jr $t1
break 46
ok14:


la $t2, func2
jr $t2
break 47
func2:

break 0



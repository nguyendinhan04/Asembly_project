.eqv MONITOR_SCREEN 0x10010000  # Start address of the bitmap display 
.eqv RED            0x00FF0000  # Common color values 
.eqv GREEN          0x0000FF00 
.eqv BLUE           0x000000FF 
.eqv WHITE          0x00FFFFFF 
.eqv YELLOW         0x00FFFF00 

.data
menu_string: .asciz "\nPLOTING FUNCTION GRAPHS.\nMenu:\n1.Plot a graph\n2.Exit\nEnter your choice: "
input_string_a: .asciz "Nhap a: "
input_string_b: .asciz "Nhap b: "
input_string_c: .asciz "Nhap c: "
exit_string: .asciz "Goodbye!"
choose_color_string: .asciz "\nChoose your graph color:\n1.RED\n2.GREEN\n3.BLUE\n4.WWHITE \n5.YELLOW\nEnter your choice: "
.text


menu_loop:
li a7, 4
la a0,menu_string
ecall

li a7,5
ecall

addi a0, a0, -1
beqz a0, function


exit:
li a7, 4
la a0, exit_string
ecall

li a7, 10
ecall




function:
input:

li a7,4
la a0, choose_color_string
ecall

li a7,5
ecall

switch_case:
li t0, 1
beq a0, t0, case_1

li t0, 2
beq a0, t0, case_2

li t0, 3
beq a0, t0, case_3

li t0, 4
beq a0, t0, case_4

li t0, 5
beq a0, t0, case_5


#luu mau vao rregister s7
case_1:
li s7, RED
j end_switch_case

case_2:
li s7, GREEN
j end_switch_case

case_3:
li s7, BLUE
j end_switch_case

case_4:
li s7, WHITE
j end_switch_case

case_5:
li s7, YELLOW
j end_switch_case

end_switch_case:



#nhap a
li a7, 4
la a0, input_string_a
ecall
li a7, 5
ecall
add s1, a0, zero
#set s8 = 0
add s8, zero, zero
bgt s1, zero, skip_is_negative
#s8 = 1 -> a < 0, s8 =0 -> a > 0
li s8, 1
skip_is_negative:

#nhap b
li a7, 4
la a0, input_string_b
ecall
li a7, 5
ecall
add s2, zero, a0

#nhap c
li a7, 4
la a0, input_string_c
ecall
li a7, 5
ecall
add s3, zero, a0

#tinh -b/2a va luu vao s6
li t5, 2
mul t6, t5, s1
sub t5, zero, s2
div t6, t5, t6
add s6, zero, t6

j menu_loop


#tim khoang tinh tien theo x va luu vao s4
addi s4, t6, -255  
sub s4, zero, s4

add a0, t6, zero
#goi ham cal_parabol voi input la a0, output la a0
jal call_parabol

#tim khoang tinh tien theo y va luu vao s5
sub s5, zero, a0


addi t0, s6, -256
addi t1, s6, 256
loop_through_points:
bgt t0, t1, end_loop_through_points


addi a0, zero, t0
#goi ham tinh toa do x' va y', tra ve gia tri cua x' va y' trong 2 register a0 va a1
jal call_parabol:

addi a0, a0, 255

#neu a < 0 cong len 512 don vi
beq s8, zero, skip_shift
addi a1, a1, 512

skip_shift:
# tinh y' = -y' + 255 de dao nguoc do thi
addi a1, a1, -255
sub a1, zero, a1
#goi ham ve voi input la a0 va a1
jal plot
 

end_loop_through_points: 


j menu_loop



call_parabol:
jr ra


#ham plot nhan input x' trong a0 va y' trong a1, return gia tri dia chi trong register a0 
plot:
addi sp, sp, -4
sw ra, 0(sp)

li t1, 512
add t0, a1, zero
mul t0, t0,t1 #des = 512*y
add t0, t0, a0 #des = x + 512*y
slli, t0, t0, 2 # des = 4*(x + 512*y)

li t2, MONITOR_SCREEN 
add t2, t2, t0
sw s7, 0(t2)
lw ra, 0(sp)
addi sp, sp, 4
jr ra


clear_bitmap:


addi sp, sp, -4
sw, ra, 0(sp)


lw ra, 0(sp)
addi sp, sp, 4
jr ra


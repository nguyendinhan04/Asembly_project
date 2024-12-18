.data
	newline: .asciz "\n"

.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012

.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 

.text 
main:             
	li  t1, IN_ADDRESS_HEXA_KEYBOARD 
	li  t2, OUT_ADDRESS_HEXA_KEYBOARD 
	li  t3, 0x01 # start checking from row 1

	
polling:          
	sb  t3, 0(t1) # must reassign expected row 
	lb  a1, 0(t2) # read scan code of key button
	bnez a1, store_key     # Branch if a key is pressed
	bnez t5, update
	
	# Move to next row (shift left by 1)
    	slli t3, t3, 1         # Shift t3 left by 1 to scan the next row (0x1 -> 0x2 -> 0x4 -> 0x8)
    	li  t4, 0x10           # t4 = 0x10, to check if all rows have been scanned
    	bne t3, t4, polling    # If not all rows have been scanned, continue scanning
    	
    	# Reset to the first row and continue
    	li  t3, 0x1
    	j polling            # Jump back to scanning rows
store_key: 
	mv t5, a1
	j polling
sleep:        
	li  a0, 100 # sleep 100ms 
	li  a7, 32 
	ecall        
back_to_polling:  
	j polling # continue polling
	
update:
	jal convert
	
	li s2, 1
	li s3, 9
	
	blt t5, s2, 1ELSE_IF_1
	bgt t5, s3, 1ELSE_IF_1
	#thuc hien neu la so
		li s2, 1
		beq s8, s2,p11
		
		li s2, 2
		beq s8, s2, p12
		
		li s2, 3
		beq s8, s2, p13
		
		li s2, 4
		beq s8, s2, p14
		j end1
		
		p11: 
			li s2, 10
			mul s4, s2
			add s4, s4, t5
			j end1
		
		p12:
			addi s8, zero, 3
			add s6, zero, t5
			j end1
		
		p13:
			li s2, 10
			mul s6, s2
			add s6, s4, t5	
			j end1	
		
		p14:
            li s8, 1
            add s4, zero, t5
			j end1
		
		end1:
	j END
	
	1ELSE_IF_1: 
	li s2, 10
	li s3, 15
	
	blt t5, s2, 1ELSE_IF_2
	bgt t5, s3, 1ELSE_IF_2
	#thuc hien neu la dau
		li s2, 1
		beq s8, s2,p21
		
		li s2, 2
		beq s8, s2, p22
		
		li s2, 3
		beq s8, s2, p23
		
		li s2, 4
		beq s8, s2, p24
		j end2
		
		p21: 
			addi s8, 0, 2
			add s5, zero, t5
			j end2
		
		p22:
			add s5, zero, t5
			j end2
		
		p23:

            addi sp, sp, -16
            sw ra, 16(sp)
            sw a0, 12(sp)
            sw a1, 8(sp)
            sw a2, 4(sp)
            sw a3, 0(sp)

            add a0, zero, s4
            add a1, zero, s5
            add a2, zero, s6
            jal tinh
            add s4, zero, a0
            add s5, zero, t5 
            li s8, 2

            addi sp, sp, 16
            lw ra, 16(sp)
            lw a0, 12(sp)
            lw a1, 8(sp)
            lw a2, 4(sp)
            lw a3, 0(sp)

			j end2	
		
		p24:
			add s4, zero, s7
            add s5, zero, t5
            li s8, 2
			j end2
		
		end2:
	j END
	
	1ELSE_IF_2:
	li s2, 15
	bne t5, s2, END 
	#thuc hien neu la = 

    li s2, 1
		beq s8, s2,p31
		
		li s2, 2
		beq s8, s2, p32
		
		li s2, 3
		beq s8, s2, p33
		
		li s2, 4
		beq s8, s2, p34
		j end3
            p31:
            add s7, s4, zero
            li s8, 4
            j end3

            p32:
            add s6, zero, s4
            
                addi sp, sp, -16
				sw ra, 16(sp)
				sw a0, 12(sp)
				sw a1, 8(sp)
				sw a2, 4(sp)
				sw a3, 0(sp)

                add a0, zero, s4
                add a1, zero, s5
                add a2, zero, s6
                jal tinh
                add s7, zero, a0
                li s8, 4

                addi sp, sp, 16
				lw ra, 16(sp)
				lw a0, 12(sp)
				lw a1, 8(sp)
				lw a2, 4(sp)
				lw a3, 0(sp)

            j end3

            p33:

                addi sp, sp, -16
				sw ra, 16(sp)
				sw a0, 12(sp)
				sw a1, 8(sp)
				sw a2, 4(sp)
				sw a3, 0(sp)

                add a0, zero, s4
                add a1, zero, s5
                add a2, zero, s6
                jal tinh
                add s7, zero, a0
                li s8, 4

                addi sp, sp, 16
				lw ra, 16(sp)
				lw a0, 12(sp)
				lw a1, 8(sp)
				lw a2, 4(sp)
				lw a3, 0(sp)

            j end3

            p34:

                add s4, zero, s7

                addi sp, sp, -16
				sw ra, 16(sp)
				sw a0, 12(sp)
				sw a1, 8(sp)
				sw a2, 4(sp)
				sw a3, 0(sp)

                add a0, zero, s4
                add a1, zero, s5
                add a2, zero, s6
                jal tinh
                add s7, zero, a0
                li s8, 4

                addi sp, sp, 16
				lw ra, 16(sp)
				lw a0, 12(sp)
				lw a1, 8(sp)
				lw a2, 4(sp)
				lw a3, 0(sp)
                #chia truong hop dau hien tai la gi
            j end3



        end3:
	j END 
	
	
	
	
	
	
	END:
	
	
	
	
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall 
	li t5, 0
	j polling
	
convert:
    li t6, 0x11          # Check for 0x11
    beq t5, t6, case_0
    
    li t6, 0x21          # Check for 0x21
    beq t5, t6, case_1
    
    li t6, 0x41          # Check for 0x41
    beq t5, t6, case_2
    
    li t6, 0x81          # Check for 0x81
    beq t5, t6, case_3
    
    li t6, 0x12          # Check for 0x12
    beq t5, t6, case_4
    
    li t6, 0x22          # Check for 0x22
    beq t5, t6, case_5
    
    li t6, 0x42          # Check for 0x42
    beq t5, t6, case_6
    
    li t6, 0x82          # Check for 0x82
    beq t5, t6, case_7
    
    li t6, 0x14          # Check for 0x14
    beq t5, t6, case_8
    
    li t6, 0x24          # Check for 0x24
    beq t5, t6, case_9
    
    li t6, 0x44          # Check for 0x44
    beq t5, t6, case_10
    
    li t6, 0x84          # Check for 0x84
    beq t5, t6, case_11
    
    li t6, 0x18          # Check for 0x18
    beq t5, t6, case_12
    
    li t6, 0x28          # Check for 0x28
    beq t5, t6, case_13
    
    li t6, 0x48          # Check for 0x48
    beq t5, t6, case_14
    
    li t6, 0x88          # Check for 0x88
    beq t5, t6, case_15

# Define all case labels
case_0:
    li t5, 0
    jr ra

case_1:
    li t5, 1
    jr ra

case_2:
    li t5, 2
    jr ra

case_3:
    li t5, 3
    jr ra

case_4:
    li t5, 4
    jr ra

case_5:
    li t5, 5
    jr ra

case_6:
    li t5, 6
    jr ra

case_7:
    li t5, 7
    jr ra

case_8:
    li t5, 8
    jr ra

case_9:
    li t5, 9
    jr ra

case_10:
    li t5, 10
    jr ra

case_11:
    li t5, 11
    jr ra

case_12:
    li t5, 12
    jr ra

case_13:
    li t5, 13
    jr ra

case_14:
    li t5, 14
    jr ra

case_15:
    li t5, 15
    jr ra
    


#ham tinh nhan 3 tham so dau vao a0, a1, a2 va return lai vao a0
tinh: 
	addi sp, sp, -8
	sw ra, 4(sp)
	sw t0, 0(sp)


	li t0, 10         # t0 = 10
    beq a1, t0, cong   # N?u a1 == 10, nh?y t?i ADD

    li t0, 11         # t0 = 11
    beq a1, t0, truu   # N?u a1 == 11, nh?y t?i SUB

    li t0, 12         # t0 = 12
    beq a1, t0, nhan   # N?u a1 == 12, nh?y t?i MUL

    li t0, 13         # t0 = 13
    beq a1, t0, chia   # N?u a1 == 13, nh?y t?i DIV

    li t0, 14         # t0 = 14
    beq a1, t0, modun   # N?u a1 == 14, nh?y t?i MOD

    # N?u không có giá tr? h?p l?, return giá tr? ban ??u c?a a0
                # Tr? v? a0
	end_tinh:



	lw ra, 4(sp)
	lw t0, 0(sp)
	addi sp, sp, 8
jr ra

#input a0, a1 output a0
cong:
add a0, a0, a2
j end_tinh

chia:
div a0, a0, a2
jr ra

nhan:
mul a0, a0, a2
j end_tinh

tru:
sub a0, a0, a2
j end_tinh

modun:
rem a0, a0, a3
j end_tinh



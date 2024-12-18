.data
	newline: .asciz "\n"
	seven_seg: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
	space: .asciz " "
	equal: .asciz "="

.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012

.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 

.eqv SEVENSEG_LEFT    0xFFFF0011	# Address of the LED on the left 

.eqv SEVENSEG_RIGHT   0xFFFF0010    	# Address of the LED on the right 

.text 
main:             
	li  t1, IN_ADDRESS_HEXA_KEYBOARD 
	li  t2, OUT_ADDRESS_HEXA_KEYBOARD 
	li  t3, 0x01 		# start checking from row 1
	li s8, 1
polling:          
	sb  t3, 0(t1) 		# assign the row to t3
	lb  a1, 0(t2) 		# read scan code of key button
	bnez a1, store_key     	# If a key is pressed, store the value to t5
	bnez t5, update		# If a1 = 0 but t5 != 0 (the loop in which the user release the key), update the current number
	# If no branch condition satisfied (a1 = 0 and t5 = 0), it means there's no key pressed from the user -> continue polling
	
	# Move to next row (shift left by 1)
    	slli t3, t3, 1         	# Shift t3 left by 1 to scan the next row (0x1 -> 0x2 -> 0x4 -> 0x8)
    	li  t4, 0x10           	# t4 = 0x10, to check if all rows have been scanned
    	bne t3, t4, polling    	# If not all rows have been scanned, continue scanning
    	
    	# Reset to the first row and continue
    	li  t3, 0x1
    	j polling            	# Jump back to scanning rows
store_key: 
	mv t5, a1		# Store the scan code of the key pressed to t5. t5 is the temporary storage for the scan code	
	j polling		# After store the current key to t5, keep listening for key related events
	
update:
	# The program only jumps to update if a1 = 0 (user release the key)
	# and t5 != 0 (the temporary storage for the key hasn't been modified yet)
	jal convert 		# Conver the key code to actual number. Eg: 0x12 to 4
	
	# after converting t5
	li s0, 10		# Use s0 to find the last digit (remaining when divided by 10)
	blt t5, s0, skip_set_s1
	li s1, 0
	 
	 skip_set_s1: 
    	bge t5, s0,logic_handling
#=================================================DISPLAY=================================================
	addi    sp, sp, -24     # Allocate 24 bytes on the stack to avoid replacing important register
	sw      t1, 0(sp)       # Save t1
    	sw      t2, 4(sp)       # Save t2
    	sw      t3, 8(sp)       # Save t3
    	sw      t4, 12(sp)      # Save t4
    	sw      t5, 16(sp)      # Save t5
    	sw      t6, 20(sp)      # Save t6
    
    	mv t3, t5 		# Store the last digit to prepare for 7-segment right display
    	rem t1, s1, s0		# Store the second last digit to prepare for 7-segment left display
    
    	# Conversion Logic
    	la      t2, seven_seg         # Load address of seven_seg table
    	add     t4, t2, t3            # Calculate address for right digit
    	lb      t5, 0(t4)             # Load 7-seg code for right digit into t5

    	add     t4, t2, t1            # Calculate address for left digit
    	lb      t6, 0(t4)             # Load 7-seg code for left digit into t6

    	# Display Left Digit
    	mv      a0, t6                # Move left digit 7-seg code to a0
    	jal     SHOW_7SEG_LEFT        # Call SHOW_7SEG_LEFT

    	# Display Right Digit
    	mv      a0, t5                # Move right digit 7-seg code to a0
    	jal     SHOW_7SEG_RIGHT       # Call SHOW_7SEG_RIGHT

    	# Epilogue: Restore t1-t6 from the stack
    	lw      t1, 0(sp)             # Restore t1
    	lw      t2, 4(sp)             # Restore t2
    	lw      t3, 8(sp)             # Restore t3
    	lw      t4, 12(sp)            # Restore t4
    	lw      t5, 16(sp)            # Restore t5
    	lw      t6, 20(sp)            # Restore t6
    
    	addi    sp, sp, 24            # Deallocate 24 bytes from the stack
#===========================================END DISPLAY=============================================
    	logic_handling:
#=========================================LOGIC HANDLING============================================
    	li s2, 0		# Use to check if t5 is a number or a arithmetic operation
	li s3, 9		# Use to check if t5 is a number or a arithmetic operation
    	
    	blt t5, s2, ELSE_IF_1	# Check if t5 is a number or an arithmetic operation
	bgt t5, s3, ELSE_IF_1	# Check if t5 is a number or an arithmetic operation
	
	#=====CASE 1: the user presses a number=====
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
			mul s4, s2, s4
			add s4, s4, t5
			j end1
		
		p12:
			addi s8, zero, 3
			add s6, zero, t5
			j end1
		
		p13:
			li s2, 10
			mul s6, s2, s6
			add s6, s6, t5	
			j end1	
		
		p14:
            li s8, 1
            add s4, zero, t5
			j end1
		
		end1:
	j END
	#===================END OF CASE 1===========================
	
	ELSE_IF_1:
	# Continue to check between case 2 and case 3
	li s2, 10
	li s3, 14
	
	bgt t5, s3, ELSE_IF_2
	
	#=====CASE 2: the user presses an arithmetic operation======
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
			addi s8, zero, 2
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
            add s7, zero, a0
            
                addi sp, sp, -4
                sw ra, 0(sp)
                jal print_case
                
                lw ra 0(sp)
                addi sp, sp, 4
            
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
	#===================END OF CASE 2===============================
	
	#============= CASE 3: the user presses "=" ====================
    	ELSE_IF_2:
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
            li s5, 10
            li s6, 0
            add s7, s4, s6
            
                addi sp, sp, -4
                sw ra, 0(sp)
                jal print_case
                
                lw ra 0(sp)
                addi sp, sp, 4
            
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
                
                addi sp, sp, -4
                sw ra, 0(sp)
                jal print_case
                
                lw ra 0(sp)
                addi sp, sp, 4
                
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
                #add s7, s4, s6
                jal tinh
                add s7, zero, a0
                
                addi sp, sp, -4
                sw ra, 0(sp)
                jal print_case
                
                lw ra 0(sp)
                addi sp, sp, 4
                
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
                
                addi sp, sp, -4
                sw ra, 0(sp)
                jal print_case
                
                lw ra 0(sp)
                addi sp, sp, 4
                
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
	#===================END OF CASE 3===============================
	
#==================================END OF LOGIC HANDLING========================================

END:    	    	    	
    	# After the logic handling, add the last digit to the current number
    	li s0, 10
    	bge t5, s0, skip_shifing
    	
    	mul s1, s1, s0 		      # shift the whole number to the left
	add s1, s1, t5		      # add the last digit to the current number
	
	skip_shifing:
	li t5, 0		      # after the update, reset t5 to 0 to avoid the program jumping into update again
	j polling		      # jump back to polling
	
convert:
	# This function convert the scan code into real number
    	li t6, 0x11          # Check for 0x11
    	beq t5, t6, case_0
    
    	li t6, 0x21          # Check for 0x21
	beq t5, t6, case_1
    
    	li t6, 0x41          # Check for 0x41
    	beq t5, t6, case_2
    
    	li t6, 0xffffff81    # Check for 0x81
    	beq t5, t6, case_3
    
    	li t6, 0x12          # Check for 0x12
    	beq t5, t6, case_4
    
    	li t6, 0x22          # Check for 0x22
    	beq t5, t6, case_5
    
    	li t6, 0x42          # Check for 0x42
    	beq t5, t6, case_6
    
    	li t6, 0xffffff82    # Check for 0x82
    	beq t5, t6, case_7
    
    	li t6, 0x14          # Check for 0x14
    	beq t5, t6, case_8
    
    	li t6, 0x24          # Check for 0x24
    	beq t5, t6, case_9
    
    	li t6, 0x44          # Check for 0x44
    	beq t5, t6, case_10
    
    	li t6, 0xffffff84    # Check for 0x84
    	beq t5, t6, case_11
    
    	li t6, 0x18          # Check for 0x18
    	beq t5, t6, case_12
    
    	li t6, 0x28          # Check for 0x28
    	beq t5, t6, case_13
    
    	li t6, 0x48          # Check for 0x48
    	beq t5, t6, case_14
    
    	li t6, 0xffffff88    # Check for 0x88
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
    
SHOW_7SEG_LEFT:   
	addi    sp, sp, -4         
    	sw      t0, 0(sp) 
    	li      t0, SEVENSEG_LEFT   # Assign port's address  
    	sb      a0, 0(t0)           # Assign new value   
    	lw	t0, 0(sp)
    	addi 	sp, sp, 4
    	jr      ra 
    	
SHOW_7SEG_RIGHT:  
	addi    sp, sp, -4         
    	sw      t0, 0(sp) 
    	li   t0, SEVENSEG_RIGHT     # Assign port's address 
    	sb   a0, 0(t0)              # Assign new value 
    	lw	t0, 0(sp)
    	addi 	sp, sp, 4 
    	jr   ra

#======================================================
tinh: 
	addi sp, sp, -8
	sw ra, 4(sp)
	sw t0, 0(sp)


	li t0, 10         # t0 = 10
    beq a1, t0, cong   # N?u a1 == 10, nh?y t?i ADD

    li t0, 11         # t0 = 11
    beq a1, t0, tru   # N?u a1 == 11, nh?y t?i SUB

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
rem a0, a0, a2
j end_tinh
#======================================================

print_case:
	# s4: operator 1
	# s5: operation
	# s6: operator 2
	# s7: result
	# Message: "o1 op o2 = res\n"
	mv a0, s4
	li a7, 1
	ecall
	la a0, space
	li a7, 4
	ecall
	
	li a0, 10
	beq s5, a0, pcase_10
	li a0, 11
	beq s5, a0, pcase_11
	li a0, 12
	beq s5, a0, pcase_12
	li a0, 13
	beq s5, a0, pcase_13
	li a0, 14
	beq s5, a0, pcase_14
	
end_pcase:
	la a0, space
	li a7, 4
	ecall
	mv a0, s6
	li a7, 1
	ecall
	la a0, space
	li a7, 4
	ecall
	la a0, equal
	li a7, 4
	ecall
	la a0, space
	li a7, 4
	ecall
	mv a0, s7
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	jr ra
	
pcase_10:
    	li a0, 43
    	li a7, 11
    	ecall
    	j end_pcase 

pcase_11:
    	li a0, 45
    	li a7, 11
    	ecall
    	j end_pcase 

pcase_12:
    	li a0, 42
    	li a7, 11
    	ecall
    	j end_pcase 

pcase_13:
    	li a0, 47
    	li a7, 11
    	ecall
    	j end_pcase 

pcase_14:
    	li a0, 37
    	li a7, 11
    	ecall
    	j end_pcase 

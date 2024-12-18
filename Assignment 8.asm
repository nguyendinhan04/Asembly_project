.data
newline: .asciz "\n"
seven_seg: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012

.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 

.eqv SEVENSEG_LEFT    0xFFFF0011    # Address of the LED on the left 
                                    #     Bit 0 = segment a 
                                    #     Bit 1 = segment b 
                                    #     ...    
                                    #     Bit 7 = dot sign 

.eqv SEVENSEG_RIGHT   0xFFFF0010    # Address of the LED on the right 

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
	# after converting t5
	li s0, 10
	
	#mv a0, s1
	#li a7, 1
	#ecall
	#la a0, newline
	#li a7, 4
	#ecall
	
	addi    sp, sp, -24          # Allocate 24 bytes on the stack
    sw      t1, 0(sp)             # Save t1
    sw      t2, 4(sp)             # Save t2
    sw      t3, 8(sp)             # Save t3
    sw      t4, 12(sp)            # Save t4
    sw      t5, 16(sp)            # Save t5
    sw      t6, 20(sp)            # Save t6
    
    mv t3, t5
    rem t1, s1, s0
    
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
    
    addi    sp, sp, 24           # Deallocate 24 bytes from the stack
    
    	mul s1, s1, s0 # shift the whole number to the left
	add s1, s1, t5
	
	li t5, 0
	j polling
	
convert:
    li t6, 0x11          # Check for 0x11
    beq t5, t6, case_0
    
    li t6, 0x21          # Check for 0x21
    beq t5, t6, case_1
    
    li t6, 0x41          # Check for 0x41
    beq t5, t6, case_2
    
    li t6, 0xffffff81          # Check for 0x81
    beq t5, t6, case_3
    
    li t6, 0x12          # Check for 0x12
    beq t5, t6, case_4
    
    li t6, 0x22          # Check for 0x22
    beq t5, t6, case_5
    
    li t6, 0x42          # Check for 0x42
    beq t5, t6, case_6
    
    li t6, 0xffffff82          # Check for 0x82
    beq t5, t6, case_7
    
    li t6, 0x14          # Check for 0x14
    beq t5, t6, case_8
    
    li t6, 0x24          # Check for 0x24
    beq t5, t6, case_9
    
    li t6, 0x44          # Check for 0x44
    beq t5, t6, case_10
    
    li t6, 0xffffff84          # Check for 0x84
    beq t5, t6, case_11
    
    li t6, 0x18          # Check for 0x18
    beq t5, t6, case_12
    
    li t6, 0x28          # Check for 0x28
    beq t5, t6, case_13
    
    li t6, 0x48          # Check for 0x48
    beq t5, t6, case_14
    
    li t6, 0xffffff88          # Check for 0x88
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
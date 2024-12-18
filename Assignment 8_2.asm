#lu so thu 1 : s2
#luu toan tu o s3
#luu so thu 2: s4
#luu ket qua o s5
#dung tu t6
#s6 dung de luu phrase 
#phrase 1: nhap so thu 1
#phrase 2: nhap toan tu
#phrase 3: nhap so thu 2
#phrase 4: hien thi ket qua




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
	lb  a0, 0(t2) # read scan code of key button
	bnez a0, store_key     # Branch if a key is pressed
	
	# Move to next row (shift left by 1)
    	slli t3, t3, 1         # Shift t3 left by 1 to scan the next row (0x1 -> 0x2 -> 0x4 -> 0x8)
    	li  t4, 0x10           # t4 = 0x10, to check if all rows have been scanned
    	bne t3, t4, polling   # If not all rows have been scanned, continue scanning
    	
    	# Reset to the first row and continue
    	li  t3, 0x1
    	j polling            # Jump back to scanning rows
store_key: 
	mv t5, a0
	beq t5, t6, end_read
	beq t5, zero, end_read
	addi t6, t5, 0
	#0
	li t6, 0x11 
	beq  t5,t6, is_digit:
 	#1
 	li t6, 0x21 
	beq  t5,t6, is_digit:
	#2
	li t6, 0x41 
	beq  t5,t6, is_digit:
	#3
	li t6, 0x81 
	beq  t5,t6, is_digit:
	#4
	li t6, 0x12 
	beq  t5,t6, is_digit:
	#5
	li t6, 0x22 
	beq  t5,t6, is_digit:
	#6
	li t6, 0x42 
	beq  t5,t6, is_digit:
	#7
	li t6, 0x82 
	beq  t5,t6, is_digit:
	
	#8
	li t6, 0x14 
	beq  t5,t6, is_digit:
	
	#9
	li t6, 0x24 
	beq  t5,t6, is_digit:
	
	
	#+
	li t6, 0x24 
	beq  t5,t6, is_oper:
	#-
	li t6, 0x24 
	beq  t5,t6, is_oper:
	#*
	li t6, 0x24 
	beq  t5,t6, is_oper:
	#/
	li t6, 0x24 
	beq  t5,t6, is_oper:
	#%
	li t6, 0x24 
	beq  t5,t6, is_oper:
	
	#=
	li t6, 0x24 
	beq  t5,t6, is_equal:
	
	j end_read
	
	
	is_digit:
	switch_case_digit:
		switch_case_is_digit:
		li t0, 1
		beq s6, t0, switch_case_is_digit:_case_1
		li t0, 2
		beq s6, t0, switch_case_is_digit:_case_2
		li t0, 3
		beq s6, t0, switch_case_is_digit:_case_3
		li t0, 4
		beq s6, t0, switch_case_is_digit:_case_4
		j end_switch_case_is_digit
		
		switch_case_is_digit:_case_1:	
		
		switch_case_is_digit:_case_2:
		switch_case_is_digit:_case_3:
		switch_case_is_digit:_case_4:
		
		
		
		end_switch_case_is_digit:
				
	
	is_oper
	
	is_equal:
	
	
	end_read:
	
	li a7, 34 # print integer (hexa) 
	ecall
	li a7, 4
	la a0, newline
	ecall
	# jal construct
	li a0, 0
sleep:        
	li  a0, 100 # sleep 100ms 
	li  a7, 32 
	ecall        
back_to_polling:  
	j polling # continue polling
	
construct:
	li s0, 10
	mul s1, s1, s0 # shift the whole number to the left
	add s1, s1, t5

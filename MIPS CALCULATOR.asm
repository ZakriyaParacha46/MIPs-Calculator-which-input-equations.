#June 18, 2021
#DE-42 CE(B)
#Zakriya Asif Paracha (340413)
#Wajeeha Tahir (334584)
#Haris Fayyaz (359075)
#Aazain Umrani

.data
    operators: .word 0:8	#making an 8 word array for operators
    operands: .word 0:8		#making an 8 word array for operands
    buffer: .word 0:8		#making an 8 word array for the buffer
    userinp: .word 80		#taking user input 10 word (char) 
    start: .asciiz "------------MIPS CALCULATOR------------\n+ for Addition\n- for Difference\n* for Product\n/ for Quotient\n| for AND\n^ for OR\n<< for Left Shift\n>> for Right Shift\n\n"
    prompt: .asciiz "Enter the Equation: "
    errprmpt: .asciiz "Math error"
    errprmpt1: .asciiz "Type error, Invalid operation"
    line: .asciiz "----------------------------------------\n"
    equal: .asciiz " = "
 
 .text  
 
 main:  
 	li $v0,4
 	la $a0, start		#displays start message
 	syscall
	la $a0,prompt		#prompts for an equation
	syscall
	
 	li $v0,8
	la $a0,userinp		#takes user input
	li $a1,80
	syscall  
	
	li $t0,0
	li $t9,1
	jal parse
	return_main:
	
	li $t0, 0		#counter
	lw $t2, operands($t0)	#first operand
	jal collectData	
	
	li $v0, 4
	la $a0, line
	syscall
	li $t0, 0
	jal display		#displays final output
	
	j exit
	
collectData:			#keeps loading operands and operators from memory
	beq $t0, $t7, end	#ends when all operations have been processed
	lb $t4, operators($t0)	#operator
	addi $t0, $t0, 4
	lw $t3, operands($t0)	#second operand
	beq $t4, '+', addition
	beq $t4, '-', subtraction
	beq $t4, '*', multiplication
	beq $t4, '/', division
	beq $t4, '|', andFunc
	beq $t4, '^', orFunc
	beq $t4, '<', shiftLeft
	beq $t4, '>', shiftRight
	
addition:
	add $t2, $t2, $t3
	j collectData
	
subtraction:
	sub $t2, $t2, $t3
	j collectData
	
multiplication:
	mult $t2, $t3
	mflo $t2
	j collectData
	
division:
	beq $t3, $zero, mathError	#to prevent division by zero
	div $t2, $t3
	mflo $t2
	j collectData
	
andFunc:
	and $t2, $t2, $t3
	j collectData
	
orFunc:
	or $t2, $t2, $t3
	j collectData
	
shiftLeft:
	sllv $t2, $t2, $t3
	j collectData
	
shiftRight:
	srlv $t2, $t2, $t3
	j collectData

parse:
	lb $t1,userinp($t0)	#load the first byte from address in $t0  
	beq $t1,62,addo		#if the input has ">>" char go to addo--add_operation 
	beq $t1,60,addo		#if the input has ">>" char go to addo--add_operation 
	beq $t1,94,addo		#if the input has "^" char go to addo--add_operation 
	beq $t1,124,addo	#if the input has "|" char go to addo--add_operation 
	
	beq $t1,43,addo		#if the input has "+" char go to addo--add_operation 
	beq $t1,45,addo		#if the input has "-" char go to addo--add_operation 
	beq $t1,42,addo		#if the input has "/" char go to addo--add_operation 
	beq $t1,47,addo		#if the input has "*" char go to addo--add_operation 
	
	beq $t1,10,Return_parse	#if the char is 10 (endline) then continue the code else check if its a digit
	beq $t1,32,Return_parse	#if the char is 32 (space) then continue the code else check if its a digit
	bgt $t1,57,TypeError	#if its greater than 57(9) then its not a digit, give a type error	
	blt $t1,48,TypeError	#if its less than 48 (0) then its not a digit, give a type error
	
	Return_parse:		#return to the parse sequence
 	bgt $t1,57,skip		#if the char is greater than char 9, skip the conversion
 	blt $t1,48,skip		#if the char is less than char 0, skip the conversion
 	
 	subi $t1,$t1,48		#if char is of a number subtract 48 to make it an integer
 	sw $t1,buffer($t3)	#store the number in a buffer array, having the offset equal to the counter $t3
 	addi $t3,$t3,4 		#incrementing the operator counter ($t3)
 	
 	skip:			#if the charecter is not a number control comes to this sequence 
	lb $t1,userinp($t0)	#loads the first byte from address in $t0    
	beq $t1,10,final_addo	#if the input is finished, stop
 	addi $t0,$t0,1		#add one to the counter 
 	j parse
 
addo:	
	bnez $t3, skip_addo
	bne $t1,45,skip_sign	#if the input has "-" char and buffer is empty, use this sign as a negative integer
	li $t9,-1
	skip_sign:
	j Return_parse	
	
	skip_addo:
	sw $t1,operators($t2)	#store the operator in array
	addi $t2,$t2,4		#itterating the counter of operand array
	
	jal asc_num		#ascii to integer function
	
	return_addo:		#return to the addo after conversion
	mul $t5,$t5,$t9 
	sw $t5,operands($t6)	#store the byte in array
	addi $t6,$t6,4
	jal clean_buffer
	li $t8,0		#incrementing the operator counter
	li $t9,1
	
	j Return_parse		#loop until all the chars are parsed in from the input
asc_num:
	subi $t3,$t3,4          #subtracting 4 from $t3 to ignore the exit charecter
	lw $t5,buffer($t3)      #loading the last (least significant) digit from the buffer
	beqz $t3,return_addo    #if the number is zero return to addo, as conversion is done
	li $t7,1 		#initialize the $t7 register as multiplicative identity
	
	while:			#while loop which will convert digits into integers 
	mul $t7,$t7,10		#multiply $t7 by 10 to make the 10s, 100s, 1000s
	subi $t3,$t3,4		#subtract 4 from the offset to receive the more significant digit  
	lw $t1,buffer($t3)	#loading the digit on the offset
	mul $t1,$t1,$t7		#multiplying the digit with its place 
	add $t5,$t5,$t1		#adding the term to $t5 (solution)
	beqz $t3,return_addo	#if $t3 is zero at any point, return to addo as conversion is complete
	beq $t7,1000000, end	#if $t7 is equal to 1000,0000 (8 which is the size of our buffer) end the code; (used by final_addo)
	j while   
	
final_addo:
jal asc_num		# converts the buffer chars, into integer
				#clearing the registers
	move $t7,$t6		#storing number of operands in reg $t7 for future use
	li $t0,0	
	li $t1,0
	li $t2,0
	li $t3,0
	li $t5,0
	li $t6,0
				#exiting to main	
	j return_main

clean_buffer:
	beq $t8,32,end		#if the input has finished, stop
	sw $zero,buffer($t8)	#store the byte in array
 	addi $t8,$t8,4		#add one to the counter 
 	j clean_buffer
 
 TypeError:	
	li $v0, 4
 	la $a0, errprmpt1
 	syscall
 	j exit
 						
 mathError:
 	li $v0, 4
 	la $a0, errprmpt
 	syscall
 	j exit
 	
 display:			#loads an operand and then an operator and displays them
 	lw $t3, operands($t0)
 	move $a0, $t3
 	beq $t0, $t7, endDisplay
 	li $v0, 1
 	syscall
 	li $v0, 11
 	lw $t3, operators($t0)
 	move $a0, $t3
 	beq $t3, '<', excptn	#to display a second < sign
 	beq $t3, '>', excptn	#to display a second > sign
 	continue:
 	syscall
 	addi $t0, $t0, 4
 	j display		#loops until the whole equation has been printed
 	
 excptn:
 	syscall
 	j continue
 	
 endDisplay:
 	li $v0, 4
 	la $a0, equal		#displays equal sign
 	syscall
 	
 	li $v0, 1
 	move $a0, $t2		#displays final answer
 	syscall
 	j end
 	
end:  
	jr $ra
	
exit:
	li $v0,10 
	syscall

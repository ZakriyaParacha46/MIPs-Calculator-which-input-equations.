#/*# Output format must be:		*/
#/*# "Evaluates to = 12345"		*/

	.text		
       	.globl __start 
__start:		# execution starts here  */

# -- test string for the function
        la      $a0, prompt     #some string should be input
        li      $v0, 4
        syscall
mainloop:                       #WHILE non-empty string
        la      $a0, sentence
        li      $a1, 82
        li      $v0, 8          #input a string containing an expression
	syscall
        lb      $t0, ($a0)
        beq     $t0,0xA,exitprogram   #newline means 'ENTER' pressed immediately

	    la	    $a1,freespace	#a0 set above, a1, place to start storing nodes
            jal     parse

            #binary tree should be set up now. $v0 points to root
	#  YOU DO SOMETHING WITH IT

	    move    $a0,$v0	#input: pointer to an expression tree
            jal     evaluate	#evaluate it for an integer result

            move    $s0, $v0        #save result

            la      $a0, ans
            li      $v0, 4
            syscall

            move    $a0, $s0        #print result
	    li  $v0, 1
	    syscall
            la      $a0, endl
            li      $v0, 4
            syscall
	
            j mainloop
exitprogram:
        li      $v0, 10
        syscall                 #goodbye

##----------------------------------------------
# parse a prefix form (polish) arith expression
# and build a binary tree of that expression
# Grammar is:
#	S -> opSS  (an expression can be operator Expr. Expr.)
#	s -> N	   (a number is an expression)
#	N -> dN	   (Numbers are a series of digits) 
#	N -> delta (non-digit terminates Number)

parse:		# parse prefix expression, in string $a0, it keeps advancing
		# $a1 pointer to space for storing nodes
		# return $v0, pointer to root node of (sub)espression
		# nodes will be word with Operation char and 
		#    2 pointers (3 words), or 0 and a number (2 words)
# save registers:
         sub $sp, $sp, 12          #save registers
        sw      $ra,  ($sp)     # return address
        sw      $s0, 4($sp)     #use s0 to point to chars
        sw      $s2, 8($sp)     #    s2 pointer to current node
skip:				# back here on space or unrecognized char
	lb	$t0,($a0)	# get next char from string# S -> op S S  rule, check for operator

	beq	$t0,'+',operator
	beq	$t0,'-' operator
	beq	$t0,'*',operator
	beq	$t0,'/' operator
				#else next rule, is it a digit?
	move	$s0,$a0	# save pointer to chars.
	move	$a0,$t0
	jal	isDigit
	move	$t0, $a0	# still need character for null test
	move	$a0, $s0	# recall pointer
	beqz	$v0, ignore     # space or unexpected character, move on
	
# first digit detected!
	jal 	parsenumber
	move	$s2, $a1	# set up node at currently avail. space
	add      $a1, $a1, 8		# this node requires 2 words
	sw	$0, ($s2)	# 0 = leaf node
	sw	$v0, 4($s2)	# next word holds value
	j 	parseexit

operator:			# build operate node
	add     $a0, $a0, 1		# move on to next character
	move	$s2, $a1	# set up node at currently avail. space
	add      $a1, $a1, 12		# this node requires 3 words
	sw	$t0, ($s2)	# 0 = operator character
				# $a0 pass address of rest of string
				# $a1 is available space (see above)
	jal	parse		# parse an expression
	sw	$v0,4($s2)	# left subtree pointer
	jal	parse
	sw	$v0,8($s2)	# right subtree
	j parseexit
	
	
ignore:
	beqz	$t0,endofstring #ERROR, unanticipated end of string
	add $a0, $a0, 1		# move on to next character
	j	skip


endofstring:
	la	$a0,ErrorMess
	li	$v0,4
	syscall
	li	$v0,10		#EXIT the program on ERROR
	syscall

parseexit:
	move    $v0, $s2	# return root node address
        lw      $ra,  ($sp)
        lw      $s0, 4($sp)
        lw      $s2, 8($sp)
         add $sp, $sp, 12          # POP return address
        jr      $ra

##---------------------------------------------------------------------------
parsenumber:			#Called when $a0 points to initial digit
# save registers:
         sub $sp, $sp, 12          #save registers
        sw      $ra,  ($sp)     # return address
        sw      $s0, 4($sp)     #use s0 to point to chars
        sw      $s1, 8($sp)     #    s1 for binary number being built
	move	$s0, $a0	# save pointer to chars.
	lb	$t0,($s0)	# we know this is a digit
	and	$s1,$t0,0xf	# number = it's binary value
digitloop:
	add $s0, $s0, 1		# move on to next character
	lb	$a0,($s0)
	jal	isDigit		# is it also a number?
	beqz	$v0, finishednumber #no, done and don't consume char
	and	$t0,$a0,0xf	# make new digit binary
	mul	$s1,$s1,10	# previous digits increase in place value
	add	$s1,$s1,$t0	#  + new digit
	j	digitloop
finishednumber:
	move	$v0, $s1	# return the binary value of the whole number
	move	$a0, $s0	# consume the digits from string
        lw      $ra,  ($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
         add $sp, $sp, 12          # POP return address
        jr      $ra

##---------------------------------------------------------------------------
isDigit:                        #is the arg. a numeric char?
        slti    $t0, $a0,'0' 
        slti    $t1, $a0, 0x3A  #char. after '9'
        xor     $v0, $t0,$t1    # true if t0=1 and t1=0 (the reverse is impossible)
        and	$v0, 1 		# only want 1 bit result
        jr      $ra


#/* Any changes above this line will be discarded by
# mipsmark. Put your answer between dashed lines. */
#/*-------------- start cut ----------------------- */

#/*  Student's Name:		Account:		*/

evaluate:
        subi $sp, $sp, 12          #save registers
        lw $t0, ($a0) #symbol
        sw    $t0,  ($sp)        #value 1 //operator
        sw    $a0, 4($sp) 
        sw    $ra, 8($sp) 
 	        
        #left node
        lw $t1, 4($a0)#pointer 1
        #loading values to the pointers
        lw $t1 ,($t1)
        #leaf condition
        bne $t1, 0, notleaf1
        lw $t1, 4($a0)
        lw $t1 ,4($t1)
        notleaf1:
        beq   $t1,'+',eval1
        beq   $t1,'-',eval1 
        beq   $t1,'*',eval1
        beq   $t1,'/', eval1
        j num1 #if it its not an expresion pass its a leaf.
        eval1:
        lw $a0, 4($a0)#pointer 1
        jal evaluate
        move $t1,$v0 #v0 have the return of evaluate
        
        lw   $t0, ($sp) 
        lw   $a0, 4($sp)
        lw   $ra, 8($sp)
        num1:
     
 	#Right node
	#loading values to the pointers
        lw $t2, 8($a0)#pointer 2
        lw $t2 ,($t2)
         #leaf condition
        bne $t2, 0, notleaf2
        lw $t2,8($a0)
        lw $t2 ,4($t2)
        notleaf2:
        beq   $t2,'+',eval2
        beq   $t2,'-',eval2 
        beq   $t2,'*',eval2
        beq   $t2,'/', eval2
        j num2 #if it its not an expresion pass its a leaf.
        eval2:
        lw $t2, 8($a0)#pointer 1
        move $a0,$t2 
        jal evaluate
        move $t2,$v0 #v0 have the return of evaluate
        lw   $t0, ($sp) 
        lw   $a0, 4($sp)
        lw   $ra, 8($sp) 
        num2:      
        beq   $t0,'+',addn
        beq   $t0,'-' subn
        beq   $t0,'*',muln
        beq   $t0,'/' divn
        return_operator:
        jr $ra
 
                 
 addn:
 add $v0,$t1,$t2
 addi $sp, $sp, 12 
 j return_operator
 subn:
 sub  $v0,$t1,$t2
 addi $sp, $sp, 12 
 j return_operator
 divn:
 beqz $t1,error1
 div  $v0,$t1,$t2
 addi $sp, $sp, 12 
 j return_operator
 muln:
 mul  $v0,$t1,$t2
 addi $sp, $sp, 12 
 j return_operator
error1:
	li $v0, 4
	la $a0, DivError
	syscall
	j exitprogram
       
         .data			#*/
#sentence: .asciiz "12345\n"
sentence:	.space 84
prompt:	.asciiz "Type a (prefix) polish integer expression,\nuse space between numbers\nENTER to stop\n"
endl:   .asciiz "\n"
ans:    .asciiz "Evaluates to = "
ErrorMess: .asciiz "*** ERROR, unanticipated end of string\n"
DivError:  .asciiz "*** ERROR, divide by 0\n"
	.align  2
freespace:  .space  500      #lots of space for nodes (in fact, to SPIM limit)
#
#/*# End of file calctree.a		*/

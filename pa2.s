.section .data

input_x_prompt	:	.asciz	"Please enter x: "
input_y_prompt	:	.asciz	"Please enter y: "
input_spec	:	.asciz	"%d"
result		:	.asciz	"x^y = %d\n"

.section .text

.global main

main:
	
#Get the x input and store it
	ldr x0, =input_x_prompt
	bl printf 
	bl get_input
	mov x19, x0
	
#Get the y input and store it
	ldr x0, =input_y_prompt
	bl printf
	bl get_input
	mov x20, x0



#Call the exponent function. Store x in x0, y in x1, and result in x2
	mov x0, x19
	mov x1, x20
	mov x2, #1
	bl exponent_function

#Result is in x2, so move it to x1 and print the result 
	mov x1, x2
	ldr x0, =result
	bl printf

	b exit

get_input:

#Store stack pointer
	sub sp, sp, 8
	str x30, [sp]

#Get input from user
	ldr x0, =input_spec
	sub sp, sp, 8
	mov x1, sp
	bl scanf

#Load input into x0 to be returned
	ldrsw x0, [sp]
	add sp, sp, 8

#Restore stack pointer
	ldr x30, [sp]
	add sp, sp, 8

#Return 
	ret 

exponent_function:

#First check base cases
#x0 holds x so compare with 0, if equal branch to base case output
#x1 holds y so compare with 0, if less than 0 then branch to base case output 

	cmp x0, #0
	beq base_case 

	cmp x1, #0
	blt base_case

#If y is not 0 then recursively multiply x and decrement y 
	cmp x1, #0
	bne recursion_function 
#Base case is y = 0 in which case we multiply by 1
	mov x3, #1
	mul x2, x2, x3
	ret

#Base case sets y (x1) to 0 so that exponent_function will end 
#Base case sets return value (x2) to 0 so the exponent_function will return 0
base_case:
	mov x1, #0
	mov x2, #0
	ret

recursion_function:
#Store all variables in stack pointer
	sub sp, sp, #24
	stur x30, [sp,#16]
	stur x1, [sp, #8]
	stur x0, [sp]

#Call exponent_function with y-1
	sub x1, x1, #1
	bl exponent_function

#Unwind the stack and restore stack pointer
	ldur x0, [sp]
	ldur x1, [sp, #8]
	ldur x30, [sp, #16]
	add sp, sp, #24

#Calculates result*exponent_function(x,y-1) and returns the value
	mul x2, x0, x2
	ret 

	
# branch to this label on program completion
exit:
	mov x0, 0
	mov x8, 93
	svc 0
	ret

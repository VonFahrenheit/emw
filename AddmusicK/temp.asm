arch spc700-raw

org $000000
incsrc "asm/main.asm"
base $24B9

org $008000


	mov a, $0384
	beq +
	mov $51, a
	mov a, #$00
	mov $0384, a	
	mov $50, #$00
	
	
	mov x, #$0e            
	mov $48, #$80
	-
	mov a, #$00				
	mov $0270+x, a		
	
	mov   a, $31+x		
	
	lsr   $48
	dec   x
	dec   x
	bpl   -             
	+
	ret

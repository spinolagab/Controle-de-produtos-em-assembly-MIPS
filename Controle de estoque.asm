.data
# Entrada do usuario vai ser recebida como um vetor para analizar antes de prosseguir
vetor: 		.space 40

# $t1 = Backup do next do anterior (posicao 8-12 no node), $s1 = Endereco do node na heap 
 
# Mensagens  
mensagemMenu: 	.asciiz "\n**** SISTEMA DE CONTROLE DE ESTOQUE ****\n1. Inserir um novo item no estoque\n2. Excluir um item do estoque\n3. Buscar um item pelo codigo\n4. Atualizar a quantidade em estoque\n5. Imprimir os produtos em estoque\n6. Sair\nOpcao: "
mensagemCod: 	.asciiz "Insira o codigo do Item: "
mensagemQtd: 	.asciiz "Insira a quantidade do Item: "
mensagemBuscaEncontrou: .asciiz "O produto esta em estoque! \nQuantidade: "
pularLinha: .asciiz "\n"

erroSelecao:    .asciiz "Opcao invalida, selecione um numero entre 1 e 6!\n"
erroEmBusca: 	.asciiz "Nao achei chefe\n"
erroListaVazia: .asciiz "Lista vazia!\n"

printCod: .asciiz "\nCodigo: "
printQtd: .asciiz "\nQuantidade em Estoque: "

saida: 		.asciiz "Saindo...\n"

.text
main:
	li $t0, 0
	la $s0, ($t0) # Head inicialmente eh nulo
	# Contador utilitario
	li $t9, 0 # Contador comecando em 0
	li $s4, 1 #auxiliador para verificar entrada
	j menu
menu:
	# Apresenta o menu
	li $v0, 4
	la $a0, mensagemMenu
	syscall
	
	#Ler a entrada do usuario
    	li $v0, 8
    	la $a0, vetor
    	li $a1, 20
    	syscall

    	lb $t0, vetor($zero)
    	lb $s6, vetor($s4)
    	
    	blt $t0, 49, erroMenu # Caso a entrada seja menor que 1
    	bgt $t0, 54, erroMenu # Caso a entrada seja maior que 6
    	bne $s6, 10, erroMenu # Caso haja a entrada de mais de 1 valor no menu da erro


    	# Verificar a entrada do usuario
    	beq $t0, 49, inserir
    	beq $t0, 50, excluir
   	beq $t0, 51, buscar
    	beq $t0, 52, atualizar
    	beq $t0, 53, imprimir
    	beq $t0, 54, sair
    	

inserir:
	jal inserirNoNode
	j menu

	inserirNoNode:
		# Caso o contador seja 0 vai para a primeira iteracao
		beqz $t9, primeiraIteracao
    		outrasIteracoes:
        		# Alocando espaco na heap para o primeiro no da lista
    			li $a0, 12	# 12 bytes para armazenar um ponteiro e dois inteiros
    			li $v0, 9       # Codigo do servico do sistema para alocacao na heap
    			syscall         # Chama o sistema
    			move $s1, $v0   # Armazena o endereco do no alocado na heap em $s1
    			 
    			
    			# Pedir ao usuario que digite o codigo
    			li $v0, 4       
    			la $a0, mensagemCod  
    			syscall         
    			
    			# Ler codigo inserido
    			li $v0, 5       
    			syscall         
    			move $t1, $v0          
    			
    			# Pedir ao usuario que digite a quantidade
    			li $v0, 4       
    			la $a0, mensagemQtd  
    			syscall
    			
    			# Ler quantidade inserida
    			li $v0, 5
    			syscall       
    			move $t2, $v0
    			
    			# Armazenar valores no no
    			sw $t1, 0($s1)   # Armazena o codigo
    			sw $t2, 4($s1)   # Armazena a quantidade
    			sw $t0, 8($s1)  # O ponteiro proximo (NEXT) do no eh nulo (Recebe ZERO)
    			
    			sw $s1, 0($t3) # campo NEXT do no ANTERIOR recebe o endereco do NO ATUAL (CONEXAO DA LISTA)
    			la $t3, 8($s1) # atualiza o Marcador do campo NEXT para o NEXT do atual                
    			
    			# Incrementa o contador
    			add $t9, $t9, 1
    			
    			jr $ra
    			
		primeiraIteracao:
    			# Alocando espaco na heap para o primeiro no da lista
    			li $a0, 12       # 12 bytes para armazenar um ponteiro e dois inteiros
    			li $v0, 9       
    			syscall         
    			move $s1, $v0   # Armazena o endereco do no alocado na heap em $s1
    			
    			# Pedir ao usuario que digite o codigo
    			li $v0, 4       
    			la $a0, mensagemCod  
    			syscall         
    			
    			# Ler codigo inserido
    			li $v0, 5       
    			syscall         
    			move $t1, $v0          
    			
    			# Pedir ao usuario que digite a quantidade
    			li $v0, 4       
    			la $a0, mensagemQtd  
    			syscall
    			
    			# Ler quantidade inserida
    			li $v0, 5
    			syscall       
    			move $t2, $v0
    			
    			# Armazenar valores no no
    			sw $t1, 0($s1)   # Armazena o codigo
    			sw $t2, 4($s1)   # Armazena a quantidade
    			sw $t0, 8($s1)  # O ponteiro proximo (NEXT) do no eh nulo (Recebe ZERO)
    			
    			la $t3, 8($s1) # Fazendo uma copia do endereco do campo NEXT do primeiro no
    			
    			# Configurando o Head para o primeiro no da lista
    			move $s0, $s1  # head aponta para o 1o no da lista. $S0 eh o HEAD
    			
    			# Incrementa o contador
    			addi $t9, $t9, 1
    			
    			jr $ra
    			
excluir:
	beqz $t9, vazio
	
	#Receber o codigo a ser excluido
	li $v0, 4
	la $a0, mensagemCod
   	syscall
	li $v0, 5
	syscall
	move $s2, $v0 # $s2 = codigo a ser buscado
	move $s3, $zero
	
	# ponteiro que vai percorrer a lista comecando pelo head
	la $t4, ($s0)
	
	jal buscaExcluir
	j menu

buscaExcluir:
	# Se o s3 for igual ao contador nao encontrou
	beq $s3,$t9, naoEncontrado
	
	beq $s3, $zero, auxExcluir
	
	# t7 vai ser um auxiliar que pega o next
	lw $t7, 8($t4)
	
	#t5 eh o codigo do next
	lw $t5, 0($t7)
	# Se t5 for o que estamos buscando vai excluir
	beq $s2, $t5, Excluir2
	
	# Se nao for entao atualiza o ponteiro para o proximo
	lw $t4, 8($t4)
	
	addi $s3, $s3, 1
	
	j buscaExcluir
 	
    auxExcluir:
    	# t5 recebe o codigo atual
	lw $t5, 0($t4)
	beq $s2, $t5, Excluir1
        # se nao for o primeiro valor vai para o proximo
        addi $s3, $s3, 1
        
        j buscaExcluir

Excluir1:
	# Encontrou o codigo
        sw $zero, 0($t4)
        sw $zero, 4($t4)
        
        # armazena o endereco do next em s5
        #la $s5, 8($t4)
        # t8 recebe o endereco
        lw $t8, 8($t4)
        
        # s5 recebe o endereco do next
        la $s5, 0($t8)
        
        # transforma o next em 0
        sw $zero, 8($t4)
        
        # passa o novo endereco do next
        move $s0, $s5
        
        # Diminui o contador de valores na lista
        addi $t9, $t9, -1
        
        jr $ra

Excluir2:
	# Diminui o contador de valores na lista
        addi $t9, $t9, -1
        
	# Encontrou o codigo
        sw $zero, 0($t7)
        sw $zero, 4($t7)
        
        # t8 salva o endereco next
        lw $t8, 8($t7)
        
        # armazena o endereco do next em s5
        la $s5, 0($t8)
        
        # transforma o antigo next em 0
        sw $zero, 8($t7)
        
        # passa o novo endereco do next
        sw $s5, 8($t4)
        
        jr $ra
        
buscar:
	beqz $t9, vazio
	
	li $v0, 4
	la $a0, mensagemCod
   	syscall

	li $v0, 5
	syscall
	move $s2, $v0 # $s2 = codigo a ser buscado
	move $s3, $zero
	
	# ponteiro que vai percorrer a lista comecando pelo head
	la $t4, ($s0)
	
	jal buscaLista
	j menu

buscaLista:
	# Se o s3 for igual ao contador nao encontrou
	beq $s3,$t9, naoEncontrado
	
	# t5 recebe o codigo
	lw $t5, 0($t4)
	
	# se t5 for o codigo digitado entao encontrou
	beq $s2, $t5, encontrado
	
	# Se nao for entao atualiza o ponteiro para o proximo
	lw $t4, 8($t4)
	
	addi $s3, $s3, 1
	
	j buscaLista
 	
    encontrado:
        # Encontrou o codigo
        li $v0, 4
        la $a0, mensagemBuscaEncontrou
        syscall

        lw $a0, 4($t4) # Carrega a quantidade
        li $v0, 1
        syscall

        jr $ra

    naoEncontrado:
        # Nao encontrou o codigo
        li $v0, 4
        la $a0, erroEmBusca
        syscall

        jr $ra

atualizar:
	beqz $t9, vazio
	
	li $v0, 4
	la $a0, mensagemCod
   	syscall

	li $v0, 5
	syscall
	move $s2, $v0 # $s2 = codigo a ser buscado
	move $s3, $zero
	
	# ponteiro que vai percorrer a lista comecando pelo head
	la $t4, ($s0)
	
	jal atualizarQtd
	j menu

atualizarQtd:
	# Se o s3 for igual ao contador nao encontrou
	beq $s3,$t9, naoEncontrado
	
	# t5 recebe o codigo
	lw $t5, 0($t4)
	
	# se t5 for o codigo digitado entao atualize
	beq $s2, $t5, update
	
	# Se nao for entao atualiza o ponteiro para o proximo
	lw $t4, 8($t4)
	
	addi $s3, $s3, 1
	
	j atualizarQtd
 	
    update:
        # Receber novo valor
        li $v0, 4
        la $a0, mensagemQtd
        syscall
        
        
        li $v0, 5
        syscall
        
        sw $v0, 4($t4) # Carrega a quantidade

        jr $ra


imprimir:
	beqz $t9, vazio
	
	move $s3, $zero
	
	# ponteiro que vai percorrer a lista comecando pelo head
	la $t4, ($s0)
	
	jal loopImprimir
	j menu

loopImprimir:
	# Se o s3 for igual ao contador nao encontrou
	beq $s3,$t9, fimLoopImprimir
	
	# t5 recebe o codigo
	lw $t5, 0($t4)
	lw $t6, 4($t4)
	
	# printar o codigo
	li $v0, 4
	la $a0, printCod
	syscall
	li $v0, 1
	la $a0, ($t5)
	syscall
	
	# printar a quantidade
	li $v0, 4
	la $a0, printQtd
	syscall
	li $v0, 1
	la $a0, ($t6)
	syscall
	
	# Se nao for entao atualiza o ponteiro para o proximo
	lw $t4, 8($t4)
	
	addi $s3, $s3, 1
	
	j loopImprimir
 	
    fimLoopImprimir:
        jr $ra
        
vazio:
	li $v0, 4
	la $a0, erroListaVazia
	syscall
	j menu
	
erroMenu:
	li $v0, 4
	la $a0, erroSelecao
	syscall
	
	j menu
sair:
	li $v0, 4
	la $a0, saida
	syscall
	
	li $v0, 10
	syscall	

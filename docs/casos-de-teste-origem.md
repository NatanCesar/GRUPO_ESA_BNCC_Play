> Documento original de casos de teste, como recebido. O acompanhamento da
> execução está em `casos-de-teste.md`.

**FUNCIONALIDADES**

# **CT01 – Efetivação de Login do Professor**

### **Teste Funcional**

**Dados de Entrada**

* E-mail: professor@escola.com  
* Senha: Professor@123

**Descrição da adequação:** Verificar se um professor cadastrado consegue acessar o sistema utilizando credenciais válidas.

**Saída Esperada:** O sistema autentica o professor e exibe a tela inicial.

### **Teste Não Funcional (Segurança)**

**Dados de Entrada**

* Cinco tentativas consecutivas com senha incorreta.

**Descrição da adequação:** Verificar proteção contra ataques de força bruta.

**Saída Esperada:** O sistema bloqueia temporariamente novas tentativas e informa o usuário.

# **CT02 – Efetivação de Login do Aluno**

### **Teste Funcional**

**Dados de Entrada**

* E-mail do aluno  
* Senha correta

**Descrição da adequação:** Verificar se o aluno consegue acessar a plataforma.

**Saída Esperada:** A tela inicial do aluno é exibida.

### **Teste Não Funcional**

**Dados de Entrada**: Tentativa de acesso sem conexão segura (HTTP).

**Descrição da adequação:** Verificar comunicação segura.

**Saída Esperada:** O sistema força conexão HTTPS.

# **CT03 – Cadastro de Professor**

### **Teste Funcional**

**Dados de Entrada**

* Nome  
* E-mail  
* Escola  
* Senha

**Descrição da adequação:** Validar o cadastro de um novo professor.

**Saída Esperada:** Professor cadastrado com sucesso.

### **Teste Não Funcional**

**Dados de Entrada:** Cadastro contendo campos extras não utilizados.

**Descrição da adequação:** Verificar minimização de dados.

**Saída Esperada:** O sistema solicita apenas os campos obrigatórios.

**CT04 – Cadastro de Aluno**

### **Teste Funcional**

**Dados de Entrada:** Nome, e-mail, turma e senha.

**Descrição da adequação:** Verificar o cadastro de um estudante.

**Saída Esperada:** Conta criada com sucesso.

### **Teste Não Funcional**

**Dados de Entrada:** Cadastro com caracteres especiais e textos longos.

**Descrição da adequação:** Validar tratamento dos dados.

**Saída Esperada:** O sistema valida os campos e impede entradas inválidas.

# **CT05 – Seleção do Eixo da BNCC**

### **Teste Funcional**

**Dados de Entrada:** Professor seleciona "Pensamento Computacional".

**Descrição da adequação:** Verificar se apenas conteúdos daquele eixo são apresentados.

**Saída Esperada:** Questões referentes ao eixo escolhido.

### **Teste Não Funcional**

**Dados de Entrada:** Troca repetitiva entre eixos.

**Descrição da adequação:** Avaliar tempo de resposta.

**Saída Esperada:** Mudança concluída em menos de 2 segundos.

# **CT06 – Cadastro de Questões**

### **Teste Funcional**

**Dados de Entrada:** Questão completa com alternativas, resposta correta e eixo.

**Descrição da adequação:** Cadastrar nova questão.

**Saída Esperada**: Questão salva no banco.

### **Teste Não Funcional**

**Dados de Entrada:** Questão contendo script HTML.

**Descrição da adequação:** Verificar proteção contra XSS.

**Saída Esperada:** Scripts são bloqueados.

**CT07 – Definição do Nível de Dificuldade**

### **Teste Funcional**

**Dados de Entrada:** Selecionar dificuldade "Difícil".

**Descrição da adequação:** Associar dificuldade à questão.

**Saída Esperada:** Questão classificada corretamente.

### **Teste Não Funcional**

**Dados de Entrada:** Grande quantidade de questões sendo classificadas.

**Descrição da adequação:** Avaliar desempenho.

**Saída Esperada:** Sem degradação perceptível.

# **CT08 – Lista de Questões por Eixo**

### **Teste Funcional**

**Dados de Entrada:** Filtro: Cultura Digital.

**Descrição da adequação:** Listar apenas questões daquele eixo.

**Saída Esperada:** Somente questões relacionadas.

### **Teste Não Funcional**

**Dados de Entrada:** Banco com milhares de questões.

**Descrição da adequação:** Avaliar o desempenho da pesquisa.

**Saída Esperada:** Resposta inferior a 3 segundos.

# **CT09 – Alteração de Questão**

### **Teste Funcional**

**Dados de Entrada:** Editar enunciado de uma questão.

**Descrição da adequação:** Salvar alterações.

**Saída Esperada:** Questão atualizada.

### **Teste Não Funcional**

**Dados de Entrada:** Dois professores editando simultaneamente.

**Descrição da adequação:** Verificar concorrência.

**Saída Esperada:** O sistema evita conflitos de versões.

# **CT10 – Remoção de Questão**

### **Teste Funcional**

**Dados de Entrada:** Excluir questão cadastrada.

**Descrição da adequação:** Remover questões.

**Saída Esperada:** Questão deixa de aparecer na listagem.

### **Teste Não Funcional**

**Dados de Entrada:** Aluno tenta excluir questão.

**Descrição da adequação:** Validar permissões.

**Saída Esperada:** Operação negada.

# **CT11 – Alteração de Cadastro do Aluno**

### **Teste Funcional**

**Dados de Entrada:** Novo e-mail.

**Descrição da adequação:** Atualizar cadastro.

**Saída Esperada:** Dados alterados.

### **Teste Não Funcional**

**Dados de Entrada:** Tentativa sem autenticação.

**Descrição da adequação:** Verificar segurança.

**Saída Esperada:** Alteração bloqueada.

# **CT12 – Alteração de Cadastro do Professor**

### **Teste Funcional**

**Dados de Entrada:** Novo nome da instituição.

**Descrição da adequação:** Atualizar cadastro.

**Saída Esperada:** Cadastro atualizado.

### **Teste Não Funcional**

**Dados de Entrada:** Sessão expirada.

**Descrição da adequação:** Verificar autenticação.

**Saída Esperada:** Solicitação de novo login.

# **CT13 – Sistema Gamificado de Perguntas e Respostas**

### **Teste Funcional**

**Dados de Entrada:** Aluno responde corretamente uma pergunta.

**Descrição da adequação:** Registrar resposta.

**Saída Esperada:** Resposta registrada e feedback apresentado.

### **Teste Não Funcional**

**Dados de Entrada:** 100 alunos respondendo simultaneamente.

**Descrição da adequação:** Avaliar escalabilidade.

**Saída Esperada:** Sem travamentos.

# **CT14 – Pontuação e Recompensas**

### **Teste Funcional**

**Dados de Entrada:** Aluno conclui atividade.

**Descrição da adequação:** Calcular pontuação.

**Saída Esperada:** Pontos adicionados.

### **Teste Não Funcional**

**Dados de Entrada:** Tentativa de alterar pontuação manualmente.

**Descrição da adequação:** Verificar integridade.

**Saída Esperada:** Alteração rejeitada.

# **CT15 – Ranking de Jogadores**

### **Teste Funcional**

**Dados de Entrada:** Pontuações de vários alunos.

**Descrição da adequação:** Gerar ranking.

**Saída Esperada:** Ranking ordenado corretamente.

### **Teste Não Funcional**

**Dados de Entrada:** Usuário sem permissão tenta visualizar dados pessoais.

**Descrição da adequação:** Verificar anonimização.

**Saída Esperada:** Somente apelidos aparecem.

# **CT16 – Multiplayer em Sala**

### **Teste Funcional**

**Dados de Entrada:** Professor cria sala com 20 alunos.

**Descrição da adequação:** Permitir participação simultânea.

**Saída Esperada:** Todos entram na mesma sessão.

### **Teste Não Funcional**

**Dados de Entrada:** 50 conexões simultâneas.

**Descrição da adequação:** Avaliar estabilidade.

**Saída Esperada:** Sistema permanece disponível.

# **CT17 – Dashboard Pedagógico**

### **Teste Funcional**

**Dados de Entrada:** Professor acessa indicadores.

**Descrição da adequação:** Exibir estatísticas da turma.

**Saída Esperada:** Dashboard carregado corretamente.

### **Teste Não Funcional**

**Dados de Entrada:** Aluno tenta acessar o dashboard.

**Descrição da adequação:** Verificar controle de acesso.

**Saída Esperada:** Acesso negado.

# **CT18 – Relatórios de Desempenho**

### **Teste Funcional**

**Dados de Entrada:** Professor solicita relatório da turma.

**Descrição da adequação:** Gerar relatório.

**Saída Esperada:** Relatório disponível para download ou visualização.

### **Teste Não Funcional**

**Dados de Entrada:** Usuário sem autorização tenta acessar o relatório.

**Descrição da adequação:** Validar segurança e privacidade.

**Saída Esperada:** O sistema impede o acesso e registra a tentativa.


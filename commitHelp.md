Aqui estão os exemplos melhorados, com mais clareza e contextualização para cada tipo de commit:

---

**Conventional Commits** é uma especificação para padronizar mensagens de commits, facilitando a leitura para humanos e automação de processos. Ela organiza as mensagens em um formato específico:

```
<tipo>[escopo opcional]: <descrição>
[corpo opcional]
[rodapé opcional]
```

### **Principais tipos:**

1. **fix:** Corrige um problema no código (relacionado à versão **PATCH** do SemVer).
   - **Exemplo:**

     ```
     fix(parser): corrige erro ao processar arrays vazios
     
     Agora o parser reconhece e lida corretamente com arrays que não possuem elementos, evitando um erro que causava falhas na execução.
     ```

2. **feat:** Adiciona um novo recurso (relacionado à versão **MINOR** do SemVer).
   - **Exemplo:**

     ```
     feat(auth): adiciona suporte para autenticação OAuth
     
     Implementa autenticação com OAuth 2.0, permitindo integração com provedores externos como Google e Facebook.
     ```

3. **BREAKING CHANGE:** Indica uma mudança que quebra compatibilidade (relacionado à versão **MAJOR** do SemVer).
   - **Exemplo:**

     ```
     feat: refatora sistema de permissões

     BREAKING CHANGE: O método `checkPermissions` foi removido e substituído por `validatePermissions`, alterando a forma como as permissões são verificadas.
     ```

### **Outros tipos permitidos:**

4. **chore:** Alterações de manutenção que não afetam a lógica do código (ex: atualização de dependências).
   - **Exemplo:**

     ```
     chore: atualiza dependências para a versão mais recente

     Atualiza as bibliotecas ESLint e Prettier para as versões mais recentes, sem impacto nas funcionalidades existentes.
     ```

5. **docs:** Alterações na documentação.
   - **Exemplo:**

     ```
     docs: adiciona instruções de configuração no README

     Inclui detalhes sobre como configurar variáveis de ambiente para diferentes ambientes de desenvolvimento.
     ```

6. **style:** Mudanças que afetam apenas a formatação, sem alterar a lógica do código (espaçamento, indentação, etc.).
   - **Exemplo:**

     ```
     style: aplica formatação padrão com Prettier em todo o projeto

     Corrige inconsistências de espaçamento e indentação de acordo com as regras definidas no Prettier.
     ```

7. **refactor:** Alterações que reestruturam o código sem adicionar novos recursos ou corrigir bugs.
   - **Exemplo:**

     ```
     refactor(api): melhora estrutura de chamadas de API sem alterar funcionalidade

     Reorganiza o código das chamadas de API para melhorar a legibilidade e facilitar futuras manutenções, sem alterar o comportamento final.
     ```

8. **perf:** Melhoria de performance.
   - **Exemplo:**

     ```
     perf(query): otimiza consultas ao banco de dados para reduzir latência

     Melhora a performance das consultas ao utilizar índices corretamente, reduzindo o tempo de resposta da API em 30%.
     ```

9. **test:** Adiciona ou corrige testes.
   - **Exemplo:**

     ```
     test: adiciona testes unitários para a função `validateEmail`

     Testa cenários de e-mails inválidos, garantindo que a função `validateEmail` rejeite entradas incorretas e passe as corretas.
     ```

---

### **Vantagens:**

- **Automatiza** a criação de changelogs com base nas mensagens de commit.
- Facilita o **aumento de versão** seguindo as regras do SemVer.
- Estrutura o **histórico de commits** de maneira clara e organizada.
- Facilita a **colaboração** entre desenvolvedores, promovendo um histórico mais compreensível para todos.

---

### **Exemplo geral de commit:**

```
feat(lang): adiciona suporte para tradução em português brasileiro

BREAKING CHANGE: O arquivo de configuração agora exige o parâmetro `locale` para especificar o idioma.
```

---

A especificação **Conventional Commits** incentiva uma organização mais clara e eficiente dos commits, proporcionando automação e melhorando a colaboração em projetos de desenvolvimento.

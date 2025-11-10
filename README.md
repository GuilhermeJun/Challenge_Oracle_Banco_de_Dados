# Challenge Oracle - Banco de Dados

## Descrição

Projeto desenvolvido para o Challenge de Banco de Dados Oracle, implementando funções de validação, procedures CRUD e aplicação Java Spring Boot para execução das procedures.

## Autores

- RM567164 - Édipo Borges de Carvalho
- RM559986 - Guilherme Jun Conheci
- RM560088 - Igor Neris Soares Alves

## Requisitos Implementados

### 1. Funções de Validação de Entrada de Dados
- ✅ `fn_valida_cliente`: Valida CNPJ, e-mail e duplicidades
- ✅ `fn_valida_venda_evento`: Valida dispositivos, serviços, clientes e valores
- ✅ `fn_valida_servico`: Valida código, nome e preço do serviço

### 2. Procedures para Operações CRUD
- ✅ **Tabela CLIENTE:**
  - `prc_ins_cliente`: INSERT com validação
  - `prc_upd_cliente`: UPDATE com validação
  - `prc_del_cliente`: DELETE com verificação de relacionamentos

- ✅ **Tabela VENDA_EVENTO:**
  - `prc_ins_venda_evento`: INSERT com validação
  - `prc_upd_venda_evento`: UPDATE com validação
  - `prc_del_venda_evento`: DELETE com verificação de relacionamentos

- ✅ **Tabela SERVICO:**
  - `prc_ins_servico`: INSERT com validação
  - `prc_upd_servico`: UPDATE com validação
  - `prc_del_servico`: DELETE com verificação de relacionamentos

### 3. Execução de Procedures via Aplicação Java
- ✅ Projeto Maven com Spring Boot
- ✅ DAOs para execução das procedures
- ✅ Service de demonstração com 2 INSERTs, 2 UPDATEs e 2 DELETEs por tabela

### 4. Função com Cursor e JOINs para Relatório
- ✅ `fn_relatorio_venda_evento`: Relatório formatado com JOINs entre venda_evento, cliente, servico e dispositivo_iot

### 5. Função para Relatório com Regra de Negócio
- ✅ `fn_relatorio_financeiro_centro_custo`: Relatório financeiro com agregações (SUM, COUNT, AVG) por centro de custo

## Estrutura do Projeto

```
├── src/
│   └── main/
│       ├── java/br/fiap/
│       │   ├── Application.java  # Classe principal Spring Boot
│       │   ├── config/
│       │   │   └── OracleConfig.java
│       │   ├── dao/              # Data Access Objects
│       │   │   ├── ClienteDAO.java
│       │   │   ├── VendaEventoDAO.java
│       │   │   └── ServicoDAO.java
│       │   └── service/
│       │       └── ProcedureService.java
│       └── resources/
│           └── application.properties
├── challenge_oracle.sql          # Script SQL completo
├── pom.xml                       # Configuração Maven
└── README.md                     # Este arquivo
```

## Configuração do Banco de Dados

- **Host:** oracle.fiap.com.br
- **Porta:** 1521
- **SID:** orcl
- **Usuário:** rm560088
- **Senha:** 061005

## Como Executar

### 1. Preparar o Banco de Dados

Execute o script SQL completo no Oracle:

```sql
@challenge_oracle.sql
```

Ou copie e cole o conteúdo do arquivo `challenge_oracle.sql` no SQL Developer/SQL*Plus.

### 2. Configurar a Aplicação Java

As credenciais já estão configuradas em `src/main/resources/application.properties`. Se necessário, ajuste conforme seu ambiente.

### 3. Executar a Aplicação

```bash
# Compilar o projeto
mvn clean install

# Executar a aplicação
mvn spring-boot:run
```

A aplicação executará automaticamente a demonstração das procedures.

## Testando as Funções de Relatório

### Relatório de Eventos de Venda

```sql
SELECT * FROM TABLE(fn_relatorio_venda_evento);
```

### Relatório Financeiro por Centro de Custo

```sql
SELECT * FROM TABLE(fn_relatorio_financeiro_centro_custo);
```

## Tecnologias Utilizadas

- **Oracle Database 11g+**
- **Java 17**
- **Spring Boot 3.2.0**
- **Maven**
- **Oracle JDBC Driver (ojdbc11)**


## Observações Importantes

1. **Integridade Referencial:** Os DELETEs podem falhar se houver registros relacionados em outras tabelas
2. **Validações:** Todas as procedures utilizam funções de validação antes de inserir/atualizar
3. **Tratamento de Erros:** Todas as procedures têm tratamento robusto de exceções
4. **Dados de Teste:** Para testar venda_evento, é necessário ter dados válidos nas tabelas relacionadas (dispositivo_iot, servico, cliente)

## Status do Projeto

✅ **Concluído** - Todos os requisitos foram implementados e testados.

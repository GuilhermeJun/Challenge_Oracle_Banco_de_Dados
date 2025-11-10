--RM     Nome
--567164 Édipo Borges de Carvalho
--559986 Guilherme Jun Conheci
--560088 Igor Neris Soaress Alves

-- DROP TABLES com tratamento de erro
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE vendas CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE venda_evento CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE servico CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE reg_cont CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE dispositivo_iot CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE conta_contabil CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE cliente CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE centro_custo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE centro_custo (
    id_centro_custo   NUMBER(4) NOT NULL,
    nome_centro_custo VARCHAR2(70) NOT NULL
);

ALTER TABLE centro_custo ADD CONSTRAINT centro_custo_pk PRIMARY KEY ( id_centro_custo );

CREATE TABLE cliente (
    id_cliente    NUMBER(5) NOT NULL,
    nome_cliente  VARCHAR2(100) NOT NULL,
    data_cadastro DATE DEFAULT sysdate NOT NULL,
    cnpj          NUMBER(14) NOT NULL,
    email         VARCHAR2(100) NOT NULL,
    senha         VARCHAR2(100) NOT NULL,
    ativo         CHAR(1) DEFAULT 'A' NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_chk_ativo CHECK ( ativo IN ( 'A', 'I' ) );
ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );
ALTER TABLE cliente ADD CONSTRAINT cliente_cnpj_un UNIQUE ( cnpj );
ALTER TABLE cliente ADD CONSTRAINT cliente_email_un UNIQUE ( email );

CREATE TABLE conta_contabil (
    id_conta            NUMBER(4) NOT NULL,
    nome_conta_contabil VARCHAR2(70) NOT NULL,
    tipo                CHAR(1) NOT NULL,
    cliente_id_cliente  NUMBER(5)
);

-- Remover constraint se existir antes de criar
BEGIN
   FOR c IN (SELECT constraint_name 
             FROM user_constraints 
             WHERE table_name = 'CONTA_CONTABIL' 
             AND constraint_name = 'CONTA_CHK_TIPO') LOOP
      EXECUTE IMMEDIATE 'ALTER TABLE conta_contabil DROP CONSTRAINT ' || c.constraint_name;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

ALTER TABLE conta_contabil ADD CONSTRAINT conta_chk_tipo CHECK ( tipo IN ( 'R', 'D' ) );
ALTER TABLE conta_contabil ADD CONSTRAINT conta_contabil_pk PRIMARY KEY ( id_conta );

CREATE TABLE dispositivo_iot (
    id_dispos   NUMBER(6) NOT NULL,
    nome_dispos VARCHAR2(80) NOT NULL,
    tipo        VARCHAR2(20) DEFAULT 'ESP32' NOT NULL,
    ativo       CHAR(1) DEFAULT 'S' NOT NULL
);

ALTER TABLE dispositivo_iot ADD CONSTRAINT dispositivo_iot_chk_ativo CHECK ( ativo IN ( 'S', 'N' ) );
ALTER TABLE dispositivo_iot ADD CONSTRAINT dispositivo_iot_pk PRIMARY KEY ( id_dispos );

CREATE TABLE reg_cont (
    id_reg_cont                  NUMBER(4) NOT NULL,
    valor                        NUMBER(9, 2) NOT NULL,
    conta_contabil_id_conta      NUMBER(4) NOT NULL,
    centro_custo_id_centro_custo NUMBER(4) NOT NULL,
    data_criacao                 DATE DEFAULT sysdate,
    data_atualizacao             DATE
);

ALTER TABLE reg_cont ADD CONSTRAINT reg_cont_pk PRIMARY KEY ( id_reg_cont );

CREATE TABLE servico (
    id_servico     NUMBER(6) NOT NULL,
    codigo_servico VARCHAR2(50) NOT NULL,
    nome_servico   VARCHAR2(120) NOT NULL,
    preco_padrao   NUMBER(9, 2) NOT NULL,
    ativo          CHAR(1) DEFAULT 'S' NOT NULL
);

ALTER TABLE servico ADD CONSTRAINT servico_chk_ativo CHECK ( ativo IN ( 'S', 'N' ));
ALTER TABLE servico ADD CONSTRAINT servico_pk PRIMARY KEY ( id_servico );
ALTER TABLE servico ADD CONSTRAINT servico_codigo_un UNIQUE ( codigo_servico );

CREATE TABLE venda_evento (
    id_evento            NUMBER(12) NOT NULL,
    dispos_iot_id_dispos NUMBER(6) NOT NULL,
    uid_tag              VARCHAR2(32),
    servico_codigo       VARCHAR2(50),
    servico_id_servico   NUMBER(6),
    cliente_id_cliente   NUMBER(5),
    operador_id          NUMBER(5),
    quantidade           NUMBER(9, 2) DEFAULT 1 NOT NULL,
    valor_unitario       NUMBER(9, 2),
    valor_total          NUMBER(9, 2),
    origem               VARCHAR2(20) DEFAULT 'RFID',
    dt_evento            DATE DEFAULT sysdate NOT NULL,
    payload_json         CLOB,
    vendas_id_vendas     NUMBER(9)
);

ALTER TABLE venda_evento ADD CONSTRAINT venda_evento_pk PRIMARY KEY ( id_evento );

CREATE TABLE vendas (
    id_vendas              NUMBER(9) NOT NULL,
    cliente_id_cliente     NUMBER(5) NOT NULL,
    reg_cont_id_reg_cont   NUMBER(4) NOT NULL,
    venda_evento_id_evento NUMBER(12)
);

ALTER TABLE vendas ADD CONSTRAINT vendas_pk PRIMARY KEY ( id_vendas );

ALTER TABLE conta_contabil
    ADD CONSTRAINT conta_contabil_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE reg_cont
    ADD CONSTRAINT reg_cont_centro_custo_fk FOREIGN KEY ( centro_custo_id_centro_custo )
        REFERENCES centro_custo ( id_centro_custo );

ALTER TABLE reg_cont
    ADD CONSTRAINT reg_cont_conta_contabil_fk FOREIGN KEY ( conta_contabil_id_conta )
        REFERENCES conta_contabil ( id_conta );

ALTER TABLE venda_evento
    ADD CONSTRAINT venda_evento_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE venda_evento
    ADD CONSTRAINT venda_evento_dispos_iot_fk FOREIGN KEY ( dispos_iot_id_dispos )
        REFERENCES dispositivo_iot ( id_dispos );

ALTER TABLE venda_evento
    ADD CONSTRAINT venda_evento_servico_fk FOREIGN KEY ( servico_id_servico )
        REFERENCES servico ( id_servico );

ALTER TABLE venda_evento
    ADD CONSTRAINT venda_evento_vendas_fk FOREIGN KEY ( vendas_id_vendas )
        REFERENCES vendas ( id_vendas );

ALTER TABLE vendas
    ADD CONSTRAINT vendas_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE vendas
    ADD CONSTRAINT vendas_reg_cont_fk FOREIGN KEY ( reg_cont_id_reg_cont )
        REFERENCES reg_cont ( id_reg_cont );

ALTER TABLE vendas
    ADD CONSTRAINT vendas_venda_evento_fk FOREIGN KEY ( venda_evento_id_evento )
        REFERENCES venda_evento ( id_evento );
        
        
SET SERVEROUTPUT ON;
SET VERIFY OFF;

--Funções de Validação de Entrada de Dados

CREATE OR REPLACE FUNCTION fn_valida_cliente (
    p_nome_cliente IN VARCHAR2,
    p_cnpj         IN NUMBER,
    p_email        IN VARCHAR2
) RETURN VARCHAR2 IS
    v_existe_cnpj  NUMBER;
    v_existe_email NUMBER;
BEGIN
    -- Verifica formato do CNPJ (14 dígitos)
    IF LENGTH(TRIM(TO_CHAR(p_cnpj))) != 14 THEN
        RETURN 'ERRO: O CNPJ deve conter 14 dígitos.';
    END IF;

    -- Verifica formato de e-mail
    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RETURN 'ERRO: E-mail em formato inválido.';
    END IF;

    -- Verifica duplicidade de CNPJ
    SELECT COUNT(*) INTO v_existe_cnpj
      FROM cliente
     WHERE cnpj = p_cnpj;

    IF v_existe_cnpj > 0 THEN
        RETURN 'ERRO: CNPJ já cadastrado.';
    END IF;

    -- Verifica duplicidade de e-mail
    SELECT COUNT(*) INTO v_existe_email
      FROM cliente
     WHERE LOWER(email) = LOWER(p_email);

    IF v_existe_email > 0 THEN
        RETURN 'ERRO: E-mail já cadastrado.';
    END IF;

    RETURN 'OK';
END;
/


CREATE OR REPLACE FUNCTION fn_valida_venda_evento (
    p_dispos_id_dispos IN NUMBER,
    p_servico_id_servico IN NUMBER,
    p_cliente_id_cliente IN NUMBER,
    p_quantidade IN NUMBER,
    p_valor_unitario IN NUMBER,
    p_valor_total IN NUMBER
) RETURN VARCHAR2 IS
    v_dispos_ativo CHAR(1);
    v_servico_ativo CHAR(1);
    v_cliente_ativo CHAR(1);
BEGIN
    -- Verifica dispositivo ativo
    SELECT ativo INTO v_dispos_ativo
      FROM dispositivo_iot
     WHERE id_dispos = p_dispos_id_dispos;

    IF v_dispos_ativo != 'S' THEN
        RETURN 'ERRO: Dispositivo IoT inativo.';
    END IF;

    -- Verifica serviço ativo
    SELECT ativo INTO v_servico_ativo
      FROM servico
     WHERE id_servico = p_servico_id_servico;

    IF v_servico_ativo != 'S' THEN
        RETURN 'ERRO: Serviço inativo.';
    END IF;

    -- Verifica cliente ativo
    SELECT ativo INTO v_cliente_ativo
      FROM cliente
     WHERE id_cliente = p_cliente_id_cliente;

    IF v_cliente_ativo != 'A' THEN
        RETURN 'ERRO: Cliente inativo.';
    END IF;

    -- Verifica coerência de valores
    IF ABS(p_valor_total - (p_quantidade * p_valor_unitario)) > 0.01 THEN
        RETURN 'ERRO: Valor total divergente da multiplicação entre quantidade e valor unitário.';
    END IF;

    RETURN 'OK';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERRO: Registro inexistente em uma das tabelas (cliente, serviço ou dispositivo).';
    WHEN OTHERS THEN
        RETURN 'ERRO: ' || SQLERRM;
END;
/


-- Função de Validação para Serviço
CREATE OR REPLACE FUNCTION fn_valida_servico (
    p_codigo_servico IN VARCHAR2,
    p_nome_servico   IN VARCHAR2,
    p_preco_padrao   IN NUMBER
) RETURN VARCHAR2 IS
    v_existe_codigo NUMBER;
BEGIN
    -- Verifica se código do serviço já existe
    SELECT COUNT(*) INTO v_existe_codigo
      FROM servico
     WHERE UPPER(codigo_servico) = UPPER(p_codigo_servico);

    IF v_existe_codigo > 0 THEN
        RETURN 'ERRO: Código de serviço já cadastrado.';
    END IF;

    -- Verifica se nome do serviço está preenchido
    IF TRIM(p_nome_servico) IS NULL OR LENGTH(TRIM(p_nome_servico)) < 3 THEN
        RETURN 'ERRO: Nome do serviço deve ter pelo menos 3 caracteres.';
    END IF;

    -- Verifica se preço é válido
    IF p_preco_padrao IS NULL OR p_preco_padrao <= 0 THEN
        RETURN 'ERRO: Preço padrão deve ser maior que zero.';
    END IF;

    -- Verifica formato do código (alfanumérico)
    IF NOT REGEXP_LIKE(p_codigo_servico, '^[A-Z0-9]+$') THEN
        RETURN 'ERRO: Código do serviço deve conter apenas letras maiúsculas e números.';
    END IF;

    RETURN 'OK';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: ' || SQLERRM;
END;
/


--Procedures para Operações CRUD

-- ========== CLIENTE ==========

-- INSERT Cliente
CREATE OR REPLACE PROCEDURE prc_ins_cliente (
    p_id_cliente   IN cliente.id_cliente%TYPE,
    p_nome_cliente IN cliente.nome_cliente%TYPE,
    p_cnpj         IN cliente.cnpj%TYPE,
    p_email        IN cliente.email%TYPE,
    p_senha        IN cliente.senha%TYPE,
    p_ativo        IN cliente.ativo%TYPE DEFAULT 'A',
    p_resultado    OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
BEGIN
    -- Validação com a função
    v_msg_validacao := fn_valida_cliente(p_nome_cliente, p_cnpj, p_email);

    IF v_msg_validacao != 'OK' THEN
        p_resultado := v_msg_validacao;
        RETURN;
    END IF;

    -- Verifica se ID já existe
    DECLARE
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_existe
          FROM cliente
         WHERE id_cliente = p_id_cliente;

        IF v_existe > 0 THEN
            p_resultado := 'ERRO: ID de cliente já existe.';
            RETURN;
        END IF;
    END;

    -- Inserção
    INSERT INTO cliente (
        id_cliente,
        nome_cliente,
        cnpj,
        email,
        senha,
        ativo
    ) VALUES (
        p_id_cliente,
        p_nome_cliente,
        p_cnpj,
        p_email,
        p_senha,
        p_ativo
    );
    COMMIT;

    p_resultado := 'OK: Cliente inserido com sucesso: ' || p_nome_cliente;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_resultado := 'ERRO: Cliente já cadastrado (CNPJ ou E-mail duplicado).';
        ROLLBACK;
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- UPDATE Cliente
CREATE OR REPLACE PROCEDURE prc_upd_cliente (
    p_id_cliente   IN cliente.id_cliente%TYPE,
    p_nome_cliente IN cliente.nome_cliente%TYPE,
    p_cnpj         IN cliente.cnpj%TYPE,
    p_email        IN cliente.email%TYPE,
    p_senha        IN cliente.senha%TYPE,
    p_ativo        IN cliente.ativo%TYPE,
    p_resultado    OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
    v_existe        NUMBER;
BEGIN
    -- Verifica se cliente existe
    SELECT COUNT(*) INTO v_existe
      FROM cliente
     WHERE id_cliente = p_id_cliente;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Cliente não encontrado.';
        RETURN;
    END IF;

    -- Validação com a função (verifica duplicidade excluindo o próprio registro)
    DECLARE
        v_existe_cnpj  NUMBER;
        v_existe_email NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_existe_cnpj
          FROM cliente
         WHERE cnpj = p_cnpj AND id_cliente != p_id_cliente;

        IF v_existe_cnpj > 0 THEN
            p_resultado := 'ERRO: CNPJ já cadastrado para outro cliente.';
            RETURN;
        END IF;

        SELECT COUNT(*) INTO v_existe_email
          FROM cliente
         WHERE LOWER(email) = LOWER(p_email) AND id_cliente != p_id_cliente;

        IF v_existe_email > 0 THEN
            p_resultado := 'ERRO: E-mail já cadastrado para outro cliente.';
            RETURN;
        END IF;

        -- Valida formato
        IF LENGTH(TRIM(TO_CHAR(p_cnpj))) != 14 THEN
            p_resultado := 'ERRO: O CNPJ deve conter 14 dígitos.';
            RETURN;
        END IF;

        IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            p_resultado := 'ERRO: E-mail em formato inválido.';
            RETURN;
        END IF;
    END;

    -- Atualização
    UPDATE cliente
       SET nome_cliente = p_nome_cliente,
           cnpj         = p_cnpj,
           email        = p_email,
           senha        = p_senha,
           ativo        = p_ativo
     WHERE id_cliente = p_id_cliente;

    COMMIT;
    p_resultado := 'OK: Cliente atualizado com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- DELETE Cliente
CREATE OR REPLACE PROCEDURE prc_del_cliente (
    p_id_cliente IN cliente.id_cliente%TYPE,
    p_resultado  OUT VARCHAR2
) IS
    v_existe        NUMBER;
    v_tem_relacionamento NUMBER;
BEGIN
    -- Verifica se cliente existe
    SELECT COUNT(*) INTO v_existe
      FROM cliente
     WHERE id_cliente = p_id_cliente;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Cliente não encontrado.';
        RETURN;
    END IF;

    -- Verifica se há relacionamentos (vendas, contas contábeis)
    SELECT COUNT(*) INTO v_tem_relacionamento
      FROM venda_evento
     WHERE cliente_id_cliente = p_id_cliente;

    IF v_tem_relacionamento > 0 THEN
        p_resultado := 'ERRO: Não é possível excluir cliente com vendas associadas.';
        RETURN;
    END IF;

    -- Exclusão
    DELETE FROM cliente
     WHERE id_cliente = p_id_cliente;

    COMMIT;
    p_resultado := 'OK: Cliente excluído com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- ========== VENDA_EVENTO ==========

-- INSERT Venda Evento
CREATE OR REPLACE PROCEDURE prc_ins_venda_evento (
    p_id_evento         IN venda_evento.id_evento%TYPE,
    p_dispos_id_dispos  IN venda_evento.dispos_iot_id_dispos%TYPE,
    p_servico_id_servico IN venda_evento.servico_id_servico%TYPE,
    p_cliente_id_cliente IN venda_evento.cliente_id_cliente%TYPE,
    p_quantidade        IN venda_evento.quantidade%TYPE,
    p_valor_unitario    IN venda_evento.valor_unitario%TYPE,
    p_valor_total       IN venda_evento.valor_total%TYPE,
    p_uid_tag           IN venda_evento.uid_tag%TYPE DEFAULT NULL,
    p_operador_id       IN venda_evento.operador_id%TYPE DEFAULT NULL,
    p_origem            IN venda_evento.origem%TYPE DEFAULT 'RFID',
    p_resultado         OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
    v_existe        NUMBER;
BEGIN
    -- Verifica se ID já existe
    SELECT COUNT(*) INTO v_existe
      FROM venda_evento
     WHERE id_evento = p_id_evento;

    IF v_existe > 0 THEN
        p_resultado := 'ERRO: ID de evento já existe.';
        RETURN;
    END IF;

    -- Validação com a função
    v_msg_validacao := fn_valida_venda_evento(
        p_dispos_id_dispos,
        p_servico_id_servico,
        p_cliente_id_cliente,
        p_quantidade,
        p_valor_unitario,
        p_valor_total
    );

    IF v_msg_validacao != 'OK' THEN
        p_resultado := v_msg_validacao;
        RETURN;
    END IF;

    -- Inserção
    INSERT INTO venda_evento (
        id_evento,
        dispos_iot_id_dispos,
        servico_id_servico,
        cliente_id_cliente,
        quantidade,
        valor_unitario,
        valor_total,
        uid_tag,
        operador_id,
        origem
    ) VALUES (
        p_id_evento,
        p_dispos_id_dispos,
        p_servico_id_servico,
        p_cliente_id_cliente,
        p_quantidade,
        p_valor_unitario,
        p_valor_total,
        p_uid_tag,
        p_operador_id,
        p_origem
    );
    COMMIT;

    p_resultado := 'OK: Evento de venda inserido com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- UPDATE Venda Evento
CREATE OR REPLACE PROCEDURE prc_upd_venda_evento (
    p_id_evento         IN venda_evento.id_evento%TYPE,
    p_dispos_id_dispos  IN venda_evento.dispos_iot_id_dispos%TYPE,
    p_servico_id_servico IN venda_evento.servico_id_servico%TYPE,
    p_cliente_id_cliente IN venda_evento.cliente_id_cliente%TYPE,
    p_quantidade        IN venda_evento.quantidade%TYPE,
    p_valor_unitario    IN venda_evento.valor_unitario%TYPE,
    p_valor_total       IN venda_evento.valor_total%TYPE,
    p_resultado         OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
    v_existe        NUMBER;
BEGIN
    -- Verifica se evento existe
    SELECT COUNT(*) INTO v_existe
      FROM venda_evento
     WHERE id_evento = p_id_evento;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Evento de venda não encontrado.';
        RETURN;
    END IF;

    -- Validação com a função
    v_msg_validacao := fn_valida_venda_evento(
        p_dispos_id_dispos,
        p_servico_id_servico,
        p_cliente_id_cliente,
        p_quantidade,
        p_valor_unitario,
        p_valor_total
    );

    IF v_msg_validacao != 'OK' THEN
        p_resultado := v_msg_validacao;
        RETURN;
    END IF;

    -- Atualização
    UPDATE venda_evento
       SET dispos_iot_id_dispos = p_dispos_id_dispos,
           servico_id_servico   = p_servico_id_servico,
           cliente_id_cliente   = p_cliente_id_cliente,
           quantidade           = p_quantidade,
           valor_unitario       = p_valor_unitario,
           valor_total          = p_valor_total
     WHERE id_evento = p_id_evento;

    COMMIT;
    p_resultado := 'OK: Evento de venda atualizado com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- DELETE Venda Evento
CREATE OR REPLACE PROCEDURE prc_del_venda_evento (
    p_id_evento IN venda_evento.id_evento%TYPE,
    p_resultado OUT VARCHAR2
) IS
    v_existe        NUMBER;
    v_tem_relacionamento NUMBER;
BEGIN
    -- Verifica se evento existe
    SELECT COUNT(*) INTO v_existe
      FROM venda_evento
     WHERE id_evento = p_id_evento;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Evento de venda não encontrado.';
        RETURN;
    END IF;

    -- Verifica se há relacionamento com vendas
    SELECT COUNT(*) INTO v_tem_relacionamento
      FROM vendas
     WHERE venda_evento_id_evento = p_id_evento;

    IF v_tem_relacionamento > 0 THEN
        p_resultado := 'ERRO: Não é possível excluir evento com venda associada.';
        RETURN;
    END IF;

    -- Exclusão
    DELETE FROM venda_evento
     WHERE id_evento = p_id_evento;

    COMMIT;
    p_resultado := 'OK: Evento de venda excluído com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- ========== SERVICO ==========

-- INSERT Servico
CREATE OR REPLACE PROCEDURE prc_ins_servico (
    p_id_servico     IN servico.id_servico%TYPE,
    p_codigo_servico IN servico.codigo_servico%TYPE,
    p_nome_servico   IN servico.nome_servico%TYPE,
    p_preco_padrao   IN servico.preco_padrao%TYPE,
    p_ativo          IN servico.ativo%TYPE DEFAULT 'S',
    p_resultado      OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
    v_existe        NUMBER;
BEGIN
    -- Verifica se ID já existe
    SELECT COUNT(*) INTO v_existe
      FROM servico
     WHERE id_servico = p_id_servico;

    IF v_existe > 0 THEN
        p_resultado := 'ERRO: ID de serviço já existe.';
        RETURN;
    END IF;

    -- Validação com a função
    v_msg_validacao := fn_valida_servico(p_codigo_servico, p_nome_servico, p_preco_padrao);

    IF v_msg_validacao != 'OK' THEN
        p_resultado := v_msg_validacao;
        RETURN;
    END IF;

    -- Inserção
    INSERT INTO servico (
        id_servico,
        codigo_servico,
        nome_servico,
        preco_padrao,
        ativo
    ) VALUES (
        p_id_servico,
        p_codigo_servico,
        p_nome_servico,
        p_preco_padrao,
        p_ativo
    );
    COMMIT;

    p_resultado := 'OK: Serviço inserido com sucesso: ' || p_nome_servico;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_resultado := 'ERRO: Código de serviço já cadastrado.';
        ROLLBACK;
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- UPDATE Servico
CREATE OR REPLACE PROCEDURE prc_upd_servico (
    p_id_servico     IN servico.id_servico%TYPE,
    p_codigo_servico IN servico.codigo_servico%TYPE,
    p_nome_servico   IN servico.nome_servico%TYPE,
    p_preco_padrao   IN servico.preco_padrao%TYPE,
    p_ativo          IN servico.ativo%TYPE,
    p_resultado      OUT VARCHAR2
) IS
    v_msg_validacao VARCHAR2(200);
    v_existe        NUMBER;
    v_existe_codigo NUMBER;
BEGIN
    -- Verifica se serviço existe
    SELECT COUNT(*) INTO v_existe
      FROM servico
     WHERE id_servico = p_id_servico;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Serviço não encontrado.';
        RETURN;
    END IF;

    -- Verifica duplicidade de código (excluindo o próprio registro)
    SELECT COUNT(*) INTO v_existe_codigo
      FROM servico
     WHERE UPPER(codigo_servico) = UPPER(p_codigo_servico) AND id_servico != p_id_servico;

    IF v_existe_codigo > 0 THEN
        p_resultado := 'ERRO: Código de serviço já cadastrado para outro serviço.';
        RETURN;
    END IF;

    -- Validação básica
    IF TRIM(p_nome_servico) IS NULL OR LENGTH(TRIM(p_nome_servico)) < 3 THEN
        p_resultado := 'ERRO: Nome do serviço deve ter pelo menos 3 caracteres.';
        RETURN;
    END IF;

    IF p_preco_padrao IS NULL OR p_preco_padrao <= 0 THEN
        p_resultado := 'ERRO: Preço padrão deve ser maior que zero.';
        RETURN;
    END IF;

    -- Atualização
    UPDATE servico
       SET codigo_servico = p_codigo_servico,
           nome_servico   = p_nome_servico,
           preco_padrao   = p_preco_padrao,
           ativo          = p_ativo
     WHERE id_servico = p_id_servico;

    COMMIT;
    p_resultado := 'OK: Serviço atualizado com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- DELETE Servico
CREATE OR REPLACE PROCEDURE prc_del_servico (
    p_id_servico IN servico.id_servico%TYPE,
    p_resultado  OUT VARCHAR2
) IS
    v_existe        NUMBER;
    v_tem_relacionamento NUMBER;
BEGIN
    -- Verifica se serviço existe
    SELECT COUNT(*) INTO v_existe
      FROM servico
     WHERE id_servico = p_id_servico;

    IF v_existe = 0 THEN
        p_resultado := 'ERRO: Serviço não encontrado.';
        RETURN;
    END IF;

    -- Verifica se há relacionamentos (vendas)
    SELECT COUNT(*) INTO v_tem_relacionamento
      FROM venda_evento
     WHERE servico_id_servico = p_id_servico;

    IF v_tem_relacionamento > 0 THEN
        p_resultado := 'ERRO: Não é possível excluir serviço com vendas associadas.';
        RETURN;
    END IF;

    -- Exclusão
    DELETE FROM servico
     WHERE id_servico = p_id_servico;

    COMMIT;
    p_resultado := 'OK: Serviço excluído com sucesso.';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERRO: ' || SQLERRM;
        ROLLBACK;
END;
/


-- ========== FUNÇÕES DE RELATÓRIO ==========

-- Função com Cursor e JOINs para Relatório de Eventos de Venda
CREATE OR REPLACE TYPE tipo_relatorio_venda_evento AS OBJECT (
    id_evento          NUMBER(12),
    nome_cliente       VARCHAR2(100),
    nome_servico       VARCHAR2(120),
    nome_dispositivo   VARCHAR2(80),
    quantidade         NUMBER(9, 2),
    valor_unitario     NUMBER(9, 2),
    valor_total        NUMBER(9, 2),
    data_evento        DATE,
    origem             VARCHAR2(20)
);
/

CREATE OR REPLACE TYPE tabela_relatorio_venda_evento AS TABLE OF tipo_relatorio_venda_evento;
/

CREATE OR REPLACE FUNCTION fn_relatorio_venda_evento
RETURN tabela_relatorio_venda_evento PIPELINED IS
    CURSOR c_vendas IS
        SELECT 
            ve.id_evento,
            c.nome_cliente,
            s.nome_servico,
            d.nome_dispos AS nome_dispositivo,
            ve.quantidade,
            ve.valor_unitario,
            ve.valor_total,
            ve.dt_evento AS data_evento,
            ve.origem
        FROM venda_evento ve
        INNER JOIN cliente c ON ve.cliente_id_cliente = c.id_cliente
        INNER JOIN servico s ON ve.servico_id_servico = s.id_servico
        INNER JOIN dispositivo_iot d ON ve.dispos_iot_id_dispos = d.id_dispos
        ORDER BY ve.dt_evento DESC;
    
    v_registro tipo_relatorio_venda_evento;
BEGIN
    FOR v_linha IN c_vendas LOOP
        v_registro := tipo_relatorio_venda_evento(
            v_linha.id_evento,
            v_linha.nome_cliente,
            v_linha.nome_servico,
            v_linha.nome_dispositivo,
            v_linha.quantidade,
            v_linha.valor_unitario,
            v_linha.valor_total,
            v_linha.data_evento,
            v_linha.origem
        );
        PIPE ROW(v_registro);
    END LOOP;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao gerar relatório: ' || SQLERRM);
END;
/


-- Função com Regra de Negócio Financeira (Agregações por Centro de Custo)
CREATE OR REPLACE TYPE tipo_relatorio_financeiro AS OBJECT (
    id_centro_custo    NUMBER(4),
    nome_centro_custo  VARCHAR2(70),
    tipo_conta         CHAR(1),
    nome_conta         VARCHAR2(70),
    quantidade_registros NUMBER,
    valor_total        NUMBER(12, 2),
    valor_medio        NUMBER(12, 2),
    data_ultimo_registro DATE
);
/

CREATE OR REPLACE TYPE tabela_relatorio_financeiro AS TABLE OF tipo_relatorio_financeiro;
/

CREATE OR REPLACE FUNCTION fn_relatorio_financeiro_centro_custo
RETURN tabela_relatorio_financeiro PIPELINED IS
    CURSOR c_financeiro IS
        SELECT 
            cc.id_centro_custo,
            cc.nome_centro_custo,
            ct.tipo AS tipo_conta,
            ct.nome_conta_contabil AS nome_conta,
            COUNT(rc.id_reg_cont) AS quantidade_registros,
            SUM(rc.valor) AS valor_total,
            ROUND(AVG(rc.valor), 2) AS valor_medio,
            MAX(rc.data_criacao) AS data_ultimo_registro
        FROM reg_cont rc
        INNER JOIN centro_custo cc ON rc.centro_custo_id_centro_custo = cc.id_centro_custo
        INNER JOIN conta_contabil ct ON rc.conta_contabil_id_conta = ct.id_conta
        GROUP BY 
            cc.id_centro_custo,
            cc.nome_centro_custo,
            ct.tipo,
            ct.nome_conta_contabil
        ORDER BY SUM(rc.valor) DESC;
    
    v_registro tipo_relatorio_financeiro;
BEGIN
    FOR v_linha IN c_financeiro LOOP
        v_registro := tipo_relatorio_financeiro(
            v_linha.id_centro_custo,
            v_linha.nome_centro_custo,
            v_linha.tipo_conta,
            v_linha.nome_conta,
            v_linha.quantidade_registros,
            v_linha.valor_total,
            v_linha.valor_medio,
            v_linha.data_ultimo_registro
        );
        PIPE ROW(v_registro);
    END LOOP;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro ao gerar relatório financeiro: ' || SQLERRM);
END;
/


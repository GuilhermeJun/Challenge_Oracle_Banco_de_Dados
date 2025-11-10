--RM     Nome
--567164 Édipo Borges de Carvalho
--559986 Guilherme Jun Conheci
--560088 Igor Neris Soaress Alves

DROP TABLE centro_custo CASCADE CONSTRAINTS;
DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE conta_contabil CASCADE CONSTRAINTS;
DROP TABLE dispositivo_iot CASCADE CONSTRAINTS;
DROP TABLE reg_cont CASCADE CONSTRAINTS;
DROP TABLE servico CASCADE CONSTRAINTS;
DROP TABLE venda_evento CASCADE CONSTRAINTS;
DROP TABLE vendas CASCADE CONSTRAINTS;

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
    ativo         CHAR(1) DEFAULT 'S' NOT NULL
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

DECLARE
    v_result VARCHAR2(200);
BEGIN
    v_result := fn_valida_cliente('TechIoT Ltda', 12345678000199, 'contato@techiot.com');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;


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

    IF v_cliente_ativo != 'S' THEN
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

DECLARE
    v_msg VARCHAR2(200);
BEGIN
    v_msg := fn_valida_venda_evento(101, 10, 5001, 2, 199.90, 399.80);
    DBMS_OUTPUT.PUT_LINE(v_msg);
END;


--Procedures para Operações CRUD

--INSERT
CREATE OR REPLACE PROCEDURE prc_ins_cliente IS
    v_id_cliente   cliente.id_cliente%TYPE := &ID_CLIENTE;
    v_nome_cliente cliente.nome_cliente%TYPE := '&NOME_CLIENTE';
    v_cnpj         cliente.cnpj%TYPE := &CNPJ;
    v_email        cliente.email%TYPE := '&EMAIL';
    v_senha        cliente.senha%TYPE := '&SENHA';
    v_ativo        cliente.ativo%TYPE := '&ATIVO';
    v_msg_validacao VARCHAR2(200);
BEGIN
    -- Validação com a função
    v_msg_validacao := fn_valida_cliente(v_nome_cliente, v_cnpj, v_email);

    IF v_msg_validacao != 'OK' THEN
        DBMS_OUTPUT.PUT_LINE(v_msg_validacao);
    END IF;

    -- Inserção
    INSERT INTO cliente (
        id_cliente,
        nome_cliente,
        cnpj,
        email,
        senha,
        data_cadastro,
        ativo
    ) VALUES (
        v_id_cliente,
        v_nome_cliente,
        v_cnpj,
        v_email,
        v_senha,
        v_ativo
    );
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('✅ Cliente inserido com sucesso: ' || v_nome_cliente);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erro: Cliente já cadastrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erro inesperado: ' || SQLERRM);
        ROLLBACK;
END;


--UPDATE






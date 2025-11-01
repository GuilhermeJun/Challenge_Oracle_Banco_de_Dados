DROP TABLE centro_custo CASCADE CONSTRAINTS;
DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE conta CASCADE CONSTRAINTS;
DROP TABLE reg_cont CASCADE CONSTRAINTS;
DROP TABLE vendas CASCADE CONSTRAINTS;

CREATE TABLE centro_custo (
    id_centro_custo   NUMBER(4) NOT NULL,
    nome_centro_custo VARCHAR2(70) NOT NULL
);

ALTER TABLE centro_custo ADD CONSTRAINT centro_custo_pk PRIMARY KEY ( id_centro_custo );

CREATE TABLE cliente (
    id_cliente    NUMBER(5) NOT NULL,
    nome_cliente  VARCHAR2(100) NOT NULL,
    data_cadastro DATE NOT NULL,
    cpf_cnpj      VARCHAR2(14) NOT NULL,
    email         VARCHAR2(100) NOT NULL,
    senha         VARCHAR2(100) NOT NULL,
    ativo         CHAR(1) NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE conta (
    id_conta           NUMBER(4) NOT NULL,
    nome_conta         VARCHAR2(70) NOT NULL,
    tipo               CHAR(1) NOT NULL,
    cliente_id_cliente NUMBER(5) NOT NULL
);

ALTER TABLE conta ADD CONSTRAINT conta_pk PRIMARY KEY ( id_conta );

CREATE TABLE reg_cont (
    id_reg_cont                  NUMBER(4) NOT NULL,
    valor                        NUMBER(9, 2) NOT NULL,
    conta_id_conta               NUMBER(4) NOT NULL,
    centro_custo_id_centro_custo NUMBER(4) NOT NULL,
    data_criacao                 DATE,
    data_atualizacao             DATE
);

ALTER TABLE reg_cont ADD CONSTRAINT reg_cont_pk PRIMARY KEY ( id_reg_cont );

CREATE TABLE vendas (
    id_vendas            NUMBER(9) NOT NULL,
    reg_cont_id_reg_cont NUMBER(4) NOT NULL,
    cliente_id_cliente   NUMBER(5) NOT NULL
);

ALTER TABLE vendas ADD CONSTRAINT vendas_pk PRIMARY KEY ( id_vendas );

ALTER TABLE conta
    ADD CONSTRAINT conta_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE reg_cont
    ADD CONSTRAINT reg_cont_centro_custo_fk FOREIGN KEY ( centro_custo_id_centro_custo )
        REFERENCES centro_custo ( id_centro_custo );

ALTER TABLE reg_cont
    ADD CONSTRAINT reg_cont_conta_fk FOREIGN KEY ( conta_id_conta )
        REFERENCES conta ( id_conta );

ALTER TABLE vendas
    ADD CONSTRAINT vendas_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE vendas
    ADD CONSTRAINT vendas_reg_cont_fk FOREIGN KEY ( reg_cont_id_reg_cont )
        REFERENCES reg_cont ( id_reg_cont );

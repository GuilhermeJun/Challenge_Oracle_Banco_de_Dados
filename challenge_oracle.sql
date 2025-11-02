-- Gerado por Oracle SQL Developer Data Modeler 24.3.0.240.1210
--   em:        2025-11-01 22:02:10 BRT
--   site:      Oracle Database 12c
--   tipo:      Oracle Database 12c




CREATE OR REPLACE PROCEDURE pr_setup_defaults AS
    v_exists NUMBER;
BEGIN
  -- Cliente genérico
    SELECT
        COUNT(*)
    INTO v_exists
    FROM
        cliente
    WHERE
        id_cliente = 99999;

    IF v_exists = 0 THEN
        INSERT INTO cliente (
            id_cliente,
            nome_cliente,
            cpf_cnpj,
            email,
            senha,
            ativo
        ) VALUES ( 99999,
                   'CLIENTE GENERICO',
                   '00000000000000',
                   'generico@example.com',
                   '***',
                   'S' );

    END IF;

  -- Centro de custo padrão
    SELECT
        COUNT(*)
    INTO v_exists
    FROM
        centro_custo
    WHERE
        id_centro_custo = 1001;

    IF v_exists = 0 THEN
        INSERT INTO centro_custo (
            id_centro_custo,
            nome_centro_custo
        ) VALUES ( 1001,
                   'OPERACIONAL PADRAO' );

    END IF;

  -- Conta de receita padrão (tipo R) em CONTA_CONTABIL
    SELECT
        COUNT(*)
    INTO v_exists
    FROM
        conta_contabil
    WHERE
        id_conta_contabil = 1001;

    IF v_exists = 0 THEN
        INSERT INTO conta_contabil (
            id_conta_contabil,
            nome_conta_contabil,
            tipo,
            cliente_id_cliente
        ) VALUES ( 1001,
                   'RECEITA SERVICOS PADRAO',
                   'R',
                   NULL );

    END IF;

END;
/
ALTER TABLE centro_custo;
ALTER TABLE cliente;
ALTER TABLE conta_contabil;
ALTER TABLE dispositivo_iot;
ALTER TABLE reg_cont;
ALTER TABLE servico;
ALTER TABLE venda_evento;
ALTER TABLE vendas;
ALTER TABLE cliente DROP CONSTRAINT cliente_chk_ativo;

ALTER TABLE cliente
    ADD CONSTRAINT cliente_chk_ativo CHECK ( ativo IN ( 'S', 'N' ) );
ALTER TABLE conta_contabil DROP CONSTRAINT conta_chk_tipo;

ALTER TABLE conta_contabil
    ADD CONSTRAINT conta_chk_tipo CHECK ( tipo IN ( 'R', 'D' ) );
ALTER TABLE dispositivo_iot
    ADD CONSTRAINT dispositivo_iot_chk_ativo CHECK ( ativo IN ( 'S', 'N' ) );
ALTER TABLE servico
    ADD CONSTRAINT servico_chk_ativo CHECK ( ativo IN ( 'S', 'N' ) );
CREATE OR REPLACE TRIGGER trg_venda_evento_ai AFTER
    INSERT ON venda_evento
    FOR EACH ROW
DECLARE
    v_servico_id   servico.id_servico%TYPE;
    v_preco_padrao servico.preco_padrao%TYPE := 0;
    v_qtd          NUMBER := 1;
    v_unit         NUMBER := 0;
    v_total        NUMBER := 0;
    v_cliente      cliente.id_cliente%TYPE;
    v_reg_cont_id  reg_cont.id_reg_cont%TYPE;
    v_venda_id     vendas.id_vendas%TYPE;
BEGIN
  -- Resolver serviço a partir de ID ou código
    v_servico_id := :new.servico_id_servico;
    IF
        v_servico_id IS NULL
        AND :new.servico_codigo IS NOT NULL
    THEN
        BEGIN
            SELECT
                id_servico
            INTO v_servico_id
            FROM
                servico
            WHERE
                upper(codigo) = upper(:new.servico_codigo);

        EXCEPTION
            WHEN no_data_found THEN
                v_servico_id := NULL;
        END;

    END IF;

    IF v_servico_id IS NOT NULL THEN
        SELECT
            nvl(preco_padrao, 0)
        INTO v_preco_padrao
        FROM
            servico
        WHERE
            id_servico = v_servico_id;

    END IF;

    v_qtd := nvl(:new.quantidade,
                 1);
    v_unit := nvl(:new.valor_unitario,
                  v_preco_padrao);
    v_total := nvl(:new.valor_total,
                   v_qtd * v_unit);

  -- Cliente default se não vier no evento
    v_cliente := nvl(:new.cliente_id_cliente,
                     99999);

  -- REG_CONT (receita) com conta/centro padrão 1001
    v_reg_cont_id := reg_cont_seq.nextval;
    INSERT INTO reg_cont (
        id_reg_cont,
        valor,
        conta_id_conta,
        centro_custo_id_centro_custo
    ) VALUES ( v_reg_cont_id,
               nvl(v_total, 0),
               1001,
               1001 );

  -- VENDAS vinculada ao REG_CONT e ao cliente + referência ao evento
    v_venda_id := vendas_seq.nextval;
    INSERT INTO vendas (
        id_vendas,
        cliente_id_cliente,
        reg_cont_id_reg_cont,
        venda_evento_id_evento
    ) VALUES ( v_venda_id,
               v_cliente,
               v_reg_cont_id,
               :new.id_evento );

  -- Atualiza o evento com o ID da venda gerada (uma-a-uma opcional)
    UPDATE venda_evento
    SET
        vendas_id_vendas = v_venda_id
    WHERE
        id_evento = :new.id_evento;

END;
/
CREATE OR REPLACE TRIGGER trg_vendas_ai_ensure_regcont AFTER
    INSERT ON vendas
    FOR EACH ROW
DECLARE
    v_reg_cont_id reg_cont.id_reg_cont%TYPE;
BEGIN
    IF :new.reg_cont_id_reg_cont IS NULL THEN
        v_reg_cont_id := reg_cont_seq.nextval;
        INSERT INTO reg_cont (
            id_reg_cont,
            valor,
            conta_id_conta,
            centro_custo_id_centro_custo
        ) VALUES ( v_reg_cont_id,
                   0,
                   1001,
                   1001 );

        UPDATE vendas
        SET
            reg_cont_id_reg_cont = v_reg_cont_id
        WHERE
            id_vendas = :new.id_vendas;

    END IF;
END;
/
ALTER TABLE venda_evento RENAME CONSTRAINT venda_evento_dispositivo_iot_fk TO venda_evento_dispositivo_fk;

-- Relatório do Resumo do Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             0
-- CREATE INDEX                             0
-- CREATE VIEW                              0
-- ALTER TABLE                             15
-- ALTER INDEX                              0
-- ALTER VIEW                               0
-- DROP TABLE                               0
-- DROP INDEX                               0
-- DROP VIEW                                0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         1
-- CREATE FUNCTION                          0
-- DROP PACKAGE                             0
-- DROP PACKAGE BODY                        0
-- DROP PROCEDURE                           0
-- DROP FUNCTION                            0
-- CREATE TRIGGER                           2
-- ALTER TRIGGER                            0
-- DROP TRIGGER                             0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- DROP TYPE                                0
-- CREATE SEQUENCE                          0
-- ALTER SEQUENCE                           0
-- DROP SEQUENCE                            0
-- CREATE MATERIALIZED VIEW                 0
-- DROP MATERIALIZED VIEW                   0
-- CREATE SYNONYM                           0
-- DROP SYNONYM                             0
-- CREATE DIMENSION                         0
-- DROP DIMENSION                           0
-- CREATE CONTEXT                           0
-- DROP CONTEXT                             0
-- CREATE DIRECTORY                         0
-- DROP DIRECTORY                           0

-- 
-- ERRORS                                   0
-- WARNINGS                                 0

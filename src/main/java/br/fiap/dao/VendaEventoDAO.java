package br.fiap.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;

/**
 * DAO para operações CRUD na tabela VENDA_EVENTO
 * Utiliza procedures Oracle para INSERT, UPDATE e DELETE
 */
@Repository
public class VendaEventoDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Insere um novo evento de venda usando a procedure prc_ins_venda_evento
     */
    public String inserirVendaEvento(Long idEvento, Integer disposId, Integer servicoId, 
                                     Integer clienteId, Double quantidade, 
                                     Double valorUnitario, Double valorTotal) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_ins_venda_evento(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }"
            );
            cs.setLong(1, idEvento);
            cs.setInt(2, disposId);
            cs.setInt(3, servicoId);
            cs.setInt(4, clienteId);
            cs.setDouble(5, quantidade);
            cs.setDouble(6, valorUnitario);
            cs.setDouble(7, valorTotal);
            cs.setNull(8, Types.VARCHAR); // p_uid_tag (opcional)
            cs.setNull(9, Types.NUMERIC); // p_operador_id (opcional)
            cs.setString(10, "RFID"); // p_origem (default 'RFID')
            cs.registerOutParameter(11, Types.VARCHAR); // p_resultado
            cs.execute();
            return cs.getString(11);
        });
    }

    /**
     * Atualiza um evento de venda usando a procedure prc_upd_venda_evento
     */
    public String atualizarVendaEvento(Long idEvento, Integer disposId, Integer servicoId, 
                                       Integer clienteId, Double quantidade, 
                                       Double valorUnitario, Double valorTotal) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_upd_venda_evento(?, ?, ?, ?, ?, ?, ?, ?) }"
            );
            cs.setLong(1, idEvento);
            cs.setInt(2, disposId);
            cs.setInt(3, servicoId);
            cs.setInt(4, clienteId);
            cs.setDouble(5, quantidade);
            cs.setDouble(6, valorUnitario);
            cs.setDouble(7, valorTotal);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.execute();
            return cs.getString(8);
        });
    }

    /**
     * Exclui um evento de venda usando a procedure prc_del_venda_evento
     */
    public String excluirVendaEvento(Long idEvento) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_del_venda_evento(?, ?) }"
            );
            cs.setLong(1, idEvento);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();
            return cs.getString(2);
        });
    }
}


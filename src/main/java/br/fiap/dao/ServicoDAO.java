package br.fiap.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;

/**
 * DAO para operações CRUD na tabela SERVICO
 * Utiliza procedures Oracle para INSERT, UPDATE e DELETE
 */
@Repository
public class ServicoDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Insere um novo serviço usando a procedure prc_ins_servico
     */
    public String inserirServico(Integer idServico, String codigoServico, 
                                 String nomeServico, Double precoPadrao, String ativo) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_ins_servico(?, ?, ?, ?, ?, ?) }"
            );
            cs.setInt(1, idServico);
            cs.setString(2, codigoServico);
            cs.setString(3, nomeServico);
            cs.setDouble(4, precoPadrao);
            cs.setString(5, ativo);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.execute();
            return cs.getString(6);
        });
    }

    /**
     * Atualiza um serviço usando a procedure prc_upd_servico
     */
    public String atualizarServico(Integer idServico, String codigoServico, 
                                   String nomeServico, Double precoPadrao, String ativo) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_upd_servico(?, ?, ?, ?, ?, ?) }"
            );
            cs.setInt(1, idServico);
            cs.setString(2, codigoServico);
            cs.setString(3, nomeServico);
            cs.setDouble(4, precoPadrao);
            cs.setString(5, ativo);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.execute();
            return cs.getString(6);
        });
    }

    /**
     * Exclui um serviço usando a procedure prc_del_servico
     */
    public String excluirServico(Integer idServico) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_del_servico(?, ?) }"
            );
            cs.setInt(1, idServico);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();
            return cs.getString(2);
        });
    }
}


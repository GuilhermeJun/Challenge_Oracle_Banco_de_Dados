package br.fiap.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;

/**
 * DAO para operações CRUD na tabela CLIENTE
 * Utiliza procedures Oracle para INSERT, UPDATE e DELETE
 */
@Repository
public class ClienteDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Insere um novo cliente usando a procedure prc_ins_cliente
     */
    public String inserirCliente(Integer idCliente, String nomeCliente, Long cnpj, 
                                  String email, String senha, String ativo) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_ins_cliente(?, ?, ?, ?, ?, ?, ?) }"
            );
            cs.setInt(1, idCliente);
            cs.setString(2, nomeCliente);
            cs.setLong(3, cnpj);
            cs.setString(4, email);
            cs.setString(5, senha);
            cs.setString(6, ativo);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();
            return cs.getString(7);
        });
    }

    /**
     * Atualiza um cliente existente usando a procedure prc_upd_cliente
     */
    public String atualizarCliente(Integer idCliente, String nomeCliente, Long cnpj, 
                                    String email, String senha, String ativo) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_upd_cliente(?, ?, ?, ?, ?, ?, ?) }"
            );
            cs.setInt(1, idCliente);
            cs.setString(2, nomeCliente);
            cs.setLong(3, cnpj);
            cs.setString(4, email);
            cs.setString(5, senha);
            cs.setString(6, ativo);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();
            return cs.getString(7);
        });
    }

    /**
     * Exclui um cliente usando a procedure prc_del_cliente
     */
    public String excluirCliente(Integer idCliente) {
        return jdbcTemplate.execute((Connection connection) -> {
            CallableStatement cs = connection.prepareCall(
                "{ call prc_del_cliente(?, ?) }"
            );
            cs.setInt(1, idCliente);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();
            return cs.getString(2);
        });
    }
}


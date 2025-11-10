package br.fiap.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import javax.sql.DataSource;

/**
 * Configuração do Oracle Database
 * Configura o DataSource e JdbcTemplate para acesso ao banco de dados
 */
@Configuration
public class OracleConfig {

    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}


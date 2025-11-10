package br.fiap.service;

import br.fiap.dao.ClienteDAO;
import br.fiap.dao.VendaEventoDAO;
import br.fiap.dao.ServicoDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Service para demonstração das procedures CRUD
 * Executa 2 INSERTs, 2 UPDATEs e 2 DELETEs por tabela
 */
@Service
public class ProcedureService {

    @Autowired
    private ClienteDAO clienteDAO;

    @Autowired
    private VendaEventoDAO vendaEventoDAO;

    @Autowired
    private ServicoDAO servicoDAO;

    public void demonstrarProcedures() {
        System.out.println("\n=== DEMONSTRAÇÃO DE PROCEDURES ===\n");

        demonstrarCliente();
        demonstrarServico();
        
        // Criar dados necessários para venda_evento antes de testar
        prepararDadosParaVendaEvento();
        
        demonstrarVendaEvento();
    }
    
    private void prepararDadosParaVendaEvento() {
        System.out.println("--- PREPARANDO DADOS PARA VENDA_EVENTO ---\n");
        
        // Criar cliente para venda_evento
        clienteDAO.inserirCliente(5001, "Cliente Teste Venda", 11111111000111L, 
            "teste@venda.com", "senha123", "A");
        
        // Criar serviço para venda_evento
        servicoDAO.inserirServico(5001, "SERV001", "Serviço Teste", 100.00, "S");
        
        // Nota: dispositivo_iot precisa ser criado manualmente no banco ou via SQL direto
        // Assumindo que existe dispositivo com id=1
        System.out.println("Dados preparados. Assumindo dispositivo_iot id=1 existe no banco.\n");
    }

    private void demonstrarCliente() {
        System.out.println("--- TABELA: CLIENTE ---\n");

        // INSERT 1
        System.out.println("INSERT 1 - Cliente TechIoT");
        String resultado = clienteDAO.inserirCliente(
            1001, "TechIoT Ltda", 12345678000199L, 
            "contato@techiot.com", "senha123", "A"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // INSERT 2
        System.out.println("INSERT 2 - Cliente Inovação");
        resultado = clienteDAO.inserirCliente(
            1002, "Inovação Sistemas SA", 98765432000111L, 
            "contato@inovacao.com", "senha456", "A"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 1
        System.out.println("UPDATE 1 - Atualizar TechIoT");
        resultado = clienteDAO.atualizarCliente(
            1001, "TechIoT Ltda - Atualizado", 12345678000199L, 
            "novoemail@techiot.com", "senha789", "A"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 2
        System.out.println("UPDATE 2 - Desativar Inovação");
        resultado = clienteDAO.atualizarCliente(
            1002, "Inovação Sistemas SA", 98765432000111L, 
            "contato@inovacao.com", "senha456", "I"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 1 - Tentar excluir (pode falhar se houver relacionamentos)
        System.out.println("DELETE 1 - Excluir Cliente 1001");
        resultado = clienteDAO.excluirCliente(1001);
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 2 - Tentar excluir (pode falhar se houver relacionamentos)
        System.out.println("DELETE 2 - Excluir Cliente 1002");
        resultado = clienteDAO.excluirCliente(1002);
        System.out.println("Resultado: " + resultado + "\n");
    }

    private void demonstrarServico() {
        System.out.println("--- TABELA: SERVICO ---\n");

        // INSERT 1
        System.out.println("INSERT 1 - Serviço Consultoria");
        String resultado = servicoDAO.inserirServico(
            2001, "CONS001", "Consultoria em TI", 5000.00, "S"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // INSERT 2
        System.out.println("INSERT 2 - Serviço Desenvolvimento");
        resultado = servicoDAO.inserirServico(
            2002, "DEV001", "Desenvolvimento de Software", 8000.00, "S"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 1
        System.out.println("UPDATE 1 - Atualizar Consultoria");
        resultado = servicoDAO.atualizarServico(
            2001, "CONS001", "Consultoria em TI - Premium", 7500.00, "S"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 2
        System.out.println("UPDATE 2 - Desativar Desenvolvimento");
        resultado = servicoDAO.atualizarServico(
            2002, "DEV001", "Desenvolvimento de Software", 8000.00, "N"
        );
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 1 - Tentar excluir (pode falhar se houver relacionamentos)
        System.out.println("DELETE 1 - Excluir Serviço 2001");
        resultado = servicoDAO.excluirServico(2001);
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 2 - Tentar excluir (pode falhar se houver relacionamentos)
        System.out.println("DELETE 2 - Excluir Serviço 2002");
        resultado = servicoDAO.excluirServico(2002);
        System.out.println("Resultado: " + resultado + "\n");
    }

    private void demonstrarVendaEvento() {
        System.out.println("--- TABELA: VENDA_EVENTO ---\n");

        // Usando dados criados: dispositivo_iot (id=1), servico (id=5001), cliente (id=5001)
        // Nota: dispositivo_iot id=1 precisa existir no banco

        // INSERT 1
        System.out.println("INSERT 1 - Evento de Venda 1");
        String resultado = vendaEventoDAO.inserirVendaEvento(
            3001L, 1, 5001, 5001, 2.0, 100.00, 200.00
        );
        System.out.println("Resultado: " + resultado + "\n");

        // INSERT 2
        System.out.println("INSERT 2 - Evento de Venda 2");
        resultado = vendaEventoDAO.inserirVendaEvento(
            3002L, 1, 5001, 5001, 3.0, 150.00, 450.00
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 1
        System.out.println("UPDATE 1 - Atualizar Evento 3001");
        resultado = vendaEventoDAO.atualizarVendaEvento(
            3001L, 1, 5001, 5001, 2.5, 120.00, 300.00
        );
        System.out.println("Resultado: " + resultado + "\n");

        // UPDATE 2
        System.out.println("UPDATE 2 - Atualizar Evento 3002");
        resultado = vendaEventoDAO.atualizarVendaEvento(
            3002L, 1, 5001, 5001, 4.0, 150.00, 600.00
        );
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 1
        System.out.println("DELETE 1 - Excluir Evento 3001");
        resultado = vendaEventoDAO.excluirVendaEvento(3001L);
        System.out.println("Resultado: " + resultado + "\n");

        // DELETE 2
        System.out.println("DELETE 2 - Excluir Evento 3002");
        resultado = vendaEventoDAO.excluirVendaEvento(3002L);
        System.out.println("Resultado: " + resultado + "\n");
    }
}


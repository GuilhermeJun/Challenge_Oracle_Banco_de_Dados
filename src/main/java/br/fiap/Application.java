package br.fiap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Autowired;
import br.fiap.service.ProcedureService;

/**
 * Aplicação Spring Boot para demonstração das procedures Oracle
 * 
 * @author RM560088 - Igor Neris Soares Alves
 */
@SpringBootApplication
public class Application implements CommandLineRunner {

    @Autowired
    private ProcedureService procedureService;

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("\n==========================================");
        System.out.println("  DEMONSTRAÇÃO DE PROCEDURES ORACLE");
        System.out.println("==========================================\n");
        
        procedureService.demonstrarProcedures();
        
        System.out.println("\n==========================================");
        System.out.println("  DEMONSTRAÇÃO CONCLUÍDA");
        System.out.println("==========================================\n");
    }
}


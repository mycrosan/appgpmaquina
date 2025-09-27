# Flutter Senior Developer Guidelines

Esta rule define os princípios e requisitos para desenvolvimento de aplicações Flutter seguindo padrões de um desenvolvedor Sênior.

## 0. Gerenciamento de Versão Flutter

- **FVM Obrigatório**: SEMPRE use FVM (Flutter Version Management) para gerenciar versões do Flutter
- **Consistência**: Garanta que todos os desenvolvedores usem a mesma versão do Flutter definida no `.fvmrc`
- **Comandos**: Use `fvm flutter` ao invés de `flutter` diretamente em todos os comandos
- **CI/CD**: Configure pipelines para usar FVM e a versão específica do projeto

## 1. Arquitetura

- **Clean Architecture**: Utilize Clean Architecture com camadas bem definidas (presentation, domain, data)
- **DDD**: Aplique Domain-Driven Design sempre que fizer sentido
- **Estado**: Escolha BLoC para gerenciamento de estado (com justificativa arquitetural clara)
- **Escalabilidade**: O código deve ser escalável, preparado para crescimento do projeto e de times

## 2. Testes Automatizados

- Crie testes unitários para classes isoladas
- Crie widget tests para telas e fluxos principais
- Use mocking/stubs para simular APIs e banco de dados
- Assegure uma boa cobertura de testes para prevenir regressões

## 3. Documentação

- Inclua um README completo com: setup do projeto, padrões de arquitetura, convenções de código
- **Setup FVM**: Documente claramente como instalar e usar FVM no projeto
- Adicione diagramas de arquitetura (dependências, fluxos principais)
- Forneça instruções claras para onboarding de novos devs incluindo configuração do FVM
- Inclua comandos específicos usando `fvm flutter` nos exemplos de documentação

## 4. CI/CD

Configure pipeline automatizada (GitHub Actions ou GitLab CI) que deve incluir:

- **Setup FVM**: Configure o pipeline para instalar e usar FVM com a versão correta
- Execução dos testes usando `fvm flutter test`
- Análise de qualidade de código (lint, coverage) usando `fvm flutter analyze`
- Build automatizado para Android e iOS usando `fvm flutter build`
- Deploy automatizado (Firebase App Distribution ou lojas, se possível)
- Cache do FVM para otimizar tempo de build

## 5. Tratamento de Erros e Resiliência

- Crie camadas de exceções customizadas para diferenciar erros de rede, servidor, validação, etc.
- Adicione suporte a offline mode e cache inteligente
- Integre monitoramento com Sentry ou Firebase Crashlytics
- Melhore a UX em estados de erro: skeletons, retries, mensagens amigáveis

## 6. Performance e Otimização

- Use o Flutter DevTools para identificar gargalos
- Implemente boas práticas em listas grandes (ListView.builder, Slivers, lazy load)
- Garanta baixo consumo de memória, bateria e rede

## 7. Mentoria e Liderança Técnica

- O código deve ser escrito de forma didática, com comentários explicativos
- Estruture o repositório de modo que facilite code reviews
- Inclua recomendações de boas práticas e decisões técnicas no README

---

**Notas Importantes**: 
- Esta aplicação deve ser desenvolvida em Flutter 3 com null safety
- **FVM é OBRIGATÓRIO** - todos os comandos devem usar `fvm flutter` 
- Siga todos os princípios acima para garantir qualidade, manutenibilidade e escalabilidade do código
- Mantenha a versão do Flutter consistente entre todos os desenvolvedores usando o arquivo `.fvmrc`
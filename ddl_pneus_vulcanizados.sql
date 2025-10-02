-- DDL para tabela de pneus vulcanizados
-- Sistema de controle de vulcanização de pneus

CREATE TABLE pneus_vulcanizados (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
    -- Identificação do pneu
    numero_etiqueta VARCHAR(20) NOT NULL UNIQUE,
    codigo_carcaca VARCHAR(50),
    
    -- Dados do processo de vulcanização
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME,
    tempo_vulcanizacao_segundos INT NOT NULL,
    tempo_real_vulcanizacao_segundos INT,
    
    -- Status do processo
    status_processo ENUM('EM_ANDAMENTO', 'FINALIZADO', 'CANCELADO', 'ERRO') NOT NULL DEFAULT 'EM_ANDAMENTO',
    sucesso BOOLEAN DEFAULT NULL,
    
    -- Dados da máquina/equipamento
    ip_sonoff VARCHAR(15),
    porta_sonoff INT DEFAULT 8081,
    
    -- Controle de qualidade
    temperatura_inicial DECIMAL(5,2),
    temperatura_final DECIMAL(5,2),
    pressao_inicial DECIMAL(8,2),
    pressao_final DECIMAL(8,2),
    
    -- Dados do operador
    operador_id BIGINT,
    operador_nome VARCHAR(100),
    
    -- Observações e logs
    observacoes TEXT,
    log_erros TEXT,
    
    -- Auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Índices para performance
    INDEX idx_numero_etiqueta (numero_etiqueta),
    INDEX idx_data_inicio (data_inicio),
    INDEX idx_status_processo (status_processo),
    INDEX idx_operador_id (operador_id),
    INDEX idx_created_at (created_at)
);

-- Tabela para histórico de eventos do processo
CREATE TABLE pneus_vulcanizados_eventos (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pneu_vulcanizado_id BIGINT NOT NULL,
    
    -- Tipo de evento
    tipo_evento ENUM(
        'INICIO_PROCESSO',
        'RELE_LIGADO', 
        'RELE_DESLIGADO',
        'TIMER_ATUALIZADO',
        'PROCESSO_PAUSADO',
        'PROCESSO_RETOMADO',
        'PROCESSO_FINALIZADO',
        'PROCESSO_CANCELADO',
        'ERRO_COMUNICACAO',
        'ERRO_SISTEMA'
    ) NOT NULL,
    
    -- Dados do evento
    descricao TEXT,
    dados_json JSON,
    timestamp_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Referência ao pneu vulcanizado
    FOREIGN KEY (pneu_vulcanizado_id) REFERENCES pneus_vulcanizados(id) ON DELETE CASCADE,
    
    -- Índices
    INDEX idx_pneu_vulcanizado_id (pneu_vulcanizado_id),
    INDEX idx_tipo_evento (tipo_evento),
    INDEX idx_timestamp_evento (timestamp_evento)
);
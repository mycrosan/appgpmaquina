import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/configuracao_maquina.dart';
import '../bloc/configuracao_maquina_bloc.dart';
import '../bloc/configuracao_maquina_state.dart';

class ConfiguracaoListWidget extends StatelessWidget {
  final Function(ConfiguracaoMaquina) onEdit;
  final Function(ConfiguracaoMaquina) onDelete;
  final Function(int) onPageChanged;
  final int currentPage;

  const ConfiguracaoListWidget({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onPageChanged,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfiguracaoMaquinaBloc, ConfiguracaoMaquinaState>(
      builder: (context, state) {
        developer.log('🔄 Construindo lista - Estado: ${state.runtimeType}', name: 'ConfiguracaoListWidget');

        if (state is ConfiguracaoMaquinaLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando configurações...'),
              ],
            ),
          );
        }

        if (state is ConfiguracaoMaquinaError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar configurações',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    developer.log('🔄 Usuário solicitou recarregar após erro', name: 'ConfiguracaoListWidget');
                    // Trigger reload by calling parent
                    onPageChanged(currentPage);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ConfiguracoesMaquinaLoaded) {
          developer.log('📋 Exibindo ${state.configuracoes.length} configurações', name: 'ConfiguracaoListWidget');
          
          if (state.configuracoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma configuração encontrada',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione uma nova configuração para começar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Lista de configurações
              Expanded(
                child: ListView.builder(
                  itemCount: state.configuracoes.length,
                  itemBuilder: (context, index) {
                    final configuracao = state.configuracoes[index];
                    return _ConfiguracaoCard(
                      configuracao: configuracao,
                      onEdit: () => onEdit(configuracao),
                      onDelete: () => onDelete(configuracao),
                    );
                  },
                ),
              ),
              
              // Paginação
              if (state.totalPages > 1)
                _PaginationWidget(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  totalElements: state.totalElements,
                  onPageChanged: onPageChanged,
                ),
            ],
          );
        }

        // Estado inicial ou outros estados
        return const Center(
          child: Text('Carregue as configurações para visualizar'),
        );
      },
    );
  }
}

class _ConfiguracaoCard extends StatelessWidget {
  final ConfiguracaoMaquina configuracao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ConfiguracaoCard({
    required this.configuracao,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com chave e status
            Row(
              children: [
                Expanded(
                  child: Text(
                    configuracao.chaveConfiguracao,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: configuracao.ativo 
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: configuracao.ativo 
                          ? AppColors.success
                          : AppColors.textSecondary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    configuracao.ativo ? 'ATIVO' : 'INATIVO',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: configuracao.ativo 
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Valor da configuração
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                configuracao.valorConfiguracao,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Descrição (se houver)
            if (configuracao.descricao != null && configuracao.descricao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                configuracao.descricao!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // Informações adicionais
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Tipo: ${configuracao.tipoValor}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (configuracao.obrigatorio) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Obrigatório',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Ações
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Excluir'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final Function(int) onPageChanged;

  const _PaginationWidget({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Informações da paginação
          Text(
            'Página ${currentPage + 1} de $totalPages ($totalElements itens)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Controles de paginação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primeira página
              IconButton(
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'Primeira página',
              ),

              // Página anterior
              IconButton(
                onPressed: currentPage > 0 
                    ? () => onPageChanged(currentPage - 1) 
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
              ),

              // Páginas numeradas (mostra até 5 páginas)
              ..._buildPageNumbers(),

              // Próxima página
              IconButton(
                onPressed: currentPage < totalPages - 1 
                    ? () => onPageChanged(currentPage + 1) 
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Próxima página',
              ),

              // Última página
              IconButton(
                onPressed: currentPage < totalPages - 1 
                    ? () => onPageChanged(totalPages - 1) 
                    : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    int start = (currentPage - 2).clamp(0, totalPages - 1);
    int end = (start + 4).clamp(0, totalPages - 1);

    if (end - start < 4) {
      start = (end - 4).clamp(0, totalPages - 1);
    }

    for (int i = start; i <= end; i++) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: i == currentPage ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () => onPageChanged(i),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: i == currentPage 
                        ? AppColors.textOnPrimary 
                        : AppColors.textPrimary,
                    fontWeight: i == currentPage 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pages;
  }
}
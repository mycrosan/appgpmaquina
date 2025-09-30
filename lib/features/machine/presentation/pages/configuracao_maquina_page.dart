import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/configuracao_maquina.dart';
import '../bloc/configuracao_maquina_bloc.dart';
import '../bloc/configuracao_maquina_event.dart';
import '../bloc/configuracao_maquina_state.dart';
import '../widgets/configuracao_form_widget.dart';
import '../widgets/configuracao_list_widget.dart';

class ConfiguracaoMaquinaPage extends StatefulWidget {
  final int? registroMaquinaId;

  const ConfiguracaoMaquinaPage({
    super.key,
    this.registroMaquinaId,
  });

  @override
  State<ConfiguracaoMaquinaPage> createState() => _ConfiguracaoMaquinaPageState();
}

class _ConfiguracaoMaquinaPageState extends State<ConfiguracaoMaquinaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  bool? _filtroAtivo = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasConfiguracoes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Inicialmente só uma tab
    developer.log('🏗️ Inicializando ConfiguracaoMaquinaPage', name: 'ConfiguracaoMaquinaUI');
    developer.log('  - Registro Máquina ID: ${widget.registroMaquinaId}', name: 'ConfiguracaoMaquinaUI');
    _loadConfiguracoes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadConfiguracoes() {
    developer.log('🔄 Carregando configurações da máquina', name: 'ConfiguracaoMaquinaUI');
    context.read<ConfiguracaoMaquinaBloc>().add(
      LoadConfiguracoesMaquina(
        registroMaquinaId: widget.registroMaquinaId,
        chaveConfiguracao: _searchQuery,
        ativo: _filtroAtivo,
        page: _currentPage,
        size: _pageSize,
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
      _currentPage = 0;
    });
    _loadConfiguracoes();
  }

  void _onFiltroAtivoChanged(bool? value) {
    setState(() {
      _filtroAtivo = value;
      _currentPage = 0;
    });
    _loadConfiguracoes();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadConfiguracoes();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Configuração'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ConfiguracaoFormWidget(
            registroMaquinaId: widget.registroMaquinaId,
            onSubmit: (configuracao) {
              context.read<ConfiguracaoMaquinaBloc>().add(
                CreateConfiguracaoMaquina(configuracao: configuracao),
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showEditDialog(ConfiguracaoMaquina configuracao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Configuração'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ConfiguracaoFormWidget(
            configuracao: configuracao,
            registroMaquinaId: widget.registroMaquinaId,
            onSubmit: (updatedConfiguracao) {
              context.read<ConfiguracaoMaquinaBloc>().add(
                UpdateConfiguracaoMaquina(
                  id: configuracao.id!,
                  configuracao: updatedConfiguracao,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(ConfiguracaoMaquina configuracao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a configuração "${configuracao.chaveConfiguracao}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ConfiguracaoMaquinaBloc>().add(
                DeleteConfiguracaoMaquina(id: configuracao.id!),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações da Máquina'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          indicatorColor: AppColors.textOnPrimary,
          tabs: _hasConfiguracoes 
            ? const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Configurações',
                ),
              ]
            : const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Configurações',
                ),
                Tab(
                  icon: Icon(Icons.add),
                  text: 'Nova Configuração',
                ),
              ],
        ),
      ),
      body: BlocListener<ConfiguracaoMaquinaBloc, ConfiguracaoMaquinaState>(
        listener: (context, state) {
          developer.log('📡 Estado do BLoC alterado: ${state.runtimeType}', name: 'ConfiguracaoMaquinaUI');

          // Verifica se há configurações carregadas e atualiza o TabController
          if (state is ConfiguracoesMaquinaLoaded) {
            final hasConfiguracoes = state.configuracoes.isNotEmpty;
            if (_hasConfiguracoes != hasConfiguracoes) {
              setState(() {
                _hasConfiguracoes = hasConfiguracoes;
                _tabController.dispose();
                _tabController = TabController(
                  length: _hasConfiguracoes ? 1 : 2, // Se tem configurações, só mostra lista; se não tem, mostra lista + nova
                  vsync: this,
                );
              });
              developer.log('🔄 TabController atualizado - Tem configurações: $_hasConfiguracoes', name: 'ConfiguracaoMaquinaUI');
            }
          }

          if (state is ConfiguracaoMaquinaCreated) {
            developer.log('✅ Configuração criada com sucesso', name: 'ConfiguracaoMaquinaUI');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Configuração criada com sucesso!'),
                  ],
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _loadConfiguracoes();
          } else if (state is ConfiguracaoMaquinaUpdated) {
            developer.log('✅ Configuração atualizada com sucesso', name: 'ConfiguracaoMaquinaUI');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Configuração atualizada com sucesso!'),
                  ],
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _loadConfiguracoes();
          } else if (state is ConfiguracaoMaquinaDeleted) {
            developer.log('✅ Configuração excluída com sucesso', name: 'ConfiguracaoMaquinaUI');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Configuração excluída com sucesso!'),
                  ],
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _loadConfiguracoes();
          } else if (state is ConfiguracaoMaquinaError) {
            developer.log('❌ Erro: ${state.message}', name: 'ConfiguracaoMaquinaUI');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Erro',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.message,
                            style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 6),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: Colors.white,
                  onPressed: () {
                    developer.log('🔄 Usuário solicitou tentar novamente após erro', name: 'ConfiguracaoMaquinaUI');
                    _loadConfiguracoes();
                  },
                ),
              ),
            );
          } else if (state is ConfiguracaoMaquinaValidationError) {
            developer.log('⚠️ Erro de validação: ${state.errors}', name: 'ConfiguracaoMaquinaUI');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Erro de Validação',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...state.errors.entries.map(
                      (entry) => Text(
                        '• ${entry.key}: ${entry.value}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 8),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: _hasConfiguracoes 
            ? [
                // Tab de Listagem (apenas quando há configurações)
                Column(
                  children: [
                    // Filtros
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[50],
                      child: Column(
                        children: [
                          // Campo de busca
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar por chave de configuração',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                          const SizedBox(height: 12),
                          // Filtro de status
                          Row(
                            children: [
                              const Text('Status: '),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Todos'),
                                selected: _filtroAtivo == null,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(null);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Ativo'),
                                selected: _filtroAtivo == true,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(true);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Inativo'),
                                selected: _filtroAtivo == false,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(false);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Lista de configurações
                    Expanded(
                      child: ConfiguracaoListWidget(
                        onEdit: _showEditDialog,
                        onDelete: _showDeleteDialog,
                        onPageChanged: _onPageChanged,
                        currentPage: _currentPage,
                      ),
                    ),
                  ],
                ),
              ]
            : [
                // Tab de Listagem (quando não há configurações)
                Column(
                  children: [
                    // Filtros
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[50],
                      child: Column(
                        children: [
                          // Campo de busca
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar por chave de configuração',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                          const SizedBox(height: 12),
                          // Filtro de status
                          Row(
                            children: [
                              const Text('Status: '),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Todos'),
                                selected: _filtroAtivo == null,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(null);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Ativo'),
                                selected: _filtroAtivo == true,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(true);
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Inativo'),
                                selected: _filtroAtivo == false,
                                onSelected: (selected) {
                                  if (selected) _onFiltroAtivoChanged(false);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Lista de configurações
                    Expanded(
                      child: ConfiguracaoListWidget(
                        onEdit: _showEditDialog,
                        onDelete: _showDeleteDialog,
                        onPageChanged: _onPageChanged,
                        currentPage: _currentPage,
                      ),
                    ),
                  ],
                ),
                // Tab de Criação (apenas quando não há configurações)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConfiguracaoFormWidget(
                    registroMaquinaId: widget.registroMaquinaId,
                    onSubmit: (configuracao) {
                      context.read<ConfiguracaoMaquinaBloc>().add(
                        CreateConfiguracaoMaquina(configuracao: configuracao),
                      );
                    },
                  ),
                ),
              ],
        ),
      ),
      floatingActionButton: (!_hasConfiguracoes && _tabController.index == 0)
          ? FloatingActionButton(
              onPressed: _showCreateDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
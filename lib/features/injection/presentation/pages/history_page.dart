import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/injection_bloc.dart';
import '../../domain/entities/processo_injecao.dart';
import '../widgets/process_history_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../injection_container.dart';
import '../../data/datasources/vulcanizacao_remote_datasource.dart';
import '../../data/models/pneu_vulcanizado_response_dto.dart';

/// Tela de histórico de processos de injeção
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  StatusProcesso? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  // Estado para paginação e busca
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  final int _size = 20;
  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<PneuVulcanizadoResponseDTO> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchFirstPage();
  }

  String? _currentStatusParam() {
    return _selectedStatus == StatusProcesso.concluido
        ? 'FINALIZADO'
        : (_selectedStatus == StatusProcesso.aguardando ||
                _selectedStatus == StatusProcesso.iniciando ||
                _selectedStatus == StatusProcesso.injetando)
            ? 'INICIADO'
            : null;
  }

  Future<void> _fetchFirstPage() async {
    // Mantém o comportamento anterior (processos de injeção) para futuras integrações
    context.read<InjectionBloc>().add(
      InjectionLoadProcessesByStatus(
        status: StatusProcesso.concluido.toString(),
      ),
    );

    setState(() {
      _isLoading = true;
      _page = 0;
      _hasMore = true;
      _items = [];
    });

    try {
      final ds = sl<VulcanizacaoRemoteDataSource>();
      final result = await ds.listarPneusVulcanizados(
        status: _currentStatusParam(),
        numeroEtiqueta: _searchQuery,
        page: _page,
        size: _size,
      );

      setState(() {
        _items = result;
        _hasMore = result.length >= _size;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
      _page += 1;
    });

    try {
      final ds = sl<VulcanizacaoRemoteDataSource>();
      final result = await ds.listarPneusVulcanizados(
        status: _currentStatusParam(),
        numeroEtiqueta: _searchQuery,
        page: _page,
        size: _size,
      );

      setState(() {
        _items.addAll(result);
        _hasMore = result.length >= _size;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mais registros: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Histórico de Processos',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por etiqueta',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = null;
                          });
                          _fetchFirstPage();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.trim().isEmpty ? null : value.trim();
                });
                _fetchFirstPage();
              },
            ),
          ),
          // Filtros ativos
          if (_selectedStatus != null || _startDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceVariant,
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(_getStatusText(_selectedStatus!)),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _fetchFirstPage();
                      },
                    ),
                  if (_startDate != null && _endDate != null)
                    Chip(
                      label: Text(
                        '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _fetchFirstPage();
                      },
                    ),
                ],
              ),
            ),

          // Lista unificada: prioriza pneus vulcanizados da API
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum registro encontrado',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Não há pneus vulcanizados para os filtros selecionados.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchFirstPage,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _items.length) {
                              final item = _items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _VulcanizadoCard(item: item),
                              );
                            }

                            // Rodapé de paginação
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : SizedBox(
                                        width: 180,
                                        child: CustomButton(
                                          text: 'Carregar mais',
                                          onPressed: _loadMore,
                                          variant: ButtonVariant.outlined,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        StatusProcesso? tempStatus = _selectedStatus;
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Filtrar Vulcanização',
                style: AppTextStyles.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro por status
                  Text('Status', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<StatusProcesso>(
                    value: tempStatus,
                    decoration: const InputDecoration(
                      hintText: 'Todos os status',
                      border: OutlineInputBorder(),
                    ),
                    items: StatusProcesso.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Filtro por período
                  Text('Período', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Data inicial',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: tempStartDate != null
                                ? _formatDate(tempStartDate!)
                                : '',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                tempStartDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Data final',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: tempEndDate != null
                                ? _formatDate(tempEndDate!)
                                : '',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: tempStartDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                tempEndDate = date;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _startDate = null;
                      _endDate = null;
                    });
                    Navigator.of(context).pop();
                    _fetchFirstPage();
                  },
                  child: Text(
                    'Limpar',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = tempStatus;
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });
                    Navigator.of(context).pop();
                    _fetchFirstPage();
                  },
                  child: Text(
                    'Aplicar',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getStatusText(StatusProcesso status) {
    switch (status) {
      case StatusProcesso.aguardando:
        return 'Aguardando';
      case StatusProcesso.iniciando:
        return 'Iniciando';
      case StatusProcesso.injetando:
        return 'Em Andamento';
      case StatusProcesso.pausado:
        return 'Pausado';
      case StatusProcesso.cancelado:
        return 'Cancelado';
      case StatusProcesso.concluido:
        return 'Concluído';
      case StatusProcesso.erro:
        return 'Erro';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToProcessDetails(ProcessoInjecao processo) {
    // TODO: Implementar navegação para detalhes do processo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes do processo ${processo.id} em desenvolvimento'),
      ),
    );
  }
}

/// Card simples para exibir dados de um pneu vulcanizado
class _VulcanizadoCard extends StatelessWidget {
  final PneuVulcanizadoResponseDTO item;

  const _VulcanizadoCard({required this.item});

  Color _statusColor() {
    switch (item.status) {
      case StatusPneuVulcanizado.finalizado:
        return AppColors.success;
      case StatusPneuVulcanizado.iniciado:
        return AppColors.warning;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Vulcanizado #${item.id}', style: AppTextStyles.titleSmall),
              const Spacer(),
              Chip(
                label: Text(item.status.value),
                backgroundColor: _statusColor().withOpacity(0.15),
                shape: StadiumBorder(
                  side: BorderSide(color: _statusColor().withOpacity(0.3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Produção',
                  value: item.producaoId.toString(),
                  icon: Icons.precision_manufacturing,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Etiqueta',
                  value: item.numeroEtiqueta ?? '-',
                  icon: Icons.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Operador',
                  value: item.usuarioNome,
                  icon: Icons.person,
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'Iniciado em',
                  value: _formatDateTime(item.dtCreate),
                  icon: Icons.schedule,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'Finalizado em',
                  value: item.dtUpdate != null
                      ? _formatDateTime(item.dtUpdate!)
                      : '-',
                  icon: Icons.update,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

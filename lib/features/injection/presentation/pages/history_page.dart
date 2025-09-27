import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/injection_bloc.dart';
import '../../domain/entities/processo_injecao.dart';
import '../widgets/process_history_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProcesses();
  }

  void _loadProcesses() {
    if (_selectedStatus != null) {
      context.read<InjectionBloc>().add(
        InjectionLoadProcessesByStatus(status: _selectedStatus.toString()),
      );
    } else if (_startDate != null && _endDate != null) {
      // TODO: Implementar busca por data quando o use case estiver disponível
      context.read<InjectionBloc>().add(
        InjectionLoadProcessesByStatus(status: StatusProcesso.concluido.toString()),
      );
    } else {
      // Carrega todos os processos concluídos por padrão
      context.read<InjectionBloc>().add(
        InjectionLoadProcessesByStatus(status: StatusProcesso.concluido.toString()),
      );
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
                        _loadProcesses();
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
                        _loadProcesses();
                      },
                    ),
                ],
              ),
            ),

          // Lista de processos
          Expanded(
            child: BlocBuilder<InjectionBloc, InjectionState>(
              builder: (context, state) {
                if (state is InjectionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is InjectionError) {
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
                          'Erro ao carregar histórico',
                          style: AppTextStyles.titleMedium,
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
                        CustomButton(
                          text: 'Tentar Novamente',
                          onPressed: _loadProcesses,
                          variant: ButtonVariant.outlined,
                        ),
                      ],
                    ),
                  );
                }

                if (state is InjectionProcessesLoaded) {
                  if (state.processos.isEmpty) {
                    return Center(
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
                            'Nenhum processo encontrado',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Não há processos que correspondam aos filtros selecionados.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadProcesses(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.processos.length,
                      itemBuilder: (context, index) {
                        final processo = state.processos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProcessHistoryCard(
                            processo: processo,
                            onTap: () => _navigateToProcessDetails(processo),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text('Estado não reconhecido'),
                );
              },
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
                'Filtrar Processos',
                style: AppTextStyles.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro por status
                  Text(
                    'Status',
                    style: AppTextStyles.labelLarge,
                  ),
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
                  Text(
                    'Período',
                    style: AppTextStyles.labelLarge,
                  ),
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
                    _loadProcesses();
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
                    _loadProcesses();
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
      SnackBar(content: Text('Detalhes do processo ${processo.id} em desenvolvimento')),
    );
  }
}
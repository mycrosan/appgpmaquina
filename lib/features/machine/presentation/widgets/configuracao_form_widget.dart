import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/matriz.dart';
import '../bloc/machine_config_bloc.dart';
import '../bloc/machine_config_event.dart';
import '../bloc/machine_config_state.dart';

/// Widget de formulário simplificado para configuração da máquina
/// Permite apenas seleção de matriz e descrição opcional
class ConfiguracaoFormWidget extends StatefulWidget {
  final int maquinaId;
  final Function(int matrizId, String celularId, String? descricao) onSubmit;

  const ConfiguracaoFormWidget({
    super.key,
    required this.maquinaId,
    required this.onSubmit,
  });

  @override
  State<ConfiguracaoFormWidget> createState() => _ConfiguracaoFormWidgetState();
}

class _ConfiguracaoFormWidgetState extends State<ConfiguracaoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  String _matrizSearchQuery = '';
  
  Matriz? _matrizSelecionada;
  List<Matriz> _matrizes = [];
  bool _carregandoMatrizes = false;

  @override
  void initState() {
    super.initState();
    _carregarMatrizes();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _openMatrizSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = _matrizSearchQuery;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<Matriz> filtered = _matrizes.where((m) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return (m.nome.toLowerCase().contains(q) ||
                      m.codigo.toLowerCase().contains(q));
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.view_module, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Selecionar Matriz',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar matriz',
                        hintText: 'Digite nome ou código',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          query = value;
                          _matrizSearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_carregandoMatrizes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Nenhuma matriz encontrada',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final m = filtered[index];
                            final selected = _matrizSelecionada?.id == m.id;
                            return ListTile(
                              leading: const Icon(Icons.widgets_outlined),
                              title: Text('${m.nome} (${m.codigo})'),
                              trailing: selected
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _matrizSelecionada = m;
                                  _matrizSearchQuery = '';
                                });
                                developer.log('📋 Matriz selecionada: ${m.nome}', name: 'ConfiguracaoFormWidget');
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _carregarMatrizes() {
    setState(() {
      _carregandoMatrizes = true;
    });
    
    context.read<MachineConfigBloc>().add(LoadAvailableMatrizes());
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_matrizSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma matriz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      developer.log('✅ Formulário válido, enviando dados', name: 'ConfiguracaoFormWidget');
      
      // Captura automática do celularId (não mostrado ao usuário)
      const String celularId = "CEL001";
      
      final descricao = _descricaoController.text.trim().isEmpty 
          ? null 
          : _descricaoController.text.trim();

      developer.log('📋 Dados da configuração:', name: 'ConfiguracaoFormWidget');
      developer.log('  - Máquina ID: ${widget.maquinaId}', name: 'ConfiguracaoFormWidget');
      developer.log('  - Matriz ID: ${_matrizSelecionada!.id}', name: 'ConfiguracaoFormWidget');
      developer.log('  - Celular ID: $celularId', name: 'ConfiguracaoFormWidget');
      developer.log('  - Descrição: $descricao', name: 'ConfiguracaoFormWidget');

      widget.onSubmit(_matrizSelecionada!.id, celularId, descricao);
    } else {
      developer.log('❌ Formulário inválido', name: 'ConfiguracaoFormWidget');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MachineConfigBloc, MachineConfigState>(
          listener: (context, state) {
            if (state is AvailableMatrizesLoaded) {
              setState(() {
                _matrizes = state.matrizes;
                _carregandoMatrizes = false;
              });
              developer.log('✅ ${state.matrizes.length} matrizes carregadas', name: 'ConfiguracaoFormWidget');
            } else if (state is MachineConfigLoading) {
              setState(() {
                _carregandoMatrizes = true;
              });
            }
          },
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                'Configuração da Máquina',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Seleção de Matriz com pesquisa
              FormField<Matriz>(
                validator: (_) {
                  if (_matrizSelecionada == null) {
                    return 'Por favor, selecione uma matriz';
                  }
                  return null;
                },
                builder: (state) {
                  return InkWell(
                    onTap: _carregandoMatrizes ? null : _openMatrizSearch,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Matriz *',
                        hintText: 'Selecione uma matriz',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.view_module),
                        suffixIcon: const Icon(Icons.search),
                        errorText: state.errorText,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _matrizSelecionada == null
                              ? 'Toque para pesquisar'
                              : '${_matrizSelecionada!.nome} (${_matrizSelecionada!.codigo})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _matrizSelecionada == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Indicador de carregamento para matrizes
              if (_carregandoMatrizes) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Carregando matrizes...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),

              // Descrição (opcional)
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descrição opcional da configuração',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value != null && value.trim().length > 500) {
                    return 'Descrição deve ter no máximo 500 caracteres';
                  }
                  return null;
                },
                maxLength: 500,
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 24),

              // Informação sobre celular ID (apenas informativo)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'O celular será configurado automaticamente como CEL001',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _carregandoMatrizes ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Configurar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/registro_maquina.dart';
import '../bloc/registro_maquina_bloc.dart';
import '../bloc/registro_maquina_event.dart';
import '../bloc/registro_maquina_state.dart';

/// Página para editar uma máquina
class RegistroMaquinaEditPage extends StatefulWidget {
  final RegistroMaquina maquina;

  const RegistroMaquinaEditPage({super.key, required this.maquina});

  @override
  State<RegistroMaquinaEditPage> createState() =>
      _RegistroMaquinaEditPageState();
}

class _RegistroMaquinaEditPageState extends State<RegistroMaquinaEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _numeroSerieController;
  late final TextEditingController _modeloController;
  late final TextEditingController _fabricanteController;
  late final TextEditingController _localizacaoController;
  late final TextEditingController _responsavelController;
  late final TextEditingController _statusController;
  late final TextEditingController _observacoesController;
  late bool _ativo;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nomeController = TextEditingController(text: widget.maquina.nome);
    _descricaoController = TextEditingController(
      text: widget.maquina.descricao ?? '',
    );
    _numeroSerieController = TextEditingController(
      text: widget.maquina.numeroSerie ?? '',
    );
    _modeloController = TextEditingController(
      text: widget.maquina.modelo ?? '',
    );
    _fabricanteController = TextEditingController(
      text: widget.maquina.fabricante ?? '',
    );
    _localizacaoController = TextEditingController(
      text: widget.maquina.localizacao ?? '',
    );
    _responsavelController = TextEditingController(
      text: widget.maquina.responsavel ?? '',
    );
    _statusController = TextEditingController(text: widget.maquina.status);
    _observacoesController = TextEditingController(
      text: widget.maquina.observacoes ?? '',
    );
    _ativo = widget.maquina.ativo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _numeroSerieController.dispose();
    _modeloController.dispose();
    _fabricanteController.dispose();
    _localizacaoController.dispose();
    _responsavelController.dispose();
    _statusController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedMaquina = RegistroMaquina(
        id: widget.maquina.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        numeroSerie: _numeroSerieController.text.trim().isEmpty
            ? null
            : _numeroSerieController.text.trim(),
        modelo: _modeloController.text.trim().isEmpty
            ? null
            : _modeloController.text.trim(),
        fabricante: _fabricanteController.text.trim().isEmpty
            ? null
            : _fabricanteController.text.trim(),
        localizacao: _localizacaoController.text.trim().isEmpty
            ? null
            : _localizacaoController.text.trim(),
        responsavel: _responsavelController.text.trim().isEmpty
            ? null
            : _responsavelController.text.trim(),
        status: _statusController.text.trim().isEmpty
            ? ''
            : _statusController.text.trim(),
        ativo: _ativo,
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
        criadoEm: widget.maquina.criadoEm,
        atualizadoEm: DateTime.now(),
      );

      context.read<RegistroMaquinaBloc>().add(
        UpdateMaquinaEvent(maquina: updatedMaquina),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Máquina'),
      body: BlocConsumer<RegistroMaquinaBloc, RegistroMaquinaState>(
        listener: (context, state) {
          if (state is RegistroMaquinaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Máquina atualizada com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(
              context,
            ).pop(true); // Retorna true para indicar sucesso
          } else if (state is RegistroMaquinaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegistroMaquinaUpdating;

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildSpecificationsSection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildStatusSection(),
                      const SizedBox(height: 24),
                      _buildObservationsSection(),
                      const SizedBox(height: 32),
                      _buildActionButtons(isLoading),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const LoadingWidget(message: 'Salvando alterações...'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      children: [
        CustomTextField(
          controller: _nomeController,
          label: 'Nome *',
          hint: 'Digite o nome da máquina',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _descricaoController,
          label: 'Descrição',
          hint: 'Digite uma descrição da máquina',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection() {
    return _buildSection(
      title: 'Especificações',
      icon: Icons.settings,
      children: [
        CustomTextField(
          controller: _numeroSerieController,
          label: 'Número de Série',
          hint: 'Digite o número de série',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _modeloController,
          label: 'Modelo',
          hint: 'Digite o modelo da máquina',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _fabricanteController,
          label: 'Fabricante',
          hint: 'Digite o fabricante',
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Localização e Responsável',
      icon: Icons.location_on,
      children: [
        CustomTextField(
          controller: _localizacaoController,
          label: 'Localização',
          hint: 'Digite a localização da máquina',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _responsavelController,
          label: 'Responsável',
          hint: 'Digite o nome do responsável',
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'Status',
      icon: Icons.toggle_on,
      children: [
        CustomTextField(
          controller: _statusController,
          label: 'Status',
          hint: 'Digite o status da máquina',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Ativo:',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: _ativo,
              onChanged: (value) {
                setState(() {
                  _ativo = value;
                });
              },
              activeThumbColor: AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(
              _ativo ? 'Sim' : 'Não',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _ativo ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObservationsSection() {
    return _buildSection(
      title: 'Observações',
      icon: Icons.note,
      children: [
        CustomTextField(
          controller: _observacoesController,
          label: 'Observações',
          hint: 'Digite observações adicionais',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outlined,
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Salvar',
            onPressed: isLoading ? null : _onSave,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
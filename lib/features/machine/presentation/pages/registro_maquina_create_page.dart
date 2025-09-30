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

/// Página para registrar uma nova máquina
class RegistroMaquinaCreatePage extends StatefulWidget {
  const RegistroMaquinaCreatePage({super.key});

  @override
  State<RegistroMaquinaCreatePage> createState() => _RegistroMaquinaCreatePageState();
}

class _RegistroMaquinaCreatePageState extends State<RegistroMaquinaCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoCelularController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoCelularController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final novaMaquina = RegistroMaquina(
        id: 0, // ID será gerado pelo servidor
        nome: _nomeController.text.trim(),
        descricao: 'Máquina vinculada ao celular ${_codigoCelularController.text.trim()}',
        numeroSerie: _codigoCelularController.text.trim(),
        modelo: null,
        fabricante: null,
        localizacao: null,
        responsavel: null,
        status: 'Ativo',
        ativo: true,
        observacoes: 'Criada através do app móvel',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      context.read<RegistroMaquinaBloc>().add(
        CreateMaquinaEvent(maquina: novaMaquina),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Registrar Nova Máquina',
      ),
      body: BlocConsumer<RegistroMaquinaBloc, RegistroMaquinaState>(
        listener: (context, state) {
          if (state is RegistroMaquinaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Máquina registrada com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true); // Retorna true para indicar sucesso
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
          final isLoading = state is RegistroMaquinaLoading;

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildFormFields(),
                      const SizedBox(height: 32),
                      _buildSaveButton(isLoading),
                    ],
                  ),
                ),
              ),
              if (isLoading) const LoadingWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nova Máquina',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preencha as informações básicas para registrar uma nova máquina.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _nomeController,
          label: 'Nome da Máquina',
          hint: 'Digite o nome da máquina',
          prefixIcon: Icons.precision_manufacturing,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome da máquina é obrigatório';
            }
            if (value.trim().length < 3) {
              return 'Nome deve ter pelo menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _codigoCelularController,
          label: 'Código do Celular',
          hint: 'Digite o código do celular vinculado',
          prefixIcon: Icons.phone_android,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Código do celular é obrigatório';
            }
            if (value.trim().length < 4) {
              return 'Código deve ter pelo menos 4 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Registrar Máquina',
        onPressed: isLoading ? null : _onSave,
        icon: Icons.save,
      ),
    );
  }
}
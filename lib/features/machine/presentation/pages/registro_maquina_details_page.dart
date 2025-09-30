import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/registro_maquina.dart';
import '../bloc/registro_maquina_bloc.dart';
import '../bloc/registro_maquina_event.dart';
import '../bloc/registro_maquina_state.dart';
import '../widgets/registro_maquina_details_widget.dart';
import 'registro_maquina_edit_page.dart';

/// Página para exibir os detalhes de uma máquina
class RegistroMaquinaDetailsPage extends StatefulWidget {
  final int maquinaId;

  const RegistroMaquinaDetailsPage({super.key, required this.maquinaId});

  @override
  State<RegistroMaquinaDetailsPage> createState() =>
      _RegistroMaquinaDetailsPageState();
}

class _RegistroMaquinaDetailsPageState
    extends State<RegistroMaquinaDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Busca os dados da máquina ao inicializar
    context.read<RegistroMaquinaBloc>().add(
      GetMaquinaByIdEvent(id: widget.maquinaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes da Máquina'),
      body: BlocConsumer<RegistroMaquinaBloc, RegistroMaquinaState>(
        listener: (context, state) {
          if (state is RegistroMaquinaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RegistroMaquinaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Máquina atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reset para o estado loaded após mostrar a mensagem
            context.read<RegistroMaquinaBloc>().add(
              const ResetUpdateStatusEvent(),
            );
          }
        },
        builder: (context, state) {
          if (state is RegistroMaquinaLoading) {
            return const LoadingWidget(
              message: 'Carregando detalhes da máquina...',
            );
          } else if (state is RegistroMaquinaLoaded ||
              state is RegistroMaquinaUpdated ||
              state is RegistroMaquinaUpdating) {
            final RegistroMaquina maquina;

            if (state is RegistroMaquinaLoaded) {
              maquina = state.maquina;
            } else if (state is RegistroMaquinaUpdated) {
              maquina = state.maquina;
            } else {
              maquina = (state as RegistroMaquinaUpdating).maquina;
            }

            return Column(
              children: [
                Expanded(child: RegistroMaquinaDetailsWidget(maquina: maquina)),
                _buildActionButtons(context, maquina),
              ],
            );
          } else if (state is RegistroMaquinaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RegistroMaquinaBloc>().add(
                        GetMaquinaByIdEvent(id: widget.maquinaId),
                      );
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RegistroMaquina maquina) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEdit(context, maquina),
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, RegistroMaquina maquina) async {
    final bloc = context.read<RegistroMaquinaBloc>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: RegistroMaquinaEditPage(maquina: maquina),
        ),
      ),
    );

    // Se a edição foi bem-sucedida, recarrega os dados
    if (result == true && mounted) {
      bloc.add(GetMaquinaByIdEvent(id: widget.maquinaId));
    }
  }
}
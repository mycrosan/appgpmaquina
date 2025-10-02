import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/injection_bloc.dart';

class TimerInjecaoPage extends StatefulWidget {
  final String numeroEtiqueta;
  final int tempoInjecao;

  const TimerInjecaoPage({
    super.key,
    required this.numeroEtiqueta,
    required this.tempoInjecao,
  });

  @override
  State<TimerInjecaoPage> createState() => _TimerInjecaoPageState();
}

class _TimerInjecaoPageState extends State<TimerInjecaoPage>
    with TickerProviderStateMixin {
  late Timer _timer;
  late int _tempoRestante;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRunning = false;
  bool _isFinished = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _tempoRestante = widget.tempoInjecao;
    _audioPlayer = AudioPlayer();
    
    _progressController = AnimationController(
      duration: Duration(seconds: widget.tempoInjecao),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _isRunning = true;
    _progressController.forward();
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoRestante > 0) {
          _tempoRestante--;
          
          // Enviar evento de atualização do timer
          context.read<InjectionBloc>().add(
            InjectionUpdateTimer(
              tempoRestante: _tempoRestante,
            ),
          );
          
          // Verificar se está próximo do fim (últimos 10 segundos)
          if (_tempoRestante <= 10) {
            _pulseController.duration = const Duration(milliseconds: 500);
          }
        } else {
          _finalizarInjecao();
        }
      });
    });
  }

  void _pausarTimer() {
    _timer.cancel();
    _progressController.stop();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _retomarTimer() {
    _startTimer();
  }

  void _finalizarInjecao() async {
    print('🎯 [TIMER] Finalizando injeção - iniciando efeitos visuais e sonoros');
    _timer.cancel();
    _progressController.stop();
    
    // Configurar estado de finalizado
    setState(() {
      _isFinished = true;
      _isRunning = false;
    });
    
    // Configurar efeito piscante mais rápido
    _pulseController.duration = const Duration(milliseconds: 300);
    _pulseController.repeat(reverse: true);
    print('✨ [TIMER] Efeito piscante ativado');
    
    // Tocar som de alerta
    try {
      print('🔊 [TIMER] Reproduzindo som de alerta...');
      await _audioPlayer.play(AssetSource('sounds/alert.wav'));
      print('✅ [TIMER] Som de alerta reproduzido com sucesso');
    } catch (e) {
      print('💥 [TIMER] ERRO ao reproduzir som: $e');
    }
    
    // Enviar evento para o Bloc
    print('📤 [TIMER] Dispatch InjectionFinalizarInjecaoAr para o Bloc');
    context.read<InjectionBloc>().add(
      const InjectionFinalizarInjecaoAr(),
    );
  }

  void _cancelarInjecao() {
    _timer.cancel();
    _progressController.stop();
    _pulseController.stop();
    
    context.read<InjectionBloc>().add(
      const InjectionCancelarInjecaoAr(),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundosRestantes.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_isFinished) {
      return AppColors.success; // Verde quando finalizado
    } else if (_tempoRestante <= 10) {
      return AppColors.error;
    } else if (_tempoRestante <= 30) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Injeção de Ar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<InjectionBloc, InjectionState>(
        listener: (context, state) {
          if (state is InjectionInjecaoArFinalizada) {
            print('🎉 [TIMER] Estado de injeção finalizada recebido - mantendo na tela com efeito piscante');
            // Não navegar automaticamente - manter na tela com efeito piscante
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.sucesso 
                      ? '🎉 Pneu pronto! Injeção finalizada com sucesso!'
                      : 'Injeção finalizada com falha',
                ),
                backgroundColor: state.sucesso ? AppColors.success : AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is InjectionInjecaoArCancelada) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Injeção cancelada'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Informações da carcaça
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Etiqueta: ${widget.numeroEtiqueta}',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Timer circular
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _tempoRestante <= 10 ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: _getTimerColor().withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress indicator
                              SizedBox(
                                width: 260,
                                height: 260,
                                child: CircularProgressIndicator(
                                  value: _progressController.value,
                                  strokeWidth: 8,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getTimerColor(),
                                  ),
                                ),
                              ),
                              
                              // Tempo restante
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatarTempo(_tempoRestante),
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      color: _getTimerColor(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tempo restante',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Status da injeção
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getTimerColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getTimerColor()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isFinished 
                          ? Icons.check_circle 
                          : (_isRunning ? Icons.play_arrow : Icons.pause),
                      color: _getTimerColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isFinished 
                          ? '🎉 Pneu Pronto!' 
                          : (_isRunning ? 'Injeção em andamento...' : 'Injeção pausada'),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _getTimerColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botões de controle
              _isFinished
                  ? CustomButton(
                      text: 'Voltar',
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      backgroundColor: AppColors.primary,
                      icon: Icons.home,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancelar',
                            onPressed: () => _showCancelDialog(),
                            backgroundColor: AppColors.error,
                            icon: Icons.stop,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: _isRunning ? 'Pausar' : 'Retomar',
                            onPressed: _isRunning ? _pausarTimer : _retomarTimer,
                            backgroundColor: _isRunning ? AppColors.warning : AppColors.success,
                            icon: _isRunning ? Icons.pause : Icons.play_arrow,
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Injeção'),
        content: const Text(
          'Tem certeza que deseja cancelar a injeção de ar? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelarInjecao();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/http_client.dart';
import '../../predict/data/credit_api.dart';
import '../logic/auth_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(CreditApi(createDio())),
      child: Scaffold(
        appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Успешно!')),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final isAuthed = state is Authenticated;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Создайте аккаунт или войдите, чтобы сохранять историю.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                v != null && v.contains('@') ? null : 'Email?',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Пароль',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) =>
                                v != null && v.length >= 6 ? null : '≥ 6 символов',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (!(_formKey.currentState?.validate() ?? false)) {
                                  return;
                                }
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                final cubit = context.read<AuthCubit>();
                                _isLogin
                                    ? cubit.login(email, password)
                                    : cubit.register(email, password);
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                          _isLogin ? 'Нет аккаунта? Регистрация' : 'Уже есть? Войти'),
                    ),
                    const SizedBox(height: 24),
                    if (isAuthed)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.verified_user),
                          title: const Text('Токен'),
                          subtitle: Text((state as Authenticated).token),
                          trailing: IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed:
                                isLoading ? null : () => context.read<AuthCubit>().logout(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


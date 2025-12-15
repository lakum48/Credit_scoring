import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/http_client.dart';
import '../../predict/data/credit_api.dart';
import '../../predict/data/models/client_data.dart';
import '../../predict/logic/predict_cubit.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _empLengthController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _loanRateController = TextEditingController();
  final _loanPercentIncomeController = TextEditingController();
  final _credHistLenController = TextEditingController();

  String _homeOwnership = 'RENT';
  String _loanIntent = 'PERSONAL';
  String _loanGrade = 'C';
  String _defaultOnFile = 'N';

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _empLengthController.dispose();
    _loanAmountController.dispose();
    _loanRateController.dispose();
    _loanPercentIncomeController.dispose();
    _credHistLenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PredictCubit(CreditApi(createDio())),
      child: Scaffold(
        appBar: AppBar(title: const Text('Кредитный скоринг')),
        body: BlocConsumer<PredictCubit, PredictState>(
          listener: (context, state) {
            if (state is PredictError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isLoading = state is PredictLoading;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _numberField(
                                controller: _ageController,
                                label: 'Возраст',
                                hint: '18-100',
                                min: 18,
                                max: 100,
                                isInt: true,
                              ),
                              _numberField(
                                controller: _incomeController,
                                label: 'Доход',
                                hint: 'в у.е. / месяц',
                                min: 0,
                              ),
                              _dropdown<String>(
                                label: 'Тип жилья',
                                value: _homeOwnership,
                                items: const ['RENT', 'MORTGAGE', 'OWN', 'OTHER'],
                                onChanged: (v) => setState(() => _homeOwnership = v),
                              ),
                              _numberField(
                                controller: _empLengthController,
                                label: 'Стаж (лет)',
                                hint: 'можно 0, дробные значения',
                                min: 0,
                              ),
                              _dropdown<String>(
                                label: 'Цель кредита',
                                value: _loanIntent,
                                items: const [
                                  'PERSONAL',
                                  'EDUCATION',
                                  'MEDICAL',
                                  'VENTURE',
                                  'HOMEIMPROVEMENT',
                                  'DEBTCONSOLIDATION',
                                ],
                                onChanged: (v) => setState(() => _loanIntent = v),
                              ),
                              _dropdown<String>(
                                label: 'Кредитный грейд',
                                value: _loanGrade,
                                items: const ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
                                onChanged: (v) => setState(() => _loanGrade = v),
                              ),
                              _numberField(
                                controller: _loanAmountController,
                                label: 'Сумма кредита',
                                min: 1,
                              ),
                              _numberField(
                                controller: _loanRateController,
                                label: 'Ставка, %',
                                hint: 'можно пусто',
                                min: 0,
                                allowEmpty: true,
                              ),
                              _numberField(
                                controller: _loanPercentIncomeController,
                                label: '% от дохода',
                                hint: 'loan_amnt / income',
                                min: 0,
                                allowEmpty: true,
                              ),
                              _dropdown<String>(
                                label: 'Были дефолты?',
                                value: _defaultOnFile,
                                items: const ['Y', 'N'],
                                onChanged: (v) => setState(() => _defaultOnFile = v),
                              ),
                              _numberField(
                                controller: _credHistLenController,
                                label: 'Длина кредитной истории (лет)',
                                min: 0,
                                isInt: true,
                                allowEmpty: true,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() ??
                                              false) {
                                            final data = _buildRequest();
                                            context
                                                .read<PredictCubit>()
                                                .submit(data);
                                          }
                                        },
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Text('Рассчитать'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResultCard(state: state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ClientData _buildRequest() {
    int? credHist;
    if (_credHistLenController.text.isNotEmpty) {
      credHist = int.tryParse(_credHistLenController.text);
    }
    return ClientData(
      personAge: int.parse(_ageController.text),
      personIncome: double.parse(_incomeController.text),
      personHomeOwnership: _homeOwnership,
      personEmpLength: _empLengthController.text.isEmpty
          ? null
          : double.tryParse(_empLengthController.text),
      loanIntent: _loanIntent,
      loanGrade: _loanGrade,
      loanAmnt: double.parse(_loanAmountController.text),
      loanIntRate: _loanRateController.text.isEmpty
          ? null
          : double.tryParse(_loanRateController.text),
      loanPercentIncome: _loanPercentIncomeController.text.isEmpty
          ? null
          : double.tryParse(_loanPercentIncomeController.text),
      cbPersonDefaultOnFile: _defaultOnFile,
      cbPersonCredHistLength: credHist,
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    String? hint,
    double? min,
    double? max,
    bool isInt = false,
    bool allowEmpty = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (value) {
          if (!allowEmpty && (value == null || value.isEmpty)) {
            return 'Обязательное поле';
          }
          if (allowEmpty && (value == null || value.isEmpty)) {
            return null;
          }
          final parsed =
              isInt ? int.tryParse(value!)?.toDouble() : double.tryParse(value!);
          if (parsed == null) return 'Введите число';
          if (min != null && parsed < min) return 'Минимум $min';
          if (max != null && parsed > max) return 'Максимум $max';
          return null;
        },
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final PredictState state;

  @override
  Widget build(BuildContext context) {
    if (state is PredictSuccess) {
      final data = (state as PredictSuccess).response;
      final prob = data.probability != null
          ? '${(data.probability! * 100).toStringAsFixed(1)}%'
          : '—';
      return Card(
        child: ListTile(
          title: Text(data.approved ? 'Одобрено' : 'Отказ'),
          subtitle: Text('Вероятность: $prob'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}


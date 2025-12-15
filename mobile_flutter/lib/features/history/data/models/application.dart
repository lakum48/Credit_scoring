class Application {
  Application({
    required this.id,
    required this.personAge,
    required this.personIncome,
    required this.personHomeOwnership,
    required this.personEmpLength,
    required this.loanIntent,
    required this.loanGrade,
    required this.loanAmnt,
    required this.loanIntRate,
    required this.loanPercentIncome,
    required this.cbPersonDefaultOnFile,
    required this.cbPersonCredHistLength,
    required this.modelScore,
    required this.approved,
    required this.timestamp,
  });

  final int id;
  final int personAge;
  final double personIncome;
  final String personHomeOwnership;
  final double personEmpLength;
  final String loanIntent;
  final String? loanGrade;
  final double loanAmnt;
  final double? loanIntRate;
  final double? loanPercentIncome;
  final String? cbPersonDefaultOnFile;
  final int? cbPersonCredHistLength;
  final double? modelScore;
  final bool approved;
  final DateTime timestamp;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as int,
      personAge: json['person_age'] as int,
      personIncome: (json['person_income'] as num).toDouble(),
      personHomeOwnership: json['person_home_ownership'] as String,
      personEmpLength: (json['person_emp_length'] as num).toDouble(),
      loanIntent: json['loan_intent'] as String,
      loanGrade: json['loan_grade'] as String?,
      loanAmnt: (json['loan_amnt'] as num).toDouble(),
      loanIntRate: (json['loan_int_rate'] as num?)?.toDouble(),
      loanPercentIncome: (json['loan_percent_income'] as num?)?.toDouble(),
      cbPersonDefaultOnFile: json['cb_person_default_on_file'] as String?,
      cbPersonCredHistLength: json['cb_person_cred_hist_length'] as int?,
      modelScore: (json['model_score'] as num?)?.toDouble(),
      approved: json['approved'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}


class ClientData {
  ClientData({
    required this.personAge,
    required this.personIncome,
    required this.personHomeOwnership,
    this.personEmpLength,
    required this.loanIntent,
    this.loanGrade,
    required this.loanAmnt,
    this.loanIntRate,
    this.loanPercentIncome,
    this.cbPersonDefaultOnFile,
    this.cbPersonCredHistLength,
  });

  final int personAge;
  final double personIncome;
  final String personHomeOwnership;
  final double? personEmpLength;
  final String loanIntent;
  final String? loanGrade;
  final double loanAmnt;
  final double? loanIntRate;
  final double? loanPercentIncome;
  final String? cbPersonDefaultOnFile;
  final int? cbPersonCredHistLength;

  Map<String, dynamic> toJson() => {
        'person_age': personAge,
        'person_income': personIncome,
        'person_home_ownership': personHomeOwnership,
        'person_emp_length': personEmpLength,
        'loan_intent': loanIntent,
        'loan_grade': loanGrade,
        'loan_amnt': loanAmnt,
        'loan_int_rate': loanIntRate,
        'loan_percent_income': loanPercentIncome,
        'cb_person_default_on_file': cbPersonDefaultOnFile,
        'cb_person_cred_hist_length': cbPersonCredHistLength,
      };
}


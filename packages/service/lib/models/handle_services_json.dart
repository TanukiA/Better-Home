class ServicePrice {
  final String name;
  final List<Issue> issues;

  ServicePrice({required this.name, required this.issues});

  factory ServicePrice.fromJson(Map<String, dynamic> json) {
    var issues = json['issues'] as List;
    List<Issue> issueList =
        issues.map((issue) => Issue.fromJson(issue)).toList();

    return ServicePrice(name: json['name'], issues: issueList);
  }
}

class Issue {
  final String name;
  final int price;

  Issue({required this.name, required this.price});

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(name: json['name'], price: json['price']);
  }
}

class ServiceVariation {
  final String title;
  final List<Issue> issues;

  ServiceVariation({required this.title, required this.issues});

  factory ServiceVariation.fromJson(Map<String, dynamic> json) {
    var issues = json['issues'] as List;
    List<Issue> issueList =
        issues.map((issue) => Issue.fromJson(issue)).toList();

    return ServiceVariation(title: json['title'], issues: issueList);
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

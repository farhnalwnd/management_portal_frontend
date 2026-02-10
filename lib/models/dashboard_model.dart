class DashboardData {
  final Map<String, List<MenuItem>> categories;

  DashboardData({required this.categories});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    Map<String, List<MenuItem>> categories = {};
    json.forEach((key, value) {
      if (value is List) {
        categories[key] = value.map((item) => MenuItem.fromJson(item)).toList();
      }
    });
    return DashboardData(categories: categories);
  }
}

class MenuItem {
  final int id;
  final String menuName;
  final int displayOrder;
  final int isActive;
  final Module module;
  final Content content;

  MenuItem({
    required this.id,
    required this.menuName,
    required this.displayOrder,
    required this.isActive,
    required this.module,
    required this.content,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      menuName: json['menu_name'],
      displayOrder: json['display_order'],
      isActive: json['is_active'],
      module: Module.fromJson(json['module']),
      content: Content.fromJson(json['content']),
    );
  }
}

class Module {
  final int id;
  final String moduleName;
  final String moduleDescription;
  final String category;

  Module({
    required this.id,
    required this.moduleName,
    required this.moduleDescription,
    required this.category,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      moduleName: json['module_name'],
      moduleDescription: json['module_description'],
      category: json['category'],
    );
  }
}

class Content {
  final String type;
  final String title;
  final String version;
  final String repo;

  Content({
    required this.type,
    required this.title,
    required this.version,
    required this.repo,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      type: json['type'],
      title: json['title'],
      version: json['version'],
      repo: json['repo'],
    );
  }
}

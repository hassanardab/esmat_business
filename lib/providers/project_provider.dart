//lib/providers/project_provider.dart
import 'package:flutter/material.dart';
import '../models/project.dart';
import 'package:collection/collection.dart';
import '../services/storage_service.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;

  Future<void> loadProjects() async {
    _projects = StorageService.getProjects();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await StorageService.addProject(project);
    await loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await StorageService.updateProject(project);
    await loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await StorageService.deleteProject(id);
    await loadProjects();
    if (_selectedProject?.id == id) {
      _selectedProject = null;
    }
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  Project? getProject(String id) {
    return _projects.firstWhereOrNull((p) => p.id == id);
  }
}

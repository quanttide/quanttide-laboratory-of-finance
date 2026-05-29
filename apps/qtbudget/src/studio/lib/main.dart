import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage_backend_web.dart';
import 'services/storage_service.dart';

void main() {
  StorageService.useBackend(LocalStorageBackend());
  runApp(const QtBudgetApp());
}

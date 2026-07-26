//lib/providers/vendor_provider.dart
import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/storage_service.dart';
import 'package:collection/collection.dart';

class VendorProvider with ChangeNotifier {
  List<Vendor> _vendors = [];

  List<Vendor> get vendors => _vendors;

  Future<void> loadVendors() async {
    _vendors = StorageService.getVendors();
    notifyListeners();
  }

  Future<void> addVendor(Vendor vendor) async {
    await StorageService.addVendor(vendor);
    await loadVendors();
  }

  Future<void> updateVendor(Vendor vendor) async {
    await StorageService.updateVendor(vendor);
    await loadVendors();
  }

  Future<void> deleteVendor(String id) async {
    await StorageService.deleteVendor(id);
    await loadVendors();
  }

  Vendor? getVendor(String id) {
    return _vendors.firstWhereOrNull((v) => v.id == id);
  }
}

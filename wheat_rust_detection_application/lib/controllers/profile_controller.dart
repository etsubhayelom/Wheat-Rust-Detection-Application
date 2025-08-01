import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wheat_rust_detection_application/services/api_services.dart';

class ProfileController extends GetxController {
  var isApproved = false.obs;

  Future<void> fetchVerificationStatus() async {
    final status = await ApiService().getVerificationStatus();
    bool newStatus = status['verification_request_status'] == 'approved';

    // Debug print when status changes
    debugPrint(
        "Fetched verification status: ${newStatus ? 'APPROVED' : 'REJECTED'}");
    isApproved.value = newStatus;
  }
}

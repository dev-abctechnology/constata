import 'package:constata/src/features/effective_process/models/effective_model.dart';
import 'package:flutter/material.dart';

class AppointmentData with ChangeNotifier {
  EffectiveApointment _appointmentData;

  EffectiveApointment get appointmentData {
    if (_appointmentData != null) {
      return _appointmentData;
    }
  }

  void clearAppointmentData() {
    _appointmentData = null;
  }

  void setAppointmentData(EffectiveApointment data) {
    _appointmentData = data;
    notifyListeners();
  }
}

import 'package:constata/src/features/effective_process/models/effective_model.dart';
import 'package:flutter/material.dart';

class AppointmentData with ChangeNotifier {
  late EffectiveApointment _appointmentData;
  ValueNotifier<bool> _hasData = ValueNotifier(false);

  ValueNotifier<bool> get hasData => _hasData;

  EffectiveApointment get appointmentData {
    return _appointmentData;
  }

  void clearAppointmentData() {
    _hasData.value = false;
    notifyListeners();
  }

  void setAppointmentData(EffectiveApointment data) {
    _hasData.value = true;
    _appointmentData = data;
    notifyListeners();
  }
}

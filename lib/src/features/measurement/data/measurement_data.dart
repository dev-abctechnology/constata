import 'package:flutter/widgets.dart';

import '../model/measurement_object_r.dart';

class MeasurementData extends ChangeNotifier {
  MeasurementAppointment _measurementData;

  MeasurementAppointment get measurementData {
    if (_measurementData != null) {
      return _measurementData;
    }
  }

  void clearMeasurementData() {
    _measurementData = null;
  }

  void setMeasurementData(MeasurementAppointment data) {
    _measurementData = data;
    notifyListeners();
  }
}

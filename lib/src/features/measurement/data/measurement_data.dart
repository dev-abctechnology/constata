import 'package:flutter/widgets.dart';

import '../model/measurement_object_r.dart';

class MeasurementData extends ChangeNotifier {
  late MeasurementAppointment _measurementData;

  final ValueNotifier<bool> _hasData = ValueNotifier(false);

  bool get hasData => _hasData.value;

  MeasurementAppointment get measurementData {
    return _measurementData;
  }

  void clearMeasurementData() {
    _hasData.value = false;
    notifyListeners();
  }

  void setMeasurementData(MeasurementAppointment data) {
    _measurementData = data;
    _hasData.value = true;
    notifyListeners();
  }
}

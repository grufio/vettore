import 'package:flutter/foundation.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';

/// Controller that manages a numeric value stored in base pixels, its display
/// unit, and DPI for conversions. Supports optional linking with a partner
/// controller using a fixed aspect ratio (partner/this).
class UnitValueController extends ChangeNotifier {
  UnitValueController({
    double? valuePx,
    String unit = 'px',
    int dpi = 72,
  })  : _valuePx = valuePx,
        _unit = unit,
        _dpi = dpi;

  double? _valuePx;
  String _unit;
  int _dpi;

  bool _linked = false;
  UnitValueController? _partner;
  double? _partnerOverThisAspect; // partner.valuePx = this.valuePx * aspect
  bool _syncing = false;

  double? get valuePx => _valuePx;
  String get unit => _unit;
  int get dpi => _dpi;
  bool get linked => _linked;
  double? get partnerOverThisAspect => _partnerOverThisAspect;

  void setDpi(int newDpi) {
    if (newDpi <= 0 || newDpi == _dpi) return;
    _dpi = newDpi;
    notifyListeners();
  }

  void setUnit(String newUnit) {
    if (newUnit == _unit) return;
    _unit = newUnit;
    notifyListeners();
  }

  /// Sets value by providing a measurement in the current unit.
  void setValueFromUnit(double valueInCurrentUnit) {
    final double px = convertUnit(
      value: valueInCurrentUnit,
      fromUnit: _unit,
      toUnit: 'px',
      dpi: _dpi,
    );
    setValuePx(px);
  }

  /// Sets the internal pixel value directly.
  void setValuePx(double? px) {
    if (_valuePx == px) return;
    _valuePx = px;
    // Propagate to partner when linked and aspect is known
    if (_linked &&
        _partner != null &&
        _partnerOverThisAspect != null &&
        !_syncing) {
      try {
        _syncing = true;
        final double? base = _valuePx;
        if (base != null) {
          final double partnerPx = base * _partnerOverThisAspect!;
          _partner!._setValuePxInternal(partnerPx);
        }
      } finally {
        _syncing = false;
      }
    }
    notifyListeners();
  }

  /// Internal silent setter to avoid feedback loops.
  void _setValuePxInternal(double? px) {
    _valuePx = px;
    notifyListeners();
  }

  /// Computes the numeric value in the current unit (or an override unit).
  double? getValueInUnit({String? overrideUnit}) {
    final double? px = _valuePx;
    if (px == null) return null;
    final String u = overrideUnit ?? _unit;
    return convertUnit(value: px, fromUnit: 'px', toUnit: u, dpi: _dpi);
  }

  /// Establish bidirectional linking with a partner controller.
  /// The aspect is partner/this in pixels. If null, it will be inferred from
  /// the current pixel values when possible (and left null otherwise).
  void linkWith(UnitValueController partner, {double? partnerOverThis}) {
    _partner = partner;
    _linked = true;
    if (partnerOverThis != null) {
      _partnerOverThisAspect = partnerOverThis;
    } else {
      if (_valuePx != null && partner._valuePx != null && _valuePx != 0) {
        _partnerOverThisAspect = partner._valuePx! / _valuePx!;
      }
    }
    notifyListeners();
  }

  void setLinked(bool linked) {
    if (_linked == linked) return;
    _linked = linked;
    notifyListeners();
  }

  /// Update aspect ratio (partner/this) explicitly.
  void setAspect(double partnerOverThis) {
    _partnerOverThisAspect = partnerOverThis;
    notifyListeners();
  }
}

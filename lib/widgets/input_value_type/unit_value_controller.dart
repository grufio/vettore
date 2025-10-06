import 'package:flutter/foundation.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';

/// Controller that manages a numeric value stored in base pixels, its display
/// unit, and DPI for conversions. Supports optional linking with a partner
/// controller using a fixed aspect ratio (partner/this).
class UnitValueController extends ChangeNotifier {
  UnitValueController({double? valuePx, String unit = 'px', int dpi = 96})
      : _valuePx = valuePx,
        _unit = unit,
        _dpi = dpi;

  double? _valuePx;
  String _unit;
  int _dpi;

  bool _linked = false;
  UnitValueController? _partner;
  double? _partnerOverThisAspect; // partner.valuePx = this.valuePx * aspect
  bool _syncing = false;

  // User echo state to avoid visible rounding flip-flops
  double? _lastUserTypedValueInUnit;
  String? _lastUserTypedUnit;
  double? _lastUserTypedPxSnapshot;

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
  /// If isUserInput is true, the controller remembers the typed value/unit
  /// to allow stable echo on display without re-rounding.
  void setValueFromUnit(double valueInCurrentUnit, {bool isUserInput = false}) {
    final double px = convertUnit(
      value: valueInCurrentUnit,
      fromUnit: _unit,
      toUnit: 'px',
      dpi: _dpi,
    );
    setValuePx(px);
    if (isUserInput) {
      // Stabilize internal echo to 4 decimals for non-px units
      final bool isPx = _unit.trim().toLowerCase() == 'px';
      final double echo = isPx
          ? valueInCurrentUnit.roundToDouble()
          : ((valueInCurrentUnit * 10000.0).round() / 10000.0);
      _lastUserTypedValueInUnit = echo;
      _lastUserTypedUnit = _unit;
      _lastUserTypedPxSnapshot = _valuePx;
    }
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

  /// Returns a display value for the given (or current) unit that prefers
  /// echoing the last user-typed value when possible to avoid double-rounding.
  double? getDisplayValueInUnit({String? overrideUnit}) {
    final String u = overrideUnit ?? _unit;
    if (_lastUserTypedUnit == u &&
        _lastUserTypedPxSnapshot != null &&
        _valuePx != null) {
      // Treat sub‑pixel changes (e.g., round to nearest int px by storage)
      // as visually equivalent; prefer the last typed value to avoid flip‑flop.
      final double deltaPx = (_valuePx! - _lastUserTypedPxSnapshot!).abs();
      const double epsilonPx = 0.5; // within half a pixel → keep typed value
      if (deltaPx <= epsilonPx && _lastUserTypedValueInUnit != null) {
        return _lastUserTypedValueInUnit;
      }
    }
    final double? raw = getValueInUnit(overrideUnit: overrideUnit);
    if (raw == null) return null;
    // Round to 4 decimals internally to stabilize UI at 2 decimals
    final double scaled = (raw * 10000.0).round() / 10000.0;
    return scaled;
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

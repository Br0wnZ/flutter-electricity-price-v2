enum PriceRegion {
  peninsula('peninsula', 'Península'),
  baleares('baleares', 'Baleares'),
  canarias('canarias', 'Canarias'),
  ceuta('ceuta', 'Ceuta'),
  melilla('melilla', 'Melilla');

  const PriceRegion(this.code, this.label);

  final String code;
  final String label;

  String get apiValue => code;
}

extension PriceRegionX on PriceRegion {
  static PriceRegion? fromCode(String? code) {
    if (code == null) return null;
    for (final region in PriceRegion.values) {
      if (region.code == code) return region;
    }
    return null;
  }
}

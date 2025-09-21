/// Types of BPS realms
enum BPSRealmType {
  /// Internal BPS realm for employees
  internal,

  /// External BPS realm for external users
  external;

  /// String representation of the realm type
  String get value => switch (this) {
    internal => 'pegawai-bps',
    external => 'eksternal',
  };

  /// Display name for the realm type
  String get displayName => switch (this) {
    internal => 'BPS Internal',
    external => 'External',
  };
}

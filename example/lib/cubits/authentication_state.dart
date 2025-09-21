part of 'authentication_cubit.dart';

class AuthenticationState extends Equatable {
  final BPSUser? currentUser;
  final bool isLoading;
  final String? lastOperation;
  final String? lastResult;
  final BPSRealmType selectedRealm;
  final DateTime? authStartTime;

  const AuthenticationState({
    this.currentUser,
    this.isLoading = false,
    this.lastOperation,
    this.lastResult,
    this.selectedRealm = BPSRealmType.internal,
    this.authStartTime,
  });

  AuthenticationState copyWith({
    BPSUser? currentUser,
    bool? isLoading,
    String? lastOperation,
    String? lastResult,
    BPSRealmType? selectedRealm,
    DateTime? authStartTime,
    bool clearCurrentUser = false,
    bool clearLastOperation = false,
    bool clearLastResult = false,
    bool clearAuthStartTime = false,
  }) {
    return AuthenticationState(
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      lastOperation: clearLastOperation ? null : (lastOperation ?? this.lastOperation),
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      selectedRealm: selectedRealm ?? this.selectedRealm,
      authStartTime: clearAuthStartTime ? null : (authStartTime ?? this.authStartTime),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentUser': currentUser != null
          ? {
              'userData': currentUser!.toJson(),
              'realm': selectedRealm.name,
            }
          : null,
      'isLoading': false, // Don't persist loading state
      'lastOperation': lastOperation,
      'lastResult': lastResult,
      'selectedRealm': selectedRealm.name,
      // Don't persist authStartTime as it's session-specific
    };
  }

  factory AuthenticationState.fromJson(Map<String, dynamic> json) {
    BPSUser? user;
    BPSRealmType realm = BPSRealmType.internal;

    if (json['currentUser'] != null) {
      final userMap = json['currentUser'] as Map<String, dynamic>;
      final realmName = userMap['realm'] as String?;
      realm = BPSRealmType.values.firstWhere(
        (e) => e.name == realmName,
        orElse: () => BPSRealmType.internal,
      );
      user = BPSUser.fromJson(
        userMap['userData'] as Map<String, dynamic>,
        realm,
      );
    }

    return AuthenticationState(
      currentUser: user,
      isLoading: false, // Don't restore loading state
      lastOperation: json['lastOperation'] as String?,
      lastResult: json['lastResult'] as String?,
      selectedRealm: BPSRealmType.values.firstWhere(
        (e) => e.name == json['selectedRealm'],
        orElse: () => BPSRealmType.internal,
      ),
      authStartTime: null, // Don't restore session-specific data
    );
  }

  bool get isAuthenticated => currentUser != null;
  bool get canPerformOperations => isAuthenticated && !isLoading;

  @override
  List<Object?> get props => [
        currentUser,
        isLoading,
        lastOperation,
        lastResult,
        selectedRealm,
        authStartTime,
      ];
}
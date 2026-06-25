/// OAuth2 scopes for BPS SSO
enum BPSOAuthScope {
  openid,
  profile,
  email,
  profilePegawai,
  roles,
  groups,
  offlineAccess;

  String get value => switch (this) {
    openid => 'openid',
    profile => 'profile',
    email => 'email',
    profilePegawai => 'profile-pegawai',
    roles => 'roles',
    groups => 'groups',
    offlineAccess => 'offline_access',
  };
}

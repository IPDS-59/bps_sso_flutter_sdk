/// OIDC `display` parameter (OpenID Connect Core 1.0 §3.1.2.1), passed to
/// Keycloak's authorization endpoint to pick the login page theme.
///
/// Keycloak serves its default desktop-width theme unless [touch] (or
/// [wap]) is requested, even when the page is opened in a mobile Chrome
/// Custom Tab / SFSafariViewController. [touch] is the default for this
/// SDK since every consumer is a native mobile app.
enum BPSOAuthDisplay {
  /// Default desktop-style full page.
  page,

  /// Compact UI for a popup window (rarely applicable to Custom Tabs).
  popup,

  /// Touch-optimized UI for mobile devices. Default for this SDK.
  touch,

  /// Feature-phone-optimized UI.
  wap;

  String get value => switch (this) {
    page => 'page',
    popup => 'popup',
    touch => 'touch',
    wap => 'wap',
  };
}

/// "https://www.banco.es/login" → "banco.es"; null when [url] isn't a usable address.
String? siteHost(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final host = Uri.tryParse(withScheme(trimmed))?.host;
  if (host == null || host.trim().isEmpty) return null;
  return host.startsWith('www.') ? host.substring(4) : host;
}

/// People type "banco.es"; the browser needs a scheme.
String withScheme(String url) => url.contains('://') ? url : 'https://$url';

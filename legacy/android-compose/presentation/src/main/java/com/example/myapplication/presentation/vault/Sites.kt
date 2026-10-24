package com.example.myapplication.presentation.vault

import java.net.URI

/** "https://www.banco.es/login" → "banco.es"; null when [url] isn't a usable address. */
fun siteHost(url: String): String? {
    val trimmed = url.trim()
    if (trimmed.isEmpty()) return null
    return runCatching { URI(withScheme(trimmed)).host }.getOrNull()?.removePrefix("www.")?.takeIf { it.isNotBlank() }
}

/** People type "banco.es"; the browser needs a scheme. */
fun withScheme(url: String): String = if ("://" in url) url else "https://$url"

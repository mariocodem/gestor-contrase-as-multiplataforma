package com.example.myapplication.data.di

import javax.inject.Qualifier

/** CPU-bound work such as key derivation and AES. */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class DefaultDispatcher

/** Lives as long as the process; for work that must outlive any screen. */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class ApplicationScope

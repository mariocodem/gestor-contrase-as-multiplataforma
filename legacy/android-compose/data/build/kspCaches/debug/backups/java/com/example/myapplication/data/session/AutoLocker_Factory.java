package com.example.myapplication.data.session;

import com.example.myapplication.domain.repository.SettingsRepository;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import kotlinx.coroutines.CoroutineScope;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("com.example.myapplication.data.di.ApplicationScope")
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation",
    "nullness:initialization.field.uninitialized"
})
public final class AutoLocker_Factory implements Factory<AutoLocker> {
  private final Provider<VaultSession> sessionProvider;

  private final Provider<SettingsRepository> settingsProvider;

  private final Provider<CoroutineScope> scopeProvider;

  private AutoLocker_Factory(Provider<VaultSession> sessionProvider,
      Provider<SettingsRepository> settingsProvider, Provider<CoroutineScope> scopeProvider) {
    this.sessionProvider = sessionProvider;
    this.settingsProvider = settingsProvider;
    this.scopeProvider = scopeProvider;
  }

  @Override
  public AutoLocker get() {
    return newInstance(sessionProvider.get(), settingsProvider.get(), scopeProvider.get());
  }

  public static AutoLocker_Factory create(Provider<VaultSession> sessionProvider,
      Provider<SettingsRepository> settingsProvider, Provider<CoroutineScope> scopeProvider) {
    return new AutoLocker_Factory(sessionProvider, settingsProvider, scopeProvider);
  }

  public static AutoLocker newInstance(VaultSession session, SettingsRepository settings,
      CoroutineScope scope) {
    return new AutoLocker(session, settings, scope);
  }
}

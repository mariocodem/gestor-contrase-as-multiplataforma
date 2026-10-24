package com.example.myapplication.domain.usecase.settings;

import com.example.myapplication.domain.repository.SettingsRepository;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;

@ScopeMetadata
@QualifierMetadata
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
public final class SetAutoLockTimeoutUseCase_Factory implements Factory<SetAutoLockTimeoutUseCase> {
  private final Provider<SettingsRepository> settingsProvider;

  private SetAutoLockTimeoutUseCase_Factory(Provider<SettingsRepository> settingsProvider) {
    this.settingsProvider = settingsProvider;
  }

  @Override
  public SetAutoLockTimeoutUseCase get() {
    return newInstance(settingsProvider.get());
  }

  public static SetAutoLockTimeoutUseCase_Factory create(
      Provider<SettingsRepository> settingsProvider) {
    return new SetAutoLockTimeoutUseCase_Factory(settingsProvider);
  }

  public static SetAutoLockTimeoutUseCase newInstance(SettingsRepository settings) {
    return new SetAutoLockTimeoutUseCase(settings);
  }
}

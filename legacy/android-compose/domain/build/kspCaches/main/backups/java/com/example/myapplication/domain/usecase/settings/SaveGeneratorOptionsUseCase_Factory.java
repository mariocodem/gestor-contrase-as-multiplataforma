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
public final class SaveGeneratorOptionsUseCase_Factory implements Factory<SaveGeneratorOptionsUseCase> {
  private final Provider<SettingsRepository> settingsProvider;

  private SaveGeneratorOptionsUseCase_Factory(Provider<SettingsRepository> settingsProvider) {
    this.settingsProvider = settingsProvider;
  }

  @Override
  public SaveGeneratorOptionsUseCase get() {
    return newInstance(settingsProvider.get());
  }

  public static SaveGeneratorOptionsUseCase_Factory create(
      Provider<SettingsRepository> settingsProvider) {
    return new SaveGeneratorOptionsUseCase_Factory(settingsProvider);
  }

  public static SaveGeneratorOptionsUseCase newInstance(SettingsRepository settings) {
    return new SaveGeneratorOptionsUseCase(settings);
  }
}

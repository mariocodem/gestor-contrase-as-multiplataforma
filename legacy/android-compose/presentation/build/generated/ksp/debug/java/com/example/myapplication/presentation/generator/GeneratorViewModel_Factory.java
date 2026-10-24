package com.example.myapplication.presentation.generator;

import com.example.myapplication.domain.usecase.generator.GeneratePasswordUseCase;
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase;
import com.example.myapplication.domain.usecase.settings.SaveGeneratorOptionsUseCase;
import com.example.myapplication.presentation.common.SecretClipboard;
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
public final class GeneratorViewModel_Factory implements Factory<GeneratorViewModel> {
  private final Provider<ObserveSettingsUseCase> observeSettingsProvider;

  private final Provider<SaveGeneratorOptionsUseCase> saveOptionsProvider;

  private final Provider<GeneratePasswordUseCase> generatePasswordProvider;

  private final Provider<SecretClipboard> clipboardProvider;

  private GeneratorViewModel_Factory(Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SaveGeneratorOptionsUseCase> saveOptionsProvider,
      Provider<GeneratePasswordUseCase> generatePasswordProvider,
      Provider<SecretClipboard> clipboardProvider) {
    this.observeSettingsProvider = observeSettingsProvider;
    this.saveOptionsProvider = saveOptionsProvider;
    this.generatePasswordProvider = generatePasswordProvider;
    this.clipboardProvider = clipboardProvider;
  }

  @Override
  public GeneratorViewModel get() {
    return newInstance(observeSettingsProvider.get(), saveOptionsProvider.get(), generatePasswordProvider.get(), clipboardProvider.get());
  }

  public static GeneratorViewModel_Factory create(
      Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SaveGeneratorOptionsUseCase> saveOptionsProvider,
      Provider<GeneratePasswordUseCase> generatePasswordProvider,
      Provider<SecretClipboard> clipboardProvider) {
    return new GeneratorViewModel_Factory(observeSettingsProvider, saveOptionsProvider, generatePasswordProvider, clipboardProvider);
  }

  public static GeneratorViewModel newInstance(ObserveSettingsUseCase observeSettings,
      SaveGeneratorOptionsUseCase saveOptions, GeneratePasswordUseCase generatePassword,
      SecretClipboard clipboard) {
    return new GeneratorViewModel(observeSettings, saveOptions, generatePassword, clipboard);
  }
}

package com.example.myapplication.presentation.root;

import com.example.myapplication.domain.usecase.auth.SignOutUseCase;
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase;
import com.example.myapplication.domain.usecase.vault.ObserveAppStateUseCase;
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
public final class RootViewModel_Factory implements Factory<RootViewModel> {
  private final Provider<ObserveAppStateUseCase> observeAppStateProvider;

  private final Provider<ObserveSettingsUseCase> observeSettingsProvider;

  private final Provider<SignOutUseCase> signOutUseCaseProvider;

  private RootViewModel_Factory(Provider<ObserveAppStateUseCase> observeAppStateProvider,
      Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SignOutUseCase> signOutUseCaseProvider) {
    this.observeAppStateProvider = observeAppStateProvider;
    this.observeSettingsProvider = observeSettingsProvider;
    this.signOutUseCaseProvider = signOutUseCaseProvider;
  }

  @Override
  public RootViewModel get() {
    return newInstance(observeAppStateProvider.get(), observeSettingsProvider.get(), signOutUseCaseProvider.get());
  }

  public static RootViewModel_Factory create(
      Provider<ObserveAppStateUseCase> observeAppStateProvider,
      Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SignOutUseCase> signOutUseCaseProvider) {
    return new RootViewModel_Factory(observeAppStateProvider, observeSettingsProvider, signOutUseCaseProvider);
  }

  public static RootViewModel newInstance(ObserveAppStateUseCase observeAppState,
      ObserveSettingsUseCase observeSettings, SignOutUseCase signOutUseCase) {
    return new RootViewModel(observeAppState, observeSettings, signOutUseCase);
  }
}

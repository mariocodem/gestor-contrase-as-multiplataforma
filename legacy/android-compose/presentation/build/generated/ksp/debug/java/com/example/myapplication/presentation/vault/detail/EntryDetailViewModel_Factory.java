package com.example.myapplication.presentation.vault.detail;

import androidx.lifecycle.SavedStateHandle;
import com.example.myapplication.domain.usecase.entry.DeleteEntryUseCase;
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase;
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase;
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
public final class EntryDetailViewModel_Factory implements Factory<EntryDetailViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<ObserveEntryUseCase> observeEntryProvider;

  private final Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider;

  private final Provider<DeleteEntryUseCase> deleteEntryProvider;

  private final Provider<SecretClipboard> clipboardProvider;

  private EntryDetailViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ObserveEntryUseCase> observeEntryProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider,
      Provider<DeleteEntryUseCase> deleteEntryProvider,
      Provider<SecretClipboard> clipboardProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.observeEntryProvider = observeEntryProvider;
    this.evaluateStrengthProvider = evaluateStrengthProvider;
    this.deleteEntryProvider = deleteEntryProvider;
    this.clipboardProvider = clipboardProvider;
  }

  @Override
  public EntryDetailViewModel get() {
    return newInstance(savedStateHandleProvider.get(), observeEntryProvider.get(), evaluateStrengthProvider.get(), deleteEntryProvider.get(), clipboardProvider.get());
  }

  public static EntryDetailViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ObserveEntryUseCase> observeEntryProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider,
      Provider<DeleteEntryUseCase> deleteEntryProvider,
      Provider<SecretClipboard> clipboardProvider) {
    return new EntryDetailViewModel_Factory(savedStateHandleProvider, observeEntryProvider, evaluateStrengthProvider, deleteEntryProvider, clipboardProvider);
  }

  public static EntryDetailViewModel newInstance(SavedStateHandle savedStateHandle,
      ObserveEntryUseCase observeEntry, EvaluatePasswordStrengthUseCase evaluateStrength,
      DeleteEntryUseCase deleteEntry, SecretClipboard clipboard) {
    return new EntryDetailViewModel(savedStateHandle, observeEntry, evaluateStrength, deleteEntry, clipboard);
  }
}

package com.example.myapplication.presentation.vault.editor;

import androidx.lifecycle.SavedStateHandle;
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase;
import com.example.myapplication.domain.usecase.entry.SaveEntryUseCase;
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase;
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
public final class EntryEditorViewModel_Factory implements Factory<EntryEditorViewModel> {
  private final Provider<SavedStateHandle> savedStateHandleProvider;

  private final Provider<ObserveEntryUseCase> observeEntryProvider;

  private final Provider<SaveEntryUseCase> saveEntryProvider;

  private final Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider;

  private EntryEditorViewModel_Factory(Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ObserveEntryUseCase> observeEntryProvider,
      Provider<SaveEntryUseCase> saveEntryProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider) {
    this.savedStateHandleProvider = savedStateHandleProvider;
    this.observeEntryProvider = observeEntryProvider;
    this.saveEntryProvider = saveEntryProvider;
    this.evaluateStrengthProvider = evaluateStrengthProvider;
  }

  @Override
  public EntryEditorViewModel get() {
    return newInstance(savedStateHandleProvider.get(), observeEntryProvider.get(), saveEntryProvider.get(), evaluateStrengthProvider.get());
  }

  public static EntryEditorViewModel_Factory create(
      Provider<SavedStateHandle> savedStateHandleProvider,
      Provider<ObserveEntryUseCase> observeEntryProvider,
      Provider<SaveEntryUseCase> saveEntryProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider) {
    return new EntryEditorViewModel_Factory(savedStateHandleProvider, observeEntryProvider, saveEntryProvider, evaluateStrengthProvider);
  }

  public static EntryEditorViewModel newInstance(SavedStateHandle savedStateHandle,
      ObserveEntryUseCase observeEntry, SaveEntryUseCase saveEntry,
      EvaluatePasswordStrengthUseCase evaluateStrength) {
    return new EntryEditorViewModel(savedStateHandle, observeEntry, saveEntry, evaluateStrength);
  }
}

package com.example.myapplication.presentation.vault.list;

import com.example.myapplication.domain.usecase.entry.ObserveEntriesUseCase;
import com.example.myapplication.domain.usecase.entry.SearchEntriesUseCase;
import com.example.myapplication.domain.usecase.vault.LockVaultUseCase;
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
public final class VaultListViewModel_Factory implements Factory<VaultListViewModel> {
  private final Provider<ObserveEntriesUseCase> observeEntriesProvider;

  private final Provider<SearchEntriesUseCase> searchEntriesProvider;

  private final Provider<LockVaultUseCase> lockVaultProvider;

  private final Provider<SecretClipboard> clipboardProvider;

  private VaultListViewModel_Factory(Provider<ObserveEntriesUseCase> observeEntriesProvider,
      Provider<SearchEntriesUseCase> searchEntriesProvider,
      Provider<LockVaultUseCase> lockVaultProvider, Provider<SecretClipboard> clipboardProvider) {
    this.observeEntriesProvider = observeEntriesProvider;
    this.searchEntriesProvider = searchEntriesProvider;
    this.lockVaultProvider = lockVaultProvider;
    this.clipboardProvider = clipboardProvider;
  }

  @Override
  public VaultListViewModel get() {
    return newInstance(observeEntriesProvider.get(), searchEntriesProvider.get(), lockVaultProvider.get(), clipboardProvider.get());
  }

  public static VaultListViewModel_Factory create(
      Provider<ObserveEntriesUseCase> observeEntriesProvider,
      Provider<SearchEntriesUseCase> searchEntriesProvider,
      Provider<LockVaultUseCase> lockVaultProvider, Provider<SecretClipboard> clipboardProvider) {
    return new VaultListViewModel_Factory(observeEntriesProvider, searchEntriesProvider, lockVaultProvider, clipboardProvider);
  }

  public static VaultListViewModel newInstance(ObserveEntriesUseCase observeEntries,
      SearchEntriesUseCase searchEntries, LockVaultUseCase lockVault, SecretClipboard clipboard) {
    return new VaultListViewModel(observeEntries, searchEntries, lockVault, clipboard);
  }
}

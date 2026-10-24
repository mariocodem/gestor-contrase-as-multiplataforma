package com.example.myapplication.domain.usecase.entry;

import com.example.myapplication.domain.repository.VaultRepository;
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
public final class ObserveEntriesUseCase_Factory implements Factory<ObserveEntriesUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private ObserveEntriesUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public ObserveEntriesUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static ObserveEntriesUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new ObserveEntriesUseCase_Factory(vaultProvider);
  }

  public static ObserveEntriesUseCase newInstance(VaultRepository vault) {
    return new ObserveEntriesUseCase(vault);
  }
}

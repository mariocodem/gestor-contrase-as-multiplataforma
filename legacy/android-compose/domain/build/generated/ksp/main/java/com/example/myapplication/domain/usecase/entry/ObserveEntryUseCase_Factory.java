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
public final class ObserveEntryUseCase_Factory implements Factory<ObserveEntryUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private ObserveEntryUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public ObserveEntryUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static ObserveEntryUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new ObserveEntryUseCase_Factory(vaultProvider);
  }

  public static ObserveEntryUseCase newInstance(VaultRepository vault) {
    return new ObserveEntryUseCase(vault);
  }
}

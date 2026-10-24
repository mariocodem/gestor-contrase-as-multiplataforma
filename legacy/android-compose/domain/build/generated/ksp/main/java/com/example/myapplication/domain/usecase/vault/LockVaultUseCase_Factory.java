package com.example.myapplication.domain.usecase.vault;

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
public final class LockVaultUseCase_Factory implements Factory<LockVaultUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private LockVaultUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public LockVaultUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static LockVaultUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new LockVaultUseCase_Factory(vaultProvider);
  }

  public static LockVaultUseCase newInstance(VaultRepository vault) {
    return new LockVaultUseCase(vault);
  }
}

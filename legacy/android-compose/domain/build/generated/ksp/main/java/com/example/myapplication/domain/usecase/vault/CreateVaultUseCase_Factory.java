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
public final class CreateVaultUseCase_Factory implements Factory<CreateVaultUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private CreateVaultUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public CreateVaultUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static CreateVaultUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new CreateVaultUseCase_Factory(vaultProvider);
  }

  public static CreateVaultUseCase newInstance(VaultRepository vault) {
    return new CreateVaultUseCase(vault);
  }
}

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
public final class SaveEntryUseCase_Factory implements Factory<SaveEntryUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private SaveEntryUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public SaveEntryUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static SaveEntryUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new SaveEntryUseCase_Factory(vaultProvider);
  }

  public static SaveEntryUseCase newInstance(VaultRepository vault) {
    return new SaveEntryUseCase(vault);
  }
}

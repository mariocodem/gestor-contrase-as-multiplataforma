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
public final class DeleteEntryUseCase_Factory implements Factory<DeleteEntryUseCase> {
  private final Provider<VaultRepository> vaultProvider;

  private DeleteEntryUseCase_Factory(Provider<VaultRepository> vaultProvider) {
    this.vaultProvider = vaultProvider;
  }

  @Override
  public DeleteEntryUseCase get() {
    return newInstance(vaultProvider.get());
  }

  public static DeleteEntryUseCase_Factory create(Provider<VaultRepository> vaultProvider) {
    return new DeleteEntryUseCase_Factory(vaultProvider);
  }

  public static DeleteEntryUseCase newInstance(VaultRepository vault) {
    return new DeleteEntryUseCase(vault);
  }
}

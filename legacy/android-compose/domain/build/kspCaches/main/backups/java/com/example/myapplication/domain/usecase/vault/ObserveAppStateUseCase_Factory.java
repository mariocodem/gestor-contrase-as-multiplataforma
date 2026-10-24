package com.example.myapplication.domain.usecase.vault;

import com.example.myapplication.domain.repository.AuthRepository;
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
public final class ObserveAppStateUseCase_Factory implements Factory<ObserveAppStateUseCase> {
  private final Provider<AuthRepository> authProvider;

  private final Provider<VaultRepository> vaultProvider;

  private ObserveAppStateUseCase_Factory(Provider<AuthRepository> authProvider,
      Provider<VaultRepository> vaultProvider) {
    this.authProvider = authProvider;
    this.vaultProvider = vaultProvider;
  }

  @Override
  public ObserveAppStateUseCase get() {
    return newInstance(authProvider.get(), vaultProvider.get());
  }

  public static ObserveAppStateUseCase_Factory create(Provider<AuthRepository> authProvider,
      Provider<VaultRepository> vaultProvider) {
    return new ObserveAppStateUseCase_Factory(authProvider, vaultProvider);
  }

  public static ObserveAppStateUseCase newInstance(AuthRepository auth, VaultRepository vault) {
    return new ObserveAppStateUseCase(auth, vault);
  }
}

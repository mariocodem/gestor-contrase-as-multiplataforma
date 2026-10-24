package com.example.myapplication.domain.usecase.auth;

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
public final class SignOutUseCase_Factory implements Factory<SignOutUseCase> {
  private final Provider<AuthRepository> authProvider;

  private final Provider<VaultRepository> vaultProvider;

  private SignOutUseCase_Factory(Provider<AuthRepository> authProvider,
      Provider<VaultRepository> vaultProvider) {
    this.authProvider = authProvider;
    this.vaultProvider = vaultProvider;
  }

  @Override
  public SignOutUseCase get() {
    return newInstance(authProvider.get(), vaultProvider.get());
  }

  public static SignOutUseCase_Factory create(Provider<AuthRepository> authProvider,
      Provider<VaultRepository> vaultProvider) {
    return new SignOutUseCase_Factory(authProvider, vaultProvider);
  }

  public static SignOutUseCase newInstance(AuthRepository auth, VaultRepository vault) {
    return new SignOutUseCase(auth, vault);
  }
}

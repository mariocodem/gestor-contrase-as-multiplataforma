package com.example.myapplication.domain.usecase.auth;

import com.example.myapplication.domain.repository.AuthRepository;
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
public final class RegisterUseCase_Factory implements Factory<RegisterUseCase> {
  private final Provider<AuthRepository> authProvider;

  private RegisterUseCase_Factory(Provider<AuthRepository> authProvider) {
    this.authProvider = authProvider;
  }

  @Override
  public RegisterUseCase get() {
    return newInstance(authProvider.get());
  }

  public static RegisterUseCase_Factory create(Provider<AuthRepository> authProvider) {
    return new RegisterUseCase_Factory(authProvider);
  }

  public static RegisterUseCase newInstance(AuthRepository auth) {
    return new RegisterUseCase(auth);
  }
}

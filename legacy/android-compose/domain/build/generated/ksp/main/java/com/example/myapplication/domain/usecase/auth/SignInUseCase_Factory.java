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
public final class SignInUseCase_Factory implements Factory<SignInUseCase> {
  private final Provider<AuthRepository> authProvider;

  private SignInUseCase_Factory(Provider<AuthRepository> authProvider) {
    this.authProvider = authProvider;
  }

  @Override
  public SignInUseCase get() {
    return newInstance(authProvider.get());
  }

  public static SignInUseCase_Factory create(Provider<AuthRepository> authProvider) {
    return new SignInUseCase_Factory(authProvider);
  }

  public static SignInUseCase newInstance(AuthRepository auth) {
    return new SignInUseCase(auth);
  }
}

package com.example.myapplication.presentation.auth;

import com.example.myapplication.domain.usecase.auth.RegisterUseCase;
import com.example.myapplication.domain.usecase.auth.SendPasswordResetUseCase;
import com.example.myapplication.domain.usecase.auth.SignInUseCase;
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
public final class AuthViewModel_Factory implements Factory<AuthViewModel> {
  private final Provider<SignInUseCase> signInProvider;

  private final Provider<RegisterUseCase> registerProvider;

  private final Provider<SendPasswordResetUseCase> sendPasswordResetProvider;

  private AuthViewModel_Factory(Provider<SignInUseCase> signInProvider,
      Provider<RegisterUseCase> registerProvider,
      Provider<SendPasswordResetUseCase> sendPasswordResetProvider) {
    this.signInProvider = signInProvider;
    this.registerProvider = registerProvider;
    this.sendPasswordResetProvider = sendPasswordResetProvider;
  }

  @Override
  public AuthViewModel get() {
    return newInstance(signInProvider.get(), registerProvider.get(), sendPasswordResetProvider.get());
  }

  public static AuthViewModel_Factory create(Provider<SignInUseCase> signInProvider,
      Provider<RegisterUseCase> registerProvider,
      Provider<SendPasswordResetUseCase> sendPasswordResetProvider) {
    return new AuthViewModel_Factory(signInProvider, registerProvider, sendPasswordResetProvider);
  }

  public static AuthViewModel newInstance(SignInUseCase signIn, RegisterUseCase register,
      SendPasswordResetUseCase sendPasswordReset) {
    return new AuthViewModel(signIn, register, sendPasswordReset);
  }
}

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
public final class ObserveCurrentUserUseCase_Factory implements Factory<ObserveCurrentUserUseCase> {
  private final Provider<AuthRepository> authProvider;

  private ObserveCurrentUserUseCase_Factory(Provider<AuthRepository> authProvider) {
    this.authProvider = authProvider;
  }

  @Override
  public ObserveCurrentUserUseCase get() {
    return newInstance(authProvider.get());
  }

  public static ObserveCurrentUserUseCase_Factory create(Provider<AuthRepository> authProvider) {
    return new ObserveCurrentUserUseCase_Factory(authProvider);
  }

  public static ObserveCurrentUserUseCase newInstance(AuthRepository auth) {
    return new ObserveCurrentUserUseCase(auth);
  }
}

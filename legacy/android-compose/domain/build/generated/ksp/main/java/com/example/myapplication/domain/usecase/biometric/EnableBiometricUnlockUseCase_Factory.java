package com.example.myapplication.domain.usecase.biometric;

import com.example.myapplication.domain.repository.BiometricRepository;
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
public final class EnableBiometricUnlockUseCase_Factory implements Factory<EnableBiometricUnlockUseCase> {
  private final Provider<BiometricRepository> biometricsProvider;

  private EnableBiometricUnlockUseCase_Factory(Provider<BiometricRepository> biometricsProvider) {
    this.biometricsProvider = biometricsProvider;
  }

  @Override
  public EnableBiometricUnlockUseCase get() {
    return newInstance(biometricsProvider.get());
  }

  public static EnableBiometricUnlockUseCase_Factory create(
      Provider<BiometricRepository> biometricsProvider) {
    return new EnableBiometricUnlockUseCase_Factory(biometricsProvider);
  }

  public static EnableBiometricUnlockUseCase newInstance(BiometricRepository biometrics) {
    return new EnableBiometricUnlockUseCase(biometrics);
  }
}

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
public final class PrepareBiometricEnrollmentUseCase_Factory implements Factory<PrepareBiometricEnrollmentUseCase> {
  private final Provider<BiometricRepository> biometricsProvider;

  private PrepareBiometricEnrollmentUseCase_Factory(
      Provider<BiometricRepository> biometricsProvider) {
    this.biometricsProvider = biometricsProvider;
  }

  @Override
  public PrepareBiometricEnrollmentUseCase get() {
    return newInstance(biometricsProvider.get());
  }

  public static PrepareBiometricEnrollmentUseCase_Factory create(
      Provider<BiometricRepository> biometricsProvider) {
    return new PrepareBiometricEnrollmentUseCase_Factory(biometricsProvider);
  }

  public static PrepareBiometricEnrollmentUseCase newInstance(BiometricRepository biometrics) {
    return new PrepareBiometricEnrollmentUseCase(biometrics);
  }
}

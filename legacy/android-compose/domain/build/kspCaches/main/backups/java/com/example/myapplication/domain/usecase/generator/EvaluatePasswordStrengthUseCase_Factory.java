package com.example.myapplication.domain.usecase.generator;

import com.example.myapplication.domain.generator.PasswordStrengthEstimator;
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
public final class EvaluatePasswordStrengthUseCase_Factory implements Factory<EvaluatePasswordStrengthUseCase> {
  private final Provider<PasswordStrengthEstimator> estimatorProvider;

  private EvaluatePasswordStrengthUseCase_Factory(
      Provider<PasswordStrengthEstimator> estimatorProvider) {
    this.estimatorProvider = estimatorProvider;
  }

  @Override
  public EvaluatePasswordStrengthUseCase get() {
    return newInstance(estimatorProvider.get());
  }

  public static EvaluatePasswordStrengthUseCase_Factory create(
      Provider<PasswordStrengthEstimator> estimatorProvider) {
    return new EvaluatePasswordStrengthUseCase_Factory(estimatorProvider);
  }

  public static EvaluatePasswordStrengthUseCase newInstance(PasswordStrengthEstimator estimator) {
    return new EvaluatePasswordStrengthUseCase(estimator);
  }
}

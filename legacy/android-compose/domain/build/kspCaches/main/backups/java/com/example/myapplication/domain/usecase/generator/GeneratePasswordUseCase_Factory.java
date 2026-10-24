package com.example.myapplication.domain.usecase.generator;

import com.example.myapplication.domain.generator.PasswordGenerator;
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
public final class GeneratePasswordUseCase_Factory implements Factory<GeneratePasswordUseCase> {
  private final Provider<PasswordGenerator> generatorProvider;

  private final Provider<PasswordStrengthEstimator> estimatorProvider;

  private GeneratePasswordUseCase_Factory(Provider<PasswordGenerator> generatorProvider,
      Provider<PasswordStrengthEstimator> estimatorProvider) {
    this.generatorProvider = generatorProvider;
    this.estimatorProvider = estimatorProvider;
  }

  @Override
  public GeneratePasswordUseCase get() {
    return newInstance(generatorProvider.get(), estimatorProvider.get());
  }

  public static GeneratePasswordUseCase_Factory create(
      Provider<PasswordGenerator> generatorProvider,
      Provider<PasswordStrengthEstimator> estimatorProvider) {
    return new GeneratePasswordUseCase_Factory(generatorProvider, estimatorProvider);
  }

  public static GeneratePasswordUseCase newInstance(PasswordGenerator generator,
      PasswordStrengthEstimator estimator) {
    return new GeneratePasswordUseCase(generator, estimator);
  }
}

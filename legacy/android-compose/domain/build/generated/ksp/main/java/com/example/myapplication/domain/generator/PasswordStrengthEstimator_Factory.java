package com.example.myapplication.domain.generator;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
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
public final class PasswordStrengthEstimator_Factory implements Factory<PasswordStrengthEstimator> {
  @Override
  public PasswordStrengthEstimator get() {
    return newInstance();
  }

  public static PasswordStrengthEstimator_Factory create() {
    return InstanceHolder.INSTANCE;
  }

  public static PasswordStrengthEstimator newInstance() {
    return new PasswordStrengthEstimator();
  }

  private static final class InstanceHolder {
    static final PasswordStrengthEstimator_Factory INSTANCE = new PasswordStrengthEstimator_Factory();
  }
}

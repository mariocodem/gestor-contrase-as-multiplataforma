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
public final class PasswordGenerator_Factory implements Factory<PasswordGenerator> {
  @Override
  public PasswordGenerator get() {
    return newInstance();
  }

  public static PasswordGenerator_Factory create() {
    return InstanceHolder.INSTANCE;
  }

  public static PasswordGenerator newInstance() {
    return new PasswordGenerator();
  }

  private static final class InstanceHolder {
    static final PasswordGenerator_Factory INSTANCE = new PasswordGenerator_Factory();
  }
}

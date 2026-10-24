package com.example.myapplication.data.crypto;

import android.content.Context;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
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
public final class BiometricKeyStore_Factory implements Factory<BiometricKeyStore> {
  private final Provider<Context> contextProvider;

  private BiometricKeyStore_Factory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public BiometricKeyStore get() {
    return newInstance(contextProvider.get());
  }

  public static BiometricKeyStore_Factory create(Provider<Context> contextProvider) {
    return new BiometricKeyStore_Factory(contextProvider);
  }

  public static BiometricKeyStore newInstance(Context context) {
    return new BiometricKeyStore(context);
  }
}

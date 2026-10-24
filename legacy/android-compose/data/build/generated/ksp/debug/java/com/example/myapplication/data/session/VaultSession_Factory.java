package com.example.myapplication.data.session;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;

@ScopeMetadata("javax.inject.Singleton")
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
public final class VaultSession_Factory implements Factory<VaultSession> {
  @Override
  public VaultSession get() {
    return newInstance();
  }

  public static VaultSession_Factory create() {
    return InstanceHolder.INSTANCE;
  }

  public static VaultSession newInstance() {
    return new VaultSession();
  }

  private static final class InstanceHolder {
    static final VaultSession_Factory INSTANCE = new VaultSession_Factory();
  }
}

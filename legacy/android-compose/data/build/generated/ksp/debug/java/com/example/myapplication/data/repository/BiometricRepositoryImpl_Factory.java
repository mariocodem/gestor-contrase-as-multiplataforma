package com.example.myapplication.data.repository;

import com.example.myapplication.data.crypto.BiometricKeyStore;
import com.example.myapplication.data.session.VaultSession;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
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
public final class BiometricRepositoryImpl_Factory implements Factory<BiometricRepositoryImpl> {
  private final Provider<BiometricKeyStore> keyStoreProvider;

  private final Provider<VaultSession> sessionProvider;

  private BiometricRepositoryImpl_Factory(Provider<BiometricKeyStore> keyStoreProvider,
      Provider<VaultSession> sessionProvider) {
    this.keyStoreProvider = keyStoreProvider;
    this.sessionProvider = sessionProvider;
  }

  @Override
  public BiometricRepositoryImpl get() {
    return newInstance(keyStoreProvider.get(), sessionProvider.get());
  }

  public static BiometricRepositoryImpl_Factory create(Provider<BiometricKeyStore> keyStoreProvider,
      Provider<VaultSession> sessionProvider) {
    return new BiometricRepositoryImpl_Factory(keyStoreProvider, sessionProvider);
  }

  public static BiometricRepositoryImpl newInstance(BiometricKeyStore keyStore,
      VaultSession session) {
    return new BiometricRepositoryImpl(keyStore, session);
  }
}

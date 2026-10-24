package com.example.myapplication.data.repository;

import com.example.myapplication.data.mapper.EntryCodec;
import com.example.myapplication.data.remote.FirestoreVaultDataSource;
import com.example.myapplication.data.session.VaultSession;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import kotlinx.coroutines.CoroutineDispatcher;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("com.example.myapplication.data.di.DefaultDispatcher")
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
public final class VaultRepositoryImpl_Factory implements Factory<VaultRepositoryImpl> {
  private final Provider<FirestoreVaultDataSource> remoteProvider;

  private final Provider<VaultSession> sessionProvider;

  private final Provider<EntryCodec> codecProvider;

  private final Provider<CoroutineDispatcher> cryptoDispatcherProvider;

  private VaultRepositoryImpl_Factory(Provider<FirestoreVaultDataSource> remoteProvider,
      Provider<VaultSession> sessionProvider, Provider<EntryCodec> codecProvider,
      Provider<CoroutineDispatcher> cryptoDispatcherProvider) {
    this.remoteProvider = remoteProvider;
    this.sessionProvider = sessionProvider;
    this.codecProvider = codecProvider;
    this.cryptoDispatcherProvider = cryptoDispatcherProvider;
  }

  @Override
  public VaultRepositoryImpl get() {
    return newInstance(remoteProvider.get(), sessionProvider.get(), codecProvider.get(), cryptoDispatcherProvider.get());
  }

  public static VaultRepositoryImpl_Factory create(
      Provider<FirestoreVaultDataSource> remoteProvider, Provider<VaultSession> sessionProvider,
      Provider<EntryCodec> codecProvider, Provider<CoroutineDispatcher> cryptoDispatcherProvider) {
    return new VaultRepositoryImpl_Factory(remoteProvider, sessionProvider, codecProvider, cryptoDispatcherProvider);
  }

  public static VaultRepositoryImpl newInstance(FirestoreVaultDataSource remote,
      VaultSession session, EntryCodec codec, CoroutineDispatcher cryptoDispatcher) {
    return new VaultRepositoryImpl(remote, session, codec, cryptoDispatcher);
  }
}

package com.example.myapplication.data.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;
import kotlinx.coroutines.CoroutineDispatcher;
import kotlinx.coroutines.CoroutineScope;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata({
    "com.example.myapplication.data.di.ApplicationScope",
    "com.example.myapplication.data.di.DefaultDispatcher"
})
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
public final class PlatformModule_ProvideApplicationScopeFactory implements Factory<CoroutineScope> {
  private final Provider<CoroutineDispatcher> dispatcherProvider;

  private PlatformModule_ProvideApplicationScopeFactory(
      Provider<CoroutineDispatcher> dispatcherProvider) {
    this.dispatcherProvider = dispatcherProvider;
  }

  @Override
  public CoroutineScope get() {
    return provideApplicationScope(dispatcherProvider.get());
  }

  public static PlatformModule_ProvideApplicationScopeFactory create(
      Provider<CoroutineDispatcher> dispatcherProvider) {
    return new PlatformModule_ProvideApplicationScopeFactory(dispatcherProvider);
  }

  public static CoroutineScope provideApplicationScope(CoroutineDispatcher dispatcher) {
    return Preconditions.checkNotNullFromProvides(PlatformModule.INSTANCE.provideApplicationScope(dispatcher));
  }
}

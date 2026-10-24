package com.example.myapplication.data.di;

import android.content.Context;
import androidx.datastore.core.DataStore;
import androidx.datastore.preferences.core.Preferences;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
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
public final class PlatformModule_ProvideSettingsDataStoreFactory implements Factory<DataStore<Preferences>> {
  private final Provider<Context> contextProvider;

  private PlatformModule_ProvideSettingsDataStoreFactory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public DataStore<Preferences> get() {
    return provideSettingsDataStore(contextProvider.get());
  }

  public static PlatformModule_ProvideSettingsDataStoreFactory create(
      Provider<Context> contextProvider) {
    return new PlatformModule_ProvideSettingsDataStoreFactory(contextProvider);
  }

  public static DataStore<Preferences> provideSettingsDataStore(Context context) {
    return Preconditions.checkNotNullFromProvides(PlatformModule.INSTANCE.provideSettingsDataStore(context));
  }
}

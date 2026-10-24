package com.example.myapplication.presentation.common;

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
public final class AndroidSecretClipboard_Factory implements Factory<AndroidSecretClipboard> {
  private final Provider<Context> contextProvider;

  private AndroidSecretClipboard_Factory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public AndroidSecretClipboard get() {
    return newInstance(contextProvider.get());
  }

  public static AndroidSecretClipboard_Factory create(Provider<Context> contextProvider) {
    return new AndroidSecretClipboard_Factory(contextProvider);
  }

  public static AndroidSecretClipboard newInstance(Context context) {
    return new AndroidSecretClipboard(context);
  }
}

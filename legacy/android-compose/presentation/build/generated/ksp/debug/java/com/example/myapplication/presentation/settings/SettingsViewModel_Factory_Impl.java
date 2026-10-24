package com.example.myapplication.presentation.settings;

import com.example.myapplication.domain.model.User;
import dagger.internal.DaggerGenerated;
import dagger.internal.InstanceFactory;
import javax.annotation.processing.Generated;
import javax.inject.Provider;

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
public final class SettingsViewModel_Factory_Impl implements SettingsViewModel.Factory {
  private final SettingsViewModel_Factory delegateFactory;

  SettingsViewModel_Factory_Impl(SettingsViewModel_Factory delegateFactory) {
    this.delegateFactory = delegateFactory;
  }

  @Override
  public SettingsViewModel create(User user) {
    return delegateFactory.get(user);
  }

  public static Provider<SettingsViewModel.Factory> create(
      SettingsViewModel_Factory delegateFactory) {
    return InstanceFactory.create(new SettingsViewModel_Factory_Impl(delegateFactory));
  }

  public static dagger.internal.Provider<SettingsViewModel.Factory> createFactoryProvider(
      SettingsViewModel_Factory delegateFactory) {
    return InstanceFactory.create(new SettingsViewModel_Factory_Impl(delegateFactory));
  }
}

package com.example.myapplication.presentation.lock;

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
public final class LockViewModel_Factory_Impl implements LockViewModel.Factory {
  private final LockViewModel_Factory delegateFactory;

  LockViewModel_Factory_Impl(LockViewModel_Factory delegateFactory) {
    this.delegateFactory = delegateFactory;
  }

  @Override
  public LockViewModel create(User user) {
    return delegateFactory.get(user);
  }

  public static Provider<LockViewModel.Factory> create(LockViewModel_Factory delegateFactory) {
    return InstanceFactory.create(new LockViewModel_Factory_Impl(delegateFactory));
  }

  public static dagger.internal.Provider<LockViewModel.Factory> createFactoryProvider(
      LockViewModel_Factory delegateFactory) {
    return InstanceFactory.create(new LockViewModel_Factory_Impl(delegateFactory));
  }
}

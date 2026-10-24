package com.example.myapplication.domain.usecase.entry;

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
public final class SearchEntriesUseCase_Factory implements Factory<SearchEntriesUseCase> {
  @Override
  public SearchEntriesUseCase get() {
    return newInstance();
  }

  public static SearchEntriesUseCase_Factory create() {
    return InstanceHolder.INSTANCE;
  }

  public static SearchEntriesUseCase newInstance() {
    return new SearchEntriesUseCase();
  }

  private static final class InstanceHolder {
    static final SearchEntriesUseCase_Factory INSTANCE = new SearchEntriesUseCase_Factory();
  }
}

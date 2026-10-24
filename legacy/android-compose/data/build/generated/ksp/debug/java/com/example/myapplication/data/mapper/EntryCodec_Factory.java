package com.example.myapplication.data.mapper;

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
public final class EntryCodec_Factory implements Factory<EntryCodec> {
  @Override
  public EntryCodec get() {
    return newInstance();
  }

  public static EntryCodec_Factory create() {
    return InstanceHolder.INSTANCE;
  }

  public static EntryCodec newInstance() {
    return new EntryCodec();
  }

  private static final class InstanceHolder {
    static final EntryCodec_Factory INSTANCE = new EntryCodec_Factory();
  }
}

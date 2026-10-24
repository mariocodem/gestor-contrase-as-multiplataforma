package com.example.myapplication.data.remote;

import com.google.firebase.firestore.FirebaseFirestore;
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
public final class FirestoreVaultDataSource_Factory implements Factory<FirestoreVaultDataSource> {
  private final Provider<FirebaseFirestore> dbProvider;

  private FirestoreVaultDataSource_Factory(Provider<FirebaseFirestore> dbProvider) {
    this.dbProvider = dbProvider;
  }

  @Override
  public FirestoreVaultDataSource get() {
    return newInstance(dbProvider.get());
  }

  public static FirestoreVaultDataSource_Factory create(Provider<FirebaseFirestore> dbProvider) {
    return new FirestoreVaultDataSource_Factory(dbProvider);
  }

  public static FirestoreVaultDataSource newInstance(FirebaseFirestore db) {
    return new FirestoreVaultDataSource(db);
  }
}

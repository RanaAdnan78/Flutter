import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../models/invoice_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  // Safe getter for Firestore instance
  FirebaseFirestore? get _db {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirestoreService: Firebase not initialized: $e');
      return null;
    }
  }

  // Users
  Future<UserModel?> getUser(String uid) async {
    final db = _db;
    if (db == null) return null;
    
    try {
      final doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('FirestoreService: getUser error: $e');
    }
    return null;
  }

  Future<void> createUser(UserModel user) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint('FirestoreService: createUser error: $e');
    }
  }

  // Companies
  Future<void> addCompany(CompanyModel company) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(company.userId)
          .collection('companies')
          .doc(company.id)
          .set(company.toMap());
    } catch (e) {
      debugPrint('FirestoreService: addCompany error: $e');
    }
  }

  Future<void> updateCompany(CompanyModel company) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(company.userId)
          .collection('companies')
          .doc(company.id)
          .update(company.toMap());
    } catch (e) {
      debugPrint('FirestoreService: updateCompany error: $e');
    }
  }

  Future<void> deleteCompany(String userId, String companyId) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(companyId)
          .delete();
    } catch (e) {
      debugPrint('FirestoreService: deleteCompany error: $e');
    }
  }

  Stream<List<CompanyModel>> getCompaniesStream(String userId) {
    final db = _db;
    if (db == null) {
      return Stream.value([]);
    }
    
    try {
      return db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CompanyModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('FirestoreService: getCompaniesStream error: $e');
      return Stream.value([]);
    }
  }

  // Invoices
  Future<void> addInvoice(String userId, InvoiceModel invoice) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(invoice.companyId)
          .collection('invoices')
          .doc(invoice.id)
          .set(invoice.toMap());
    } catch (e) {
      debugPrint('FirestoreService: addInvoice error: $e');
    }
  }

  Future<void> updateInvoice(String userId, InvoiceModel invoice) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(invoice.companyId)
          .collection('invoices')
          .doc(invoice.id)
          .update(invoice.toMap());
    } catch (e) {
      debugPrint('FirestoreService: updateInvoice error: $e');
    }
  }

  Future<void> deleteInvoice(String userId, String companyId, String invoiceId) async {
    final db = _db;
    if (db == null) return;
    
    try {
      await db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(companyId)
          .collection('invoices')
          .doc(invoiceId)
          .delete();
    } catch (e) {
      debugPrint('FirestoreService: deleteInvoice error: $e');
    }
  }

  Stream<List<InvoiceModel>> getInvoicesStream(String userId, String companyId) {
    final db = _db;
    if (db == null) {
      return Stream.value([]);
    }
    
    try {
      return db
          .collection('users')
          .doc(userId)
          .collection('companies')
          .doc(companyId)
          .collection('invoices')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => InvoiceModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      debugPrint('FirestoreService: getInvoicesStream error: $e');
      return Stream.value([]);
    }
  }
}

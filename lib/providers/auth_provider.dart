import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 現在のユーザー
  User? _user;
  User? get user => _user;
  
  // 認証状態
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous == true;
  
  // ローディング状態
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // エラーメッセージ
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 認証状態の監視
  StreamSubscription<User?>? _authSubscription;
  
  AuthProvider() {
    _initializeAuthState();
  }
  
  // 認証状態の初期化と監視
  void _initializeAuthState() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
      
      if (user != null) {
        if (user.isAnonymous) {
          print('🔓 匿名ユーザーでログイン中: ${user.uid}');
        } else {
          print('✅ 認証済みユーザー: ${user.email} (${user.uid})');
        }
      } else {
        print('❌ ユーザーがログアウトしました');
      }
    });
    
    // 初期状態の設定
    _user = _auth.currentUser;
  }
  
  // メールアドレスとパスワードでログイン
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        print('✅ ログイン成功: ${credential.user!.email}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'ログイン中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // メールアドレスとパスワードでサインアップ
  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        print('✅ アカウント作成成功: ${credential.user!.email}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'アカウント作成中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 匿名認証
  Future<bool> signInAnonymously() async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        print('🔓 匿名ログイン成功: ${credential.user!.uid}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = '匿名ログイン中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ログアウト
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.signOut();
      print('👋 ログアウトしました');
      return true;
    } catch (e) {
      _errorMessage = 'ログアウト中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // パスワードリセット
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('📧 パスワードリセットメールを送信しました: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'パスワードリセット中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ユーザープロフィール更新
  Future<bool> updateProfile({String? displayName}) async {
    try {
      if (_user == null) return false;
      
      _setLoading(true);
      _clearError();
      
      await _user!.updateDisplayName(displayName);
      await _user!.reload();
      _user = _auth.currentUser;
      
      notifyListeners();
      print('✅ プロフィール更新完了');
      return true;
    } catch (e) {
      _errorMessage = 'プロフィール更新中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 匿名アカウントを正式アカウントに変換
  Future<bool> linkAnonymousWithEmail(String email, String password) async {
    try {
      if (_user == null || !_user!.isAnonymous) {
        _errorMessage = '匿名アカウントでログインしていません';
        notifyListeners();
        return false;
      }
      
      _setLoading(true);
      _clearError();
      
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      
      await _user!.linkWithCredential(credential);
      await _user!.reload();
      _user = _auth.currentUser;
      
      notifyListeners();
      print('✅ 匿名アカウントを正式アカウントに変換しました');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'アカウント変換中にエラーが発生しました: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Firebase認証エラーのハンドリング
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'このメールアドレスは登録されていません';
        break;
      case 'wrong-password':
        _errorMessage = 'パスワードが間違っています';
        break;
      case 'email-already-in-use':
        _errorMessage = 'このメールアドレスは既に使用されています';
        break;
      case 'weak-password':
        _errorMessage = 'パスワードが簡単すぎます（6文字以上を推奨）';
        break;
      case 'invalid-email':
        _errorMessage = 'メールアドレスの形式が正しくありません';
        break;
      case 'user-disabled':
        _errorMessage = 'このアカウントは無効になっています';
        break;
      case 'too-many-requests':
        _errorMessage = 'リクエストが多すぎます。しばらく待ってから再試行してください';
        break;
      case 'network-request-failed':
        _errorMessage = 'ネットワークエラーが発生しました';
        break;
      default:
        _errorMessage = '認証エラーが発生しました: ${e.message}';
    }
    notifyListeners();
  }
  
  // ローディング状態の設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // エラーメッセージのクリア
  void _clearError() {
    _errorMessage = null;
  }
  
  // エラーメッセージを手動でクリア
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
} 
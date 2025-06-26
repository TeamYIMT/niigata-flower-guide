using UnityEngine;
using System;
using System.Runtime.InteropServices;

namespace FlutterUnityWidget
{
    public class FlutterUnityWidget : MonoBehaviour
    {
        public static FlutterUnityWidget Instance { get; private set; }
        
        public event Action<string> OnFlutterMessage;
        public event Action OnFlutterReady;
        
        private bool _isFlutterReady = false;
        
        void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
            }
        }
        
        void Start()
        {
            // Flutterが準備完了したことを通知
            _isFlutterReady = true;
            OnFlutterReady?.Invoke();
            Debug.Log("Flutter Unity Widget initialized");
        }
        
        // Flutterからのメッセージを受信
        public void OnMessage(string message)
        {
            Debug.Log($"Received message from Flutter: {message}");
            OnFlutterMessage?.Invoke(message);
        }
        
        // Flutterにメッセージを送信
        public void SendMessageToFlutter(string message)
        {
            if (!_isFlutterReady)
            {
                Debug.LogWarning("Flutter is not ready yet");
                return;
            }
            
            try
            {
                // ネイティブプラットフォームでのメッセージ送信
                if (Application.platform == RuntimePlatform.Android)
                {
                    SendMessageToFlutterAndroid(message);
                }
                else if (Application.platform == RuntimePlatform.IPhonePlayer)
                {
                    SendMessageToFlutterIOS(message);
                }
                else
                {
                    Debug.Log($"Would send to Flutter: {message}");
                }
            }
            catch (Exception e)
            {
                Debug.LogError($"Error sending message to Flutter: {e.Message}");
            }
        }
        
        // Android用のメッセージ送信
        [DllImport("flutter_unity_widget")]
        private static extern void SendMessageToFlutterAndroid(string message);
        
        // iOS用のメッセージ送信
        [DllImport("__Internal")]
        private static extern void SendMessageToFlutterIOS(string message);
        
        // テスト用メソッド
        public void SendTestMessage()
        {
            SendMessageToFlutter("Test message from Unity!");
        }
    }
} 
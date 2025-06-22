using UnityEngine;
using System;

public class FlutterReceiver : MonoBehaviour
{
    [SerializeField] private GameObject messageDisplay;
    [SerializeField] private TMPro.TextMeshProUGUI messageText;
    
    private void Start()
    {
        // FlutterにUnityが準備完了したことを通知
        SendMessageToFlutter("Unity is ready!");
        
        if (messageDisplay != null)
            messageDisplay.SetActive(false);
    }
    
    // Flutterからのメッセージを受信
    public void OnMessage(string message)
    {
        Debug.Log($"Received message from Flutter: {message}");
        
        // UIにメッセージを表示
        if (messageText != null)
        {
            messageText.text = $"Flutter: {message}";
            if (messageDisplay != null)
                messageDisplay.SetActive(true);
        }
        
        // Flutterに応答を送信
        SendMessageToFlutter($"Received: {message}");
    }
    
    // Flutterにメッセージを送信
    private void SendMessageToFlutter(string message)
    {
        try
        {
            // flutter_unity_widgetのメッセージ送信機能を使用
            if (Application.platform == RuntimePlatform.Android || 
                Application.platform == RuntimePlatform.IPhonePlayer)
            {
                // ネイティブプラットフォーム用
                SendMessage("FlutterReceiver", "OnUnityMessage", message);
            }
            else
            {
                // エディタ用（デバッグ用）
                Debug.Log($"Would send to Flutter: {message}");
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"Error sending message to Flutter: {e.Message}");
        }
    }
    
    // テスト用のボタンイベント
    public void SendTestMessage()
    {
        SendMessageToFlutter("Test message from Unity!");
    }
    
    // シーン変更時の処理
    private void OnEnable()
    {
        SendMessageToFlutter("Unity scene loaded");
    }
} 
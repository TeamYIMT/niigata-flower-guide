using UnityEngine;
using System;
using TMPro;
using FlutterUnityWidget;

public class FlutterReceiver : MonoBehaviour
{
    [SerializeField] private GameObject messageDisplay;
    [SerializeField] private TextMeshProUGUI messageText;
    
    private void Start()
    {
        // Flutter Unity Widgetのイベントを購読
        if (FlutterUnityWidget.FlutterUnityWidget.Instance != null)
        {
            FlutterUnityWidget.FlutterUnityWidget.Instance.OnFlutterMessage += OnFlutterMessage;
            FlutterUnityWidget.FlutterUnityWidget.Instance.OnFlutterReady += OnFlutterReady;
        }
        
        if (messageDisplay != null)
            messageDisplay.SetActive(false);
    }
    
    private void OnDestroy()
    {
        // イベントの購読を解除
        if (FlutterUnityWidget.FlutterUnityWidget.Instance != null)
        {
            FlutterUnityWidget.FlutterUnityWidget.Instance.OnFlutterMessage -= OnFlutterMessage;
            FlutterUnityWidget.FlutterUnityWidget.Instance.OnFlutterReady -= OnFlutterReady;
        }
    }
    
    private void OnFlutterReady()
    {
        Debug.Log("Flutter is ready!");
        // FlutterにUnityが準備完了したことを通知
        SendMessageToFlutter("Unity is ready!");
    }
    
    private void OnFlutterMessage(string message)
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
    
    // Flutterからのメッセージを受信（レガシー用）
    public void OnMessage(string message)
    {
        OnFlutterMessage(message);
    }
    
    // Flutterにメッセージを送信
    private void SendMessageToFlutter(string message)
    {
        if (FlutterUnityWidget.FlutterUnityWidget.Instance != null)
        {
            FlutterUnityWidget.FlutterUnityWidget.Instance.SendMessageToFlutter(message);
        }
        else
        {
            Debug.LogWarning("FlutterUnityWidget instance not found");
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

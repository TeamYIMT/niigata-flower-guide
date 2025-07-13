using UnityEngine;
using UnityEngine.UI;
using FlutterUnityWidget;

public class SimpleTestScene : MonoBehaviour
{
    [SerializeField] private Text statusText;
    [SerializeField] private Button testButton;
    [SerializeField] private GameObject cube;
    
    private void Start()
    {
        // UIの初期化
        if (statusText != null)
            statusText.text = "Unity Scene Loaded";
            
        if (testButton != null)
            testButton.onClick.AddListener(OnTestButtonClick);
            
        // 簡単な3Dオブジェクトを作成
        CreateTestCube();
        
        Debug.Log("Simple test scene initialized");
    }
    
    private void CreateTestCube()
    {
        if (cube == null)
        {
            // キューブを作成
            GameObject testCube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            testCube.name = "TestCube";
            testCube.transform.position = new Vector3(0, 0, 5);
            testCube.transform.localScale = Vector3.one * 2f;
            
            // マテリアルを設定
            Renderer renderer = testCube.GetComponent<Renderer>();
            if (renderer != null)
            {
                Material material = new Material(Shader.Find("Standard"));
                material.color = Color.blue;
                renderer.material = material;
            }
            
            // 回転アニメーションを追加
            testCube.AddComponent<RotateObject>();
        }
    }
    
    private void OnTestButtonClick()
    {
        Debug.Log("Test button clicked");
        if (FlutterUnityWidget.FlutterUnityWidget.Instance != null)
        {
            FlutterUnityWidget.FlutterUnityWidget.Instance.SendMessageToFlutter("Button clicked in Unity!");
        }
        
        if (statusText != null)
            statusText.text = "Button Clicked!";
    }
}

// キューブを回転させるスクリプト
public class RotateObject : MonoBehaviour
{
    public float rotationSpeed = 50f;
    
    void Update()
    {
        transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
    }
} 

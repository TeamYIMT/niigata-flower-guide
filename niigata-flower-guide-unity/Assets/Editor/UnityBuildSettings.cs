using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.Build.Reporting;

public class UnityBuildSettings
{
    [MenuItem("Flutter/Build for Android")]
    public static void BuildForAndroid()
    {
        // ビルド設定
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = GetEnabledScenes();
        buildPlayerOptions.locationPathName = "Builds/Android";
        buildPlayerOptions.target = BuildTarget.Android;
        buildPlayerOptions.options = BuildOptions.None;

        // ビルド実行
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildResult result = report.summary.result;

        if (result == BuildResult.Succeeded)
        {
            Debug.Log("Android build completed successfully!");
            Debug.Log($"Build location: {buildPlayerOptions.locationPathName}");
        }
        else
        {
            Debug.LogError("Android build failed!");
        }
    }

    [MenuItem("Flutter/Build for iOS")]
    public static void BuildForIOS()
    {
        // Flutter Unity Widget用のiOS設定を適用
        SetupBuildSettings();
        SetupIOSSpecificSettings();
        
        // ビルド設定
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = GetEnabledScenes();
        buildPlayerOptions.locationPathName = "Builds/iOS";
        buildPlayerOptions.target = BuildTarget.iOS;
        // Flutter Unity Widget用のビルドオプション
        buildPlayerOptions.options = BuildOptions.None;

        // ビルド実行
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildResult result = report.summary.result;

        if (result == BuildResult.Succeeded)
        {
            Debug.Log("iOS build completed successfully!");
            Debug.Log($"Build location: {buildPlayerOptions.locationPathName}");
            
            // Flutter Unity Widget用の追加設定
            PostProcessIOSBuild(buildPlayerOptions.locationPathName);
        }
        else
        {
            Debug.LogError("iOS build failed!");
        }
    }
    
    private static void SetupIOSSpecificSettings()
    {
        // iOS固有の設定
        PlayerSettings.iOS.targetDevice = iOSTargetDevice.iPhoneAndiPad;
        PlayerSettings.iOS.targetOSVersionString = "12.0";
        PlayerSettings.iOS.buildNumber = "1";
        
        // Flutter Unity Widget用の設定
        PlayerSettings.iOS.locationUsageDescription = "This app uses location for AR features";
        PlayerSettings.iOS.cameraUsageDescription = "This app uses camera for AR features";
        
        // Metal設定
        PlayerSettings.SetGraphicsAPIs(BuildTarget.iOS, new UnityEngine.Rendering.GraphicsDeviceType[] { 
            UnityEngine.Rendering.GraphicsDeviceType.Metal 
        });
        
        // Architecture設定
        PlayerSettings.iOS.sdkVersion = iOSSdkVersion.DeviceSDK;
        
        // Scripting Backend設定（重要）
        PlayerSettings.SetScriptingBackend(BuildTargetGroup.iOS, ScriptingImplementation.IL2CPP);
        
        // Strip Engine Code設定（重要）
        PlayerSettings.stripEngineCode = false;
        
        Debug.Log("iOS specific settings configured");
    }
    
    private static void PostProcessIOSBuild(string buildPath)
    {
        Debug.Log($"Post-processing iOS build at: {buildPath}");
        
        // UnityFramework.frameworkが正しく生成されているか確認
        string frameworkPath = Path.Combine(buildPath, "UnityFramework.framework");
        if (Directory.Exists(frameworkPath))
        {
            Debug.Log("UnityFramework.framework found successfully");
        }
        else
        {
            Debug.LogWarning("UnityFramework.framework not found in build output");
        }
    }

    private static string[] GetEnabledScenes()
    {
        var scenes = new System.Collections.Generic.List<string>();
        
        // Build Settingsからシーンを取得
        for (int i = 0; i < EditorBuildSettings.scenes.Length; i++)
        {
            if (EditorBuildSettings.scenes[i].enabled)
            {
                scenes.Add(EditorBuildSettings.scenes[i].path);
            }
        }
        
        // ビルド設定にシーンがない場合は、デフォルトシーンを使用
        if (scenes.Count == 0)
        {
            Debug.LogWarning("No scenes found in Build Settings. Adding default scenes.");
            
            // デフォルトシーンを追加
            string[] defaultScenes = {
                "Assets/Scenes/ARDemo.unity",
                "Assets/Scenes/SampleScene.unity"
            };
            
            var buildSettingsScenes = new System.Collections.Generic.List<EditorBuildSettingsScene>();
            
            foreach (string scenePath in defaultScenes)
            {
                if (File.Exists(scenePath))
                {
                    scenes.Add(scenePath);
                    buildSettingsScenes.Add(new EditorBuildSettingsScene(scenePath, true));
                    Debug.Log($"Added scene to build: {scenePath}");
                }
            }
            
            // Build Settingsを更新
            EditorBuildSettings.scenes = buildSettingsScenes.ToArray();
        }
        
        if (scenes.Count == 0)
        {
            Debug.LogError("No valid scenes found for build!");
        }
        
        return scenes.ToArray();
    }

    [MenuItem("Flutter/Setup Build Settings")]
    public static void SetupBuildSettings()
    {
        // Player Settings for Flutter Unity Widget
#if UNITY_2019_3_OR_NEWER
        PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.Android, "com.example.niigata_flower_guide");
        PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.iOS, "com.example.niigataFlowerGuide");
#else
        PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.example.niigata_flower_guide");
        PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.iOS, "com.example.niigataFlowerGuide");
#endif
        
        // Android設定
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel23;
        PlayerSettings.Android.targetSdkVersion = AndroidSdkVersions.AndroidApiLevel33;
        
        // iOS設定
        PlayerSettings.iOS.targetDevice = iOSTargetDevice.iPhoneAndiPad;
        PlayerSettings.iOS.targetOSVersionString = "12.0";
        
        // その他の設定
        PlayerSettings.companyName = "Niigata Flower Guide";
        PlayerSettings.productName = "Niigata Flower Guide";
        
        Debug.Log("Build settings configured for Flutter Unity Widget");
    }
} 

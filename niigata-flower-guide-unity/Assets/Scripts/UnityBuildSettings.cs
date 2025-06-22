using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.Build.Reporting;

public class UnityBuildSettings : MonoBehaviour
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
        // ビルド設定
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = GetEnabledScenes();
        buildPlayerOptions.locationPathName = "Builds/iOS";
        buildPlayerOptions.target = BuildTarget.iOS;
        buildPlayerOptions.options = BuildOptions.None;

        // ビルド実行
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildResult result = report.summary.result;

        if (result == BuildResult.Succeeded)
        {
            Debug.Log("iOS build completed successfully!");
            Debug.Log($"Build location: {buildPlayerOptions.locationPathName}");
        }
        else
        {
            Debug.LogError("iOS build failed!");
        }
    }

    private static string[] GetEnabledScenes()
    {
        var scenes = new System.Collections.Generic.List<string>();
        for (int i = 0; i < EditorBuildSettings.scenes.Length; i++)
        {
            if (EditorBuildSettings.scenes[i].enabled)
            {
                scenes.Add(EditorBuildSettings.scenes[i].path);
            }
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
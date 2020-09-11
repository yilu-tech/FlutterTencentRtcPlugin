import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'entity/video_enc_param_entity.dart';

class TencentRtcPlugin {
  static const MethodChannel _channel = const MethodChannel('tencent_rtc_plugin');

  /// 监听器对象
  static _TencentRtcPluginListener _listener;

  static Future<void> destroy() async {
    return await _channel.invokeMethod('destroy');
  }

  /// 添加消息监听
  static void addListener(TencentRtcPluginListener listener) {
    if (_listener == null) {
      _listener = _TencentRtcPluginListener(_channel);
    }
    _listener.addListener(listener);
  }

  /// 移除消息监听
  static void removeListener(TencentRtcPluginListener listener) {
    if (_listener == null) {
      _listener = _TencentRtcPluginListener(_channel);
    }
    _listener.removeListener(listener);
  }

  /// 设置Debug视图
  static Future<void> showDebugView({
    @required int mode, // 模式
  }) async {
    return await _channel.invokeMethod('showDebugView', {"mode": mode});
  }

  /// 设置启用控制台打印
  static Future<void> setConsoleEnabled({
    @required bool enabled, // 是否启用
  }) async {
    return await _channel.invokeMethod('setConsoleEnabled', {
      "enabled": enabled,
    });
  }

  /// 加入房间(默认开启音频接收)
  static Future<void> enterRoom({
    @required int appid, // appid
    @required String userId, // 用户id
    @required String userSig, // 用户签名
    @required int roomId, // 房间号
    @required int scene, // 应用场景，目前支持视频通话（VideoCall）和在线直播（Live）两种场景。
    int role, // 角色
    String privateMapKey, // 房间签名 [非必填]
  }) async {
    return await _channel.invokeMethod('enterRoom', {
      "appid": appid,
      "userId": userId,
      "userSig": userSig,
      "roomId": roomId,
      "scene": scene,
      "role": role,
      "privateMapKey": privateMapKey,
    });
  }

  /// 离开房间
  static Future<void> exitRoom() async {
    return await _channel.invokeMethod('exitRoom');
  }

  /// 切换角色，仅适用于直播场景（TRTCAppSceneLIVE）。
  static Future<void> switchRole({
    @required int role, // 目标角色
  }) async {
    return await _channel.invokeMethod('switchRole', {
      "role": role,
    });
  }

  /// 设置音视频数据接收模式（需要在进房前设置才能生效）。
  /// 默认进房后自动接收音视频
  static Future<void> setDefaultStreamRecvMode({
    @required bool autoRecvAudio, // true：自动接收音频数据；false：需要调用 muteRemoteAudio 进行请求或取消。默认值：true。
    @required bool autoRecvVideo, // true：自动接收视频数据；false：需要调用 startRemoteView/stopRemoteView 进行请求或取消。默认值：true。
  }) async {
    return await _channel.invokeMethod('setDefaultStreamRecvMode', {
      "autoRecvAudio": autoRecvAudio,
      "autoRecvVideo": autoRecvVideo,
    });
  }

  /// 静音/取消静音
  static Future<void> muteRemoteAudio({
    @required String userId, // 用户id
    @required bool mute, // true静音，false静音
  }) async {
    return await _channel.invokeMethod('muteRemoteAudio', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// 静音/取消静音 所有用户
  static Future<void> muteAllRemoteAudio({
    @required bool mute, // true静音，false静音
  }) async {
    return await _channel.invokeMethod('muteAllRemoteAudio', {
      "mute": mute,
    });
  }

  /// 设置远程视频填充模式
  static Future<void> setRemoteViewFillMode({
    @required String userId, // 用户ID
    @required int mode, // 模式
  }) async {
    return await _channel.invokeMethod('setRemoteViewFillMode', {
      "userId": userId,
      "mode": mode,
    });
  }

  /// 设置本地视频填充模式
  static Future<void> setLocalViewFillMode({
    @required int mode, // 模式
  }) async {
    return await _channel.invokeMethod('setLocalViewFillMode', {
      "mode": mode,
    });
  }

  /// 开启本地音频采集
  static Future<void> startLocalAudio() async {
    return await _channel.invokeMethod('startLocalAudio');
  }

  /// 关闭本地音频采集
  static Future<void> stopLocalAudio() async {
    return await _channel.invokeMethod('stopLocalAudio');
  }

  /// 停止显示所有远端视频画面。
  static Future<void> stopAllRemoteView() async {
    return _channel.invokeMethod('stopAllRemoteView');
  }

  /// 暂停接收指定的远端视频流。。
  static Future<void> muteRemoteVideoStream({
    @required String userId, // 用户ID
    @required bool mute, // 是否停止接收
  }) async {
    return _channel.invokeMethod('muteRemoteVideoStream', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// 停止接收所有远端视频流
  static Future<void> muteAllRemoteVideoStreams({
    @required bool mute, // 是否停止接收
  }) async {
    return _channel.invokeMethod('muteAllRemoteVideoStreams', {
      "mute": mute,
    });
  }

  /// 设置视频编码相关
  static Future<void> setVideoEncoderParam({
    @required VideoEncParamEntity param, // 视频编码参数，详情请参考 TRTCCloudDef.java 中的 TRTCVideoEncParam 定义。
  }) async {
    return _channel.invokeMethod('setVideoEncoderParam', {
      "param": param.toString(),
    });
  }

  /// 设置网络流控相关参数。
  static Future<void> setNetworkQosParam({
    @required int preference, // 弱网下是“保清晰”还是“保流畅”。
    @required int controlMode, // 视频分辨率（云端控制 - 客户端控制）。
  }) async {
    return _channel.invokeMethod('setNetworkQosParam', {
      "preference": preference,
      "controlMode": controlMode,
    });
  }

  /// 设置本地图像的顺时针旋转角度。
  static Future<void> setLocalViewRotation({
    @required int rotation, // rotation 支持 TRTC_VIDEO_ROTATION_90、TRTC_VIDEO_ROTATION_180、TRTC_VIDEO_ROTATION_270 旋转角度，默认值：TRTC_VIDEO_ROTATION_0。。
  }) async {
    return _channel.invokeMethod('setLocalViewRotation', {
      "rotation": rotation,
    });
  }

  /// 设置远端图像的顺时针旋转角度。
  static Future<void> setRemoteViewRotation({
    @required String userId, // 用户ID
    @required int rotation, // rotation 支持 TRTC_VIDEO_ROTATION_90、TRTC_VIDEO_ROTATION_180、TRTC_VIDEO_ROTATION_270 旋转角度，默认值：TRTC_VIDEO_ROTATION_0。。
  }) async {
    return _channel.invokeMethod('setRemoteViewRotation', {
      "userId": userId,
      "rotation": rotation,
    });
  }

  /// 设置视频编码输出的（也就是远端用户观看到的，以及服务器录制下来的）画面方向
  static Future<void> setVideoEncoderRotation({
    @required int rotation, // 目前支持 TRTC_VIDEO_ROTATION_0 和 TRTC_VIDEO_ROTATION_180 两个旋转角度，默认值：TRTC_VIDEO_ROTATION_0。
  }) async {
    return _channel.invokeMethod('setVideoEncoderRotation', {
      "rotation": rotation,
    });
  }

  /// 设置本地摄像头预览画面的镜像模式。
  static Future<void> setLocalViewMirror({
    @required int mirrorType, // mirrorType TRTC_VIDEO_MIRROR_TYPE_AUTO：SDK 决定镜像方式：前置摄像头镜像，后置摄像头不镜像。 TRTC_VIDEO_MIRROR_TYPE_ENABLE：前置摄像头和后置摄像头都镜像。 TRTC_VIDEO_MIRROR_TYPE_DISABLE：前置摄像头和后置摄像头都不镜像。 默认值：TRTC_VIDEO_MIRROR_TYPE_AUTO。
  }) async {
    return _channel.invokeMethod('setLocalViewMirror', {
      "mirrorType": mirrorType,
    });
  }

  /// 设置编码器输出的画面镜像模式。
  static Future<void> setVideoEncoderMirror({
    @required bool mirror, // true：镜像；false：不镜像；默认值：false。
  }) async {
    return _channel.invokeMethod('setVideoEncoderMirror', {
      "mirror": mirror,
    });
  }

  /// 设置重力感应的适应模式。
  static Future<void> setGSensorMode({
    @required int mode, // 重力感应模式，详情请参考 TRTC_GSENSOR_MODE 的定义，默认值：TRTC_GSENSOR_MODE_UIFIXLAYOUT。
  }) async {
    return _channel.invokeMethod('setGSensorMode', {
      "mode": mode,
    });
  }

  /// 开启大小画面双路编码模式。
  static Future<void> enableEncSmallVideoStream({
    @required bool enable, // 是否开启小画面编码，默认值：false。
    @required VideoEncParamEntity smallVideoEncParam, // 小流的视频参数。
  }) async {
    return _channel.invokeMethod('enableEncSmallVideoStream', {
      "enable": enable,
      "smallVideoEncParam": smallVideoEncParam.toJson(),
    });
  }

  /// 选定观看指定 uid 的大画面或小画面。
  static Future<void> setRemoteVideoStreamType({
    @required String userId, // 用户ID
    @required int streamType, // 视频流类型，即选择看大画面或小画面，默认为大画面。
  }) async {
    return _channel.invokeMethod('setRemoteVideoStreamType', {
      "userId": userId,
      "streamType": streamType,
    });
  }

  /// 设定观看方优先选择的视频质量。
  static Future<void> setPriorRemoteVideoStreamType({
    @required int streamType, // 默认观看大画面或小画面，默认为大画面。
  }) async {
    return _channel.invokeMethod('setPriorRemoteVideoStreamType', {
      "streamType": streamType,
    });
  }

  /// 静音本地的音频。
  static Future<void> muteLocalAudio({
    @required bool mute, // true：屏蔽；false：开启，默认值：false。
  }) async {
    return _channel.invokeMethod('muteLocalAudio', {
      "mute": mute,
    });
  }

  /// 关闭本地的视频。
  static Future<void> muteLocalVideo({
    @required bool mute, // true：屏蔽；false：开启，默认值：false。
  }) async {
    return _channel.invokeMethod('muteLocalVideo', {
      "mute": mute,
    });
  }

  /// 设置音频路由。
  static Future<void> setAudioRoute({
    @required int route, // 音频路由，即声音由哪里输出（扬声器、听筒），请参考
  }) async {
    return _channel.invokeMethod('setAudioRoute', {
      "route": route,
    });
  }

  /// 启用音量大小提示。
  static Future<void> enableAudioVolumeEvaluation({
    @required int intervalMs, // 决定了 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms；详细的回调规则请参考 onUserVoiceVolume 的注释说明。
  }) async {
    return _channel.invokeMethod('enableAudioVolumeEvaluation', {
      "intervalMs": intervalMs,
    });
  }

  /// 开始录音。
  static Future<void> startAudioRecording({
    @required String filePath, // 文件路径（必填），录音的文件地址，由用户自行指定，请确保 App 里指定的目录存在且可写。
  }) async {
    return _channel.invokeMethod('startAudioRecording', {
      "filePath": filePath,
    });
  }

  /// 停止录音。
  static Future<void> stopAudioRecording() async {
    return _channel.invokeMethod('stopAudioRecording');
  }

  /// 设置通话时使用的系统音量类型。
  static Future<void> setSystemVolumeType({
    @required int type, // 系统音量类型，请参考 TRTCSystemVolumeType，默认值：TRTCSystemVolumeTypeAuto。
  }) async {
    return _channel.invokeMethod('setSystemVolumeType', {
      "type": type,
    });
  }

  /// 开启耳返。
  static Future<void> enableAudioEarMonitoring({
    @required bool enable, // true：开启；false：关闭。
  }) async {
    return _channel.invokeMethod('enableAudioEarMonitoring', {
      "enable": enable,
    });
  }

  /// 切换摄像头。
  static Future<void> switchCamera() async {
    return _channel.invokeMethod('switchCamera');
  }

  /// 查询当前摄像头是否支持缩放
  static Future<bool> isCameraZoomSupported() async {
    return _channel.invokeMethod('isCameraZoomSupported');
  }

  /// 设置摄像头缩放因子（焦距）。
  static Future<void> setZoom({
    @required int distance, // 取值范围为1 - 5，数值越大，焦距越远。
  }) async {
    return _channel.invokeMethod('setZoom', {
      "distance": distance,
    });
  }

  /// 查询是否支持开关闪光灯（手电筒模式）。
  static Future<bool> isCameraTorchSupported() async {
    return _channel.invokeMethod('isCameraTorchSupported');
  }

  /// 开关闪光灯。
  static Future<void> enableTorch({
    @required bool enable, // true：开启；false：关闭，默认值：false。
  }) async {
    return _channel.invokeMethod('enableTorch', {
      "enable": enable,
    });
  }

  /// 查询是否支持设置焦点。
  static Future<bool> isCameraFocusPositionInPreviewSupported() async {
    return _channel.invokeMethod('isCameraFocusPositionInPreviewSupported');
  }

  /// 设置摄像头焦点。
  static Future<void> setFocusPosition({
    @required int x,
    @required int y,
  }) async {
    return _channel.invokeMethod('setFocusPosition', {
      "x": x,
      "y": y,
    });
  }

  /// 查询是否支持自动识别人脸位置。
  static Future<bool> isCameraAutoFocusFaceModeSupported() async {
    return _channel.invokeMethod('isCameraAutoFocusFaceModeSupported');
  }

  static Future<bool> sendCustomCmdMsg({int cmdID = 0x1, String msg}) async {
    assert(msg != null && msg.length < 1024);
    return _channel.invokeMethod('sendCustomCmdMsg', {
      "cmdID": cmdID,
      "msg": msg
    });
  }
}

class TencentRtcPluginListener {

  @mustCallSuper
  void handle(String method, dynamic params) {
    if (params is String) {
      params = jsonDecode(params);
    }

    switch (method) {
      case 'SdkError':
        onError(params['code'], params['msg']);
        break;
      case 'Warning':
        onWarning(params['code'], params['msg']);
        break;
      case 'EnterRoom':
        onEnterRoom(params);
        break;
      case 'ExitRoom':
        onExitRoom(params);
        break;
      case 'SwitchRole':
        onSwitchRole(params['code'], params['msg']);
        break;
      case 'ConnectOtherRoom':
        onConnectOtherRoom(params['userId'], params['code'], params['msg']);
        break;
      case 'DisConnectOtherRoom':
        onDisConnectOtherRoom(params['code'], params['msg']);
        break;
      case 'RemoteUserEnterRoom':
        onRemoteUserEnterRoom(params.toString());
        break;
      case 'RemoteUserLeaveRoom':
        onRemoteUserLeaveRoom(params['userId'], params['reason']);
        break;
      case 'UserVideoAvailable':
        onUserVideoAvailable(params['userId'], params['available']);
        break;
      case 'UserSubStreamAvailable':
        onUserSubStreamAvailable(params['userId'], params['available']);
        break;
      case 'UserAudioAvailable':
        onUserAudioAvailable(params['userId'], params['available']);
        break;
      case 'FirstVideoFrame':
        onFirstVideoFrame(params['userId'], params['streamType'], params['width'], params['height']);
        break;
      case 'FirstAudioFrame':
        onFirstAudioFrame(params.toString());
        break;
      case 'SendFirstLocalVideoFrame':
        onSendFirstLocalVideoFrame(params);
        break;
      case 'SendFirstLocalAudioFrame':
        onSendFirstLocalAudioFrame();
        break;
      case 'Statistics':
        onStatistics(params);
        break;
      case 'NetworkQuality':
        onNetworkQuality(params['localQuality'], params['remoteQuality']);
        break;
      case 'ConnectionLost':
        onConnectionLost();
        break;
      case 'TryToReconnect':
        onTryToReconnect();
        break;
      case 'ConnectionRecovery':
        onConnectionRecovery();
        break;
      case 'SpeedTest':
        onSpeedTest(params['currentResult'], params['finishedCount'], params['totalCount']);
        break;
      case 'CameraDidReady':
        onCameraDidReady();
        break;
      case 'MicDidReady':
        onMicDidReady();
        break;
      case 'AudioRouteChanged':
        onAudioRouteChanged(params['newRoute'], params['oldRoute']);
        break;
      case 'UserVoiceVolume':
        onUserVoiceVolume(params['userVolumes'], params['totalVolume']);
        break;
      case 'RecvCustomCmdMsg':
        onRecvCustomCmdMsg(params['userId'], params['cmdID'], params['seq'], params['message']);
        break;
      case 'MissCustomCmdMsg':
        onMissCustomCmdMsg(params['userId'], params['cmdID'], params['errCode'], params['missed']);
        break;
      case 'RecvSEIMsg':
        onRecvSEIMsg(params['userId'], params['data']);
        break;
      case 'StartPublishCDNStream':
        onStartPublishCDNStream(params['err'], params['errMsg']);
        break;
      case 'StopPublishCDNStream':
        onStopPublishCDNStream(params['err'], params['errMsg']);
        break;
      case 'SetMixTranscodingConfig':
        onSetMixTranscodingConfig(params['err'], params['errMsg']);
        break;
      case 'AudioEffectFinished':
        onAudioEffectFinished(params['effectId'], params['code']);
        break;
      default:
        throw MissingPluginException();
    }
  }

  /**
   * SDK加载错误回调
   * 错误通知是要监听的，错误通知意味着 SDK 不能继续运行了
   */
  void onError(int errCode, String errMsg) {}

  /**
   * 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败。
   */
  void onWarning(int errCode, String errMsg) {}

  /**
   * 加入房间监听器
   */
  void onEnterRoom(int id) {}

  /**
   * 退出房间监听器
   */
  void onExitRoom(int id) {}

  /**
   * 切换角色
   */
  void onSwitchRole(int code, String msg) {}

  /**
   * 请求跨房通话（主播 PK）的结果回调。
   */
  void onConnectOtherRoom(String uid, int code, String msg) {}

  /**
   * 结束跨房通话（主播 PK）的结果回调。
   */
  void onDisConnectOtherRoom(int code, String msg) {}

  /**
   * 有用户加入当前房间。
   */
  void onRemoteUserEnterRoom(String uid) {}

  /**
   * 有用户离开当前房间。
   */
  void onRemoteUserLeaveRoom(String uid, int reason) {}

  /**
   * 有用户上传视频数据。
   */
  void onUserVideoAvailable(String uid, bool available) {}

  /**
   * 有用户上传屏幕数据。
   */
  void onUserSubStreamAvailable(String uid, bool available) {}

  /**
   * 有用户上传音频数据。
   */
  void onUserAudioAvailable(String uid, bool available) {}

  /**
   * 开始渲染本地或远程用户的首帧画面。
   */
  void onFirstVideoFrame(String uid, int streamType, int width, int height) {}

  /**
   * 开始播放远程用户的首帧音频（本地声音暂不通知）。
   */
  void onFirstAudioFrame(String uid) {}

  /**
   * 首帧本地视频数据已经被送出。
   */
  void onSendFirstLocalVideoFrame(int i) {}

  /**
   * 首帧本地音频数据已经被送出。
   */
  void onSendFirstLocalAudioFrame() {}

  /**
   * 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
   */
  void onNetworkQuality(dynamic localQuality, dynamic remoteQuality) {}

  /**
   * 技术指标统计回调。
   */
  void onStatistics(dynamic statistics) {}

  /**
   * 跟服务器断开。
   */
  void onConnectionLost() {}

  /**
   * SDK 尝试重新连接到服务器。
   */
  void onTryToReconnect() {}

  /**
   * SDK 跟服务器的连接恢复。
   */
  void onConnectionRecovery() {}

  /**
   * 服务器测速的回调，SDK 对多个服务器 IP 做测速，每个 IP 的测速结果通过这个回调通知。【仅Android】。
   */
  void onSpeedTest(dynamic currentResult, int finishedCount, int totalCount) {}

  /**
   * 摄像头准备就绪。
   */
  void onCameraDidReady() {}

  /**
   * 麦克风准备就绪。
   */
  void onMicDidReady() {}

  /**
   * 音频路由发生变化，音频路由即声音由哪里输出（扬声器、听筒）。
   */
  void onAudioRouteChanged(int newRoute, int oldRoute) {}

  /**
   * 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量。
   */
  void onUserVoiceVolume(List<dynamic> userVolumes, int totalVolume) {}

  /**
   * 收到自定义消息。
   */
  void onRecvCustomCmdMsg(String uid, int cmdID, int seq, String message) {}

  /**
   * 自定义消息丢失。
   */
  void onMissCustomCmdMsg(String uid, int cmdID, int errCode, int missed) {}

  /**
   * 收到SEI消息。
   */
  void onRecvSEIMsg(String uid, String message) {}

  /**
   * 启动旁路推流到 CDN 完成的回调。
   */
  void onStartPublishCDNStream(int errCode, String errMsg) {}

  /**
   * 停止旁路推流到 CDN 完成的回调。
   */
  void onStopPublishCDNStream(int errCode, String errMsg) {}

  /**
   * 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
   */
  void onSetMixTranscodingConfig(int errCode, String errMsg) {}

  /**
   * 播放音效结束回调。
   */
  void onAudioEffectFinished(int effectId, int code) {}
}

class _TencentRtcPluginListener {

  static Set<TencentRtcPluginListener> listeners = Set();

  _TencentRtcPluginListener(MethodChannel channel) {
    // 绑定监听器
    channel.setMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method != 'onListener') {
        return;
      }

      // 解析参数
      Map<String, dynamic> arguments = jsonDecode(methodCall.arguments);

      try {
        // 回调触发
        for (var item in listeners) {
          item.handle(arguments['type'], arguments['params']);
        }
      } catch (e) {
        print('=========================================================================');
        print('unhandle event[${arguments['type']}] exception $e');
        print("params> ${arguments['params'].runtimeType}: ${arguments['params']}");
        print('=========================================================================');
        throw e;
      }
    });
  }

  /// 添加消息监听
  void addListener(TencentRtcPluginListener func) {
    listeners.add(func);
  }

  /// 移除消息监听
  void removeListener(TencentRtcPluginListener func) {
    listeners.remove(func);
  }
}

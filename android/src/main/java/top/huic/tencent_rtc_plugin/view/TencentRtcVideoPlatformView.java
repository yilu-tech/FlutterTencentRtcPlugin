package top.huic.tencent_rtc_plugin.view;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;

import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import top.huic.tencent_rtc_plugin.util.TencentRtcPluginUtil;

/**
 * 视频视图
 */
public class TencentRtcVideoPlatformView extends PlatformViewFactory implements PlatformView, MethodChannel.MethodCallHandler {

    /**
     * 全局标识
     */
    public static final String SIGN = "plugins.huic.top/tencentRtcVideoView";

    /**
     * 日志标签
     */
    private static final String TAG = TencentRtcVideoPlatformView.class.getName();

    private Handler mMainHandler;

    private final Context mContext;
    private BinaryMessenger mMessenger;

    /**
     * 腾讯云视频视图
     */
    private TXCloudVideoView mVideoView;

    private boolean mDisposed = false;

    private boolean mLocalViewing = false;
    private String mRemoteUserId = "";

    /**
     * 初始化工厂信息，此处的域是 PlatformViewFactory
     */
    public TencentRtcVideoPlatformView(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.mContext = context;
        this.mMessenger = messenger;
    }

    public TencentRtcVideoPlatformView(Context context) {
        super(StandardMessageCodec.INSTANCE);
        this.mContext = context;

        mMainHandler = new Handler(Looper.getMainLooper());

        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mVideoView = new TXCloudVideoView(mContext);
            }
        });
    }

    @Override
    public View getView() {
        return mVideoView;
    }

    @Override
    public void dispose() {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mDisposed = true;
                if (mLocalViewing) {
                    TRTCCloud.sharedInstance(mContext).stopLocalPreview();
                }
                if (!mRemoteUserId.equals("")) {
                    TRTCCloud.sharedInstance(mContext).stopRemoteView(mRemoteUserId);
                }
                mVideoView.removeVideoView();
                mVideoView = null;
            }
        });
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        // 每次实例化对象，保证界面上每一个组件的独立性(此处域是 PlatformView和MethodChannel.MethodCallHandler)
        TencentRtcVideoPlatformView view = new TencentRtcVideoPlatformView(context);
        new MethodChannel(mMessenger, SIGN + "_" + viewId).setMethodCallHandler(view);

        return view;
    }

    private void runOnMainThread(Runnable runnable) {
        Handler handler = mMainHandler;
        if (handler != null) {
            if (handler.getLooper() == Looper.myLooper()) {
                runnable.run();
            } else {
                handler.post(runnable);
            }
        } else {
            runnable.run();
        }
    }

    @Override
    public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
        if (mDisposed) {
            return;
        }
        switch (call.method) {
            case "startRemoteView":
                startRemoteView(call, result);
                break;
            case "stopRemoteView":
                stopRemoteView(call, result);
                break;
            case "startLocalPreview":
                startLocalPreview(call, result);
                break;
            case "stopLocalPreview":
                stopLocalPreview(call, result);
                break;
            default:
                result.notImplemented();
        }
    }

    /**
     * 开启远程显示
     */
    private void startRemoteView(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        mRemoteUserId = TencentRtcPluginUtil.getParam(call, result, "userId");
        TRTCCloud.sharedInstance(mContext).startRemoteView(mRemoteUserId, mVideoView);
        result.success(null);
    }

    /**
     * 停止远程显示
     */
    private void stopRemoteView(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        // String userId = TencentRtcPluginUtil.getParam(call, result, "userId");
        TRTCCloud.sharedInstance(mContext).stopRemoteView(mRemoteUserId);
        mRemoteUserId = "";
        result.success(null);
    }

    /**
     * 开启本地视频采集
     */
    private void startLocalPreview(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean frontCamera = TencentRtcPluginUtil.getParam(call, result, "frontCamera");
        TRTCCloud.sharedInstance(mContext).startLocalPreview(frontCamera, mVideoView);
        mLocalViewing = true;
        result.success(null);
    }

    /**
     * 停止本地视频采集
     */
    private void stopLocalPreview(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        TRTCCloud.sharedInstance(mContext).stopLocalPreview();
        mLocalViewing = false;
        result.success(null);
    }
}
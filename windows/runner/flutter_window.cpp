#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "single_instance.h"
#include "utils.h"

namespace {

constexpr const char kDesktopActivationChannel[] =
    "worker_rest_calendar/desktop_activation";
constexpr const char kDesktopDisplayConfigurationChannel[] =
    "worker_rest_calendar/desktop_display_configuration";
constexpr const char kSystemStatusChannel[] =
    "worker_rest_calendar/system_status";
constexpr const char kWindowCloseChannel[] =
    "worker_rest_calendar/window_close";

uint64_t FileTimeToUint64(const FILETIME& value) {
  ULARGE_INTEGER converted{};
  converted.LowPart = value.dwLowDateTime;
  converted.HighPart = value.dwHighDateTime;
  return converted.QuadPart;
}

}  // namespace

FlutterWindow::FlutterWindow(
    const flutter::DartProject& project,
    std::vector<std::vector<std::string>> initial_activations)
    : project_(project),
      pending_activations_(std::move(initial_activations)) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }
  if (!::SetPropW(GetHandle(), kWorkerRestCalendarWindowProperty,
                  reinterpret_cast<HANDLE>(1))) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  window_close_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kWindowCloseChannel,
          &flutter::StandardMethodCodec::GetInstance());
  window_close_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "setCloseInterceptionEnabled") {
          result->NotImplemented();
          return;
        }
        const auto* enabled = std::get_if<bool>(call.arguments());
        if (enabled == nullptr) {
          result->Error("invalid_arguments", "Expected a boolean");
          return;
        }
        close_interception_enabled_ = *enabled;
        result->Success();
      });
  activation_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          kDesktopActivationChannel,
          &flutter::StandardMethodCodec::GetInstance());
  activation_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "consumePendingActivations") {
          result->NotImplemented();
          return;
        }
        flutter::EncodableList activations;
        activations.reserve(pending_activations_.size());
        for (const auto& arguments : pending_activations_) {
          activations.emplace_back(EncodeArguments(arguments));
        }
        pending_activations_.clear();
        dart_activation_ready_ = true;
        result->Success(flutter::EncodableValue(activations));
      });
  display_configuration_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          kDesktopDisplayConfigurationChannel,
          &flutter::StandardMethodCodec::GetInstance());
  system_status_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kSystemStatusChannel,
          &flutter::StandardMethodCodec::GetInstance());
  system_status_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "getSystemStatus") {
          result->NotImplemented();
          return;
        }

        FILETIME idle_time{};
        FILETIME kernel_time{};
        FILETIME user_time{};
        if (!::GetSystemTimes(&idle_time, &kernel_time, &user_time)) {
          result->Error("system_times", "无法读取 CPU 状态");
          return;
        }
        const uint64_t idle = FileTimeToUint64(idle_time);
        const uint64_t kernel = FileTimeToUint64(kernel_time);
        const uint64_t user = FileTimeToUint64(user_time);
        double cpu_usage = 0.0;
        if (previous_kernel_time_ != 0 || previous_user_time_ != 0) {
          const uint64_t idle_delta = idle - previous_idle_time_;
          const uint64_t total_delta =
              (kernel - previous_kernel_time_) + (user - previous_user_time_);
          if (total_delta > 0 && idle_delta <= total_delta) {
            cpu_usage = 100.0 *
                        static_cast<double>(total_delta - idle_delta) /
                        static_cast<double>(total_delta);
          }
        }
        previous_idle_time_ = idle;
        previous_kernel_time_ = kernel;
        previous_user_time_ = user;

        MEMORYSTATUSEX memory{};
        memory.dwLength = sizeof(memory);
        if (!::GlobalMemoryStatusEx(&memory)) {
          result->Error("memory_status", "无法读取内存状态");
          return;
        }

        flutter::EncodableMap status;
        status[flutter::EncodableValue("cpuUsage")] =
            flutter::EncodableValue(cpu_usage);
        status[flutter::EncodableValue("memoryUsage")] =
            flutter::EncodableValue(static_cast<double>(memory.dwMemoryLoad));

        SYSTEM_POWER_STATUS power{};
        if (::GetSystemPowerStatus(&power) && power.BatteryFlag != 128 &&
            power.BatteryLifePercent != 255) {
          status[flutter::EncodableValue("batteryLevel")] =
              flutter::EncodableValue(
                  static_cast<int>(power.BatteryLifePercent));
          status[flutter::EncodableValue("isCharging")] =
              flutter::EncodableValue(power.ACLineStatus == 1);
        }
        result->Success(flutter::EncodableValue(status));
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (GetHandle() != nullptr) {
    ::RemovePropW(GetHandle(), kWorkerRestCalendarWindowProperty);
  }
  display_configuration_channel_.reset();
  system_status_channel_.reset();
  activation_channel_.reset();
  close_interception_enabled_ = false;
  window_close_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_COPYDATA) {
    const auto* data = reinterpret_cast<const COPYDATASTRUCT*>(lparam);
    if (data != nullptr &&
        data->dwData == kWorkerRestCalendarActivationCopyDataId &&
        data->lpData != nullptr && data->cbData >= sizeof(wchar_t) &&
        data->cbData % sizeof(wchar_t) == 0) {
      const auto* command_line =
          reinterpret_cast<const wchar_t*>(data->lpData);
      const size_t character_count = data->cbData / sizeof(wchar_t);
      if (command_line[character_count - 1] == L'\0') {
        HandleActivation(GetCommandLineArguments(command_line));
        return TRUE;
      }
    }
    return FALSE;
  }

  if (message == WM_CLOSE && close_interception_enabled_ &&
      window_close_channel_) {
    window_close_channel_->InvokeMethod("onCloseRequested", nullptr);
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_DISPLAYCHANGE:
      NotifyDisplayConfigurationChanged("display");
      break;
    case WM_DPICHANGED:
      NotifyDisplayConfigurationChanged("dpi");
      break;
    case WM_SETTINGCHANGE:
      if (wparam == SPI_SETWORKAREA) {
        NotifyDisplayConfigurationChanged("work-area");
      }
      break;
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::HandleActivation(std::vector<std::string> arguments) {
  if (!dart_activation_ready_ || !activation_channel_) {
    pending_activations_.push_back(std::move(arguments));
    return;
  }
  activation_channel_->InvokeMethod(
      "onActivation",
      std::make_unique<flutter::EncodableValue>(EncodeArguments(arguments)));
}

void FlutterWindow::NotifyDisplayConfigurationChanged(const char* reason) {
  if (!display_configuration_channel_) {
    return;
  }
  flutter::EncodableMap details;
  details[flutter::EncodableValue("reason")] =
      flutter::EncodableValue(std::string(reason));
  display_configuration_channel_->InvokeMethod(
      "onDisplayConfigurationChanged",
      std::make_unique<flutter::EncodableValue>(details));
}

flutter::EncodableList FlutterWindow::EncodeArguments(
    const std::vector<std::string>& arguments) const {
  flutter::EncodableList encoded;
  encoded.reserve(arguments.size());
  for (const auto& argument : arguments) {
    encoded.emplace_back(argument);
  }
  return encoded;
}

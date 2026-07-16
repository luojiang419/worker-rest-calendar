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
  activation_channel_.reset();
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

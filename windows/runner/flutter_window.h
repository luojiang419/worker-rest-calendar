#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(
      const flutter::DartProject& project,
      std::vector<std::vector<std::string>> initial_activations = {});
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      activation_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      display_configuration_channel_;
  std::vector<std::vector<std::string>> pending_activations_;
  bool dart_activation_ready_ = false;

  void HandleActivation(std::vector<std::string> arguments);
  void NotifyDisplayConfigurationChanged(const char* reason);
  flutter::EncodableList EncodeArguments(
      const std::vector<std::string>& arguments) const;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_

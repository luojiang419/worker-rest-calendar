#include <windows.h>
#include <shellapi.h>

#include <cerrno>
#include <cwchar>
#include <fstream>
#include <string>
#include <vector>

namespace {

constexpr DWORD kOldProcessTimeoutMs = 120000;
constexpr DWORD kInstallerTimeoutMs = 600000;

std::wstring GetArgumentValue(const std::vector<std::wstring>& arguments,
                              const std::wstring& prefix) {
  for (const auto& argument : arguments) {
    if (argument.rfind(prefix, 0) == 0) {
      return argument.substr(prefix.size());
    }
  }
  return L"";
}

std::wstring Quote(const std::wstring& value) {
  std::wstring escaped = value;
  size_t position = 0;
  while ((position = escaped.find(L'"', position)) != std::wstring::npos) {
    escaped.insert(position, 1, L'\\');
    position += 2;
  }
  return L"\"" + escaped + L"\"";
}

void AppendLog(const std::wstring& path, const std::wstring& message) {
  if (path.empty()) {
    return;
  }
  std::wofstream output(path, std::ios::app);
  if (output.is_open()) {
    SYSTEMTIME time;
    GetLocalTime(&time);
    output << time.wYear << L"-" << time.wMonth << L"-" << time.wDay << L" "
           << time.wHour << L":" << time.wMinute << L":" << time.wSecond
           << L" " << message << std::endl;
  }
}

int Fail(const std::wstring& log_path, const std::wstring& message,
         int exit_code) {
  AppendLog(log_path, L"FAILED: " + message);
  MessageBoxW(nullptr, message.c_str(), L"工作日历更新失败",
              MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
  return exit_code;
}

bool WaitForOldProcess(DWORD process_id, const std::wstring& log_path) {
  HANDLE process = OpenProcess(SYNCHRONIZE, FALSE, process_id);
  if (process == nullptr) {
    const DWORD error = GetLastError();
    if (error == ERROR_INVALID_PARAMETER) {
      AppendLog(log_path, L"Old process already exited");
      return true;
    }
    AppendLog(log_path, L"OpenProcess failed: " + std::to_wstring(error));
    return false;
  }
  const DWORD wait_result = WaitForSingleObject(process, kOldProcessTimeoutMs);
  CloseHandle(process);
  if (wait_result != WAIT_OBJECT_0) {
    AppendLog(log_path,
              L"Waiting for old process failed: " +
                  std::to_wstring(wait_result));
    return false;
  }
  AppendLog(log_path, L"Old process exited");
  return true;
}

bool RunInstaller(const std::wstring& installer,
                  const std::wstring& install_directory,
                  const std::wstring& log_path, DWORD* installer_exit_code) {
  const std::wstring installer_log = log_path + L".installer.log";
  std::wstring command =
      Quote(installer) +
      L" /SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL"
      L" /CLOSEAPPLICATIONS /FORCECLOSEAPPLICATIONS /DIR=" +
      Quote(install_directory) + L" /LOG=" + Quote(installer_log);
  STARTUPINFOW startup = {};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process = {};
  if (!CreateProcessW(installer.c_str(), command.data(), nullptr, nullptr,
                      FALSE, CREATE_UNICODE_ENVIRONMENT, nullptr, nullptr,
                      &startup, &process)) {
    AppendLog(log_path,
              L"CreateProcess installer failed: " +
                  std::to_wstring(GetLastError()));
    return false;
  }
  CloseHandle(process.hThread);
  const DWORD wait_result =
      WaitForSingleObject(process.hProcess, kInstallerTimeoutMs);
  DWORD exit_code = 1;
  if (wait_result == WAIT_OBJECT_0) {
    GetExitCodeProcess(process.hProcess, &exit_code);
  }
  CloseHandle(process.hProcess);
  *installer_exit_code = exit_code;
  AppendLog(log_path,
            L"Installer wait=" + std::to_wstring(wait_result) +
                L" exit=" + std::to_wstring(exit_code));
  return wait_result == WAIT_OBJECT_0 && exit_code == 0;
}

bool StartUpdatedApp(const std::wstring& executable,
                     const std::wstring& install_directory,
                     const std::wstring& log_path) {
  std::wstring command = Quote(executable);
  STARTUPINFOW startup = {};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process = {};
  if (!CreateProcessW(executable.c_str(), command.data(), nullptr, nullptr,
                      FALSE, CREATE_UNICODE_ENVIRONMENT | DETACHED_PROCESS,
                      nullptr, install_directory.c_str(), &startup, &process)) {
    AppendLog(log_path,
              L"Starting updated app failed: " +
                  std::to_wstring(GetLastError()));
    return false;
  }
  CloseHandle(process.hThread);
  CloseHandle(process.hProcess);
  AppendLog(log_path, L"Updated app started");
  return true;
}

}  // namespace

int WINAPI wWinMain(HINSTANCE, HINSTANCE, PWSTR, int) {
  int argument_count = 0;
  LPWSTR* raw_arguments = CommandLineToArgvW(GetCommandLineW(), &argument_count);
  if (raw_arguments == nullptr) {
    return 2;
  }
  std::vector<std::wstring> arguments;
  for (int index = 1; index < argument_count; ++index) {
    arguments.emplace_back(raw_arguments[index]);
  }
  LocalFree(raw_arguments);

  const std::wstring old_pid_value =
      GetArgumentValue(arguments, L"--old-pid=");
  const std::wstring installer =
      GetArgumentValue(arguments, L"--installer=");
  const std::wstring install_directory =
      GetArgumentValue(arguments, L"--install-dir=");
  const std::wstring app_executable =
      GetArgumentValue(arguments, L"--app-exe=");
  const std::wstring log_path = GetArgumentValue(arguments, L"--log=");
  if (old_pid_value.empty() || installer.empty() || install_directory.empty() ||
      app_executable.empty() || log_path.empty()) {
    return Fail(log_path, L"更新会话参数不完整。", 3);
  }

  errno = 0;
  wchar_t* parse_end = nullptr;
  const unsigned long parsed_pid =
      std::wcstoul(old_pid_value.c_str(), &parse_end, 10);
  if (errno != 0 || parse_end == old_pid_value.c_str() ||
      parse_end == nullptr || *parse_end != L'\0' || parsed_pid == 0 ||
      parsed_pid > MAXDWORD) {
    return Fail(log_path, L"旧程序进程号无效。", 4);
  }
  const DWORD old_pid = static_cast<DWORD>(parsed_pid);
  AppendLog(log_path, L"Update session started");
  if (!WaitForOldProcess(old_pid, log_path)) {
    return Fail(log_path, L"旧版本未能在两分钟内退出，更新已取消。", 5);
  }
  DWORD installer_exit_code = 1;
  if (!RunInstaller(installer, install_directory, log_path,
                    &installer_exit_code)) {
    return Fail(log_path,
                L"安装程序执行失败，退出码：" +
                    std::to_wstring(installer_exit_code),
                6);
  }
  if (!StartUpdatedApp(app_executable, install_directory, log_path)) {
    return Fail(log_path, L"新版已安装，但无法自动重新启动。", 7);
  }
  AppendLog(log_path, L"Update session completed");
  return 0;
}

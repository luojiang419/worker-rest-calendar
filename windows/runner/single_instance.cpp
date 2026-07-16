#include "single_instance.h"

#include <chrono>
#include <thread>

namespace {

constexpr const wchar_t kSingleInstanceMutexName[] =
    L"Local\\WorkerRestCalendar.SingleInstance";
constexpr auto kPrimaryWindowWait = std::chrono::seconds(8);
constexpr auto kPrimaryWindowPollInterval = std::chrono::milliseconds(50);

struct PrimaryWindowSearch {
  HWND window = nullptr;
};

BOOL CALLBACK FindPrimaryWindow(HWND window, LPARAM parameter) {
  auto* search = reinterpret_cast<PrimaryWindowSearch*>(parameter);
  if (::GetPropW(window, kWorkerRestCalendarWindowProperty) != nullptr) {
    search->window = window;
    return FALSE;
  }
  return TRUE;
}

HWND WaitForPrimaryWindow() {
  const auto deadline = std::chrono::steady_clock::now() + kPrimaryWindowWait;
  do {
    PrimaryWindowSearch search;
    ::EnumWindows(FindPrimaryWindow, reinterpret_cast<LPARAM>(&search));
    if (search.window != nullptr) {
      return search.window;
    }
    std::this_thread::sleep_for(kPrimaryWindowPollInterval);
  } while (std::chrono::steady_clock::now() < deadline);
  return nullptr;
}

}  // namespace

const wchar_t kWorkerRestCalendarWindowProperty[] =
    L"WorkerRestCalendar.PrimaryWindow";
const ULONG_PTR kWorkerRestCalendarActivationCopyDataId = 0x57524341;

SingleInstanceGuard::SingleInstanceGuard() {
  mutex_ = ::CreateMutexW(nullptr, FALSE, kSingleInstanceMutexName);
  if (mutex_ != nullptr) {
    is_primary_ = ::GetLastError() != ERROR_ALREADY_EXISTS;
  }
}

SingleInstanceGuard::~SingleInstanceGuard() {
  if (mutex_ != nullptr) {
    ::CloseHandle(mutex_);
  }
}

bool SingleInstanceGuard::is_valid() const { return mutex_ != nullptr; }

bool SingleInstanceGuard::is_primary() const { return is_primary_; }

bool ForwardActivationToPrimaryInstance(const wchar_t* command_line) {
  HWND window = WaitForPrimaryWindow();
  if (window == nullptr || command_line == nullptr) {
    return false;
  }

  DWORD process_id = 0;
  ::GetWindowThreadProcessId(window, &process_id);
  if (process_id != 0) {
    ::AllowSetForegroundWindow(process_id);
  }

  COPYDATASTRUCT data{};
  data.dwData = kWorkerRestCalendarActivationCopyDataId;
  data.cbData = static_cast<DWORD>(
      (::wcslen(command_line) + 1) * sizeof(wchar_t));
  data.lpData = const_cast<wchar_t*>(command_line);

  DWORD_PTR result = 0;
  return ::SendMessageTimeoutW(
             window, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&data),
             SMTO_ABORTIFHUNG | SMTO_BLOCK, 10000, &result) != 0;
}

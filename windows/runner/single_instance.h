#ifndef RUNNER_SINGLE_INSTANCE_H_
#define RUNNER_SINGLE_INSTANCE_H_

#include <windows.h>

extern const wchar_t kWorkerRestCalendarWindowProperty[];
extern const ULONG_PTR kWorkerRestCalendarActivationCopyDataId;

class SingleInstanceGuard {
 public:
  SingleInstanceGuard();
  ~SingleInstanceGuard();

  SingleInstanceGuard(const SingleInstanceGuard&) = delete;
  SingleInstanceGuard& operator=(const SingleInstanceGuard&) = delete;

  bool is_valid() const;
  bool is_primary() const;

 private:
  HANDLE mutex_ = nullptr;
  bool is_primary_ = false;
};

bool ForwardActivationToPrimaryInstance(const wchar_t* command_line);

#endif  // RUNNER_SINGLE_INSTANCE_H_

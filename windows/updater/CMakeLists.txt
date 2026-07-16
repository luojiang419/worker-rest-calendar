cmake_minimum_required(VERSION 3.14)

add_executable(worker_rest_calendar_updater WIN32 "update_main.cpp")
apply_standard_settings(worker_rest_calendar_updater)
target_compile_definitions(worker_rest_calendar_updater PRIVATE "NOMINMAX")
target_link_libraries(worker_rest_calendar_updater PRIVATE "shell32.lib")
set_target_properties(
  worker_rest_calendar_updater
  PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner"
)

/// S2E Selective Symbolic Execution Platform
///
/// Copyright (c) 2017, Dependable Systems Laboratory, EPFL
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

#ifndef S2E_LINUX_MONITOR_H
#define S2E_LINUX_MONITOR_H

#include <linux/sched.h>

#include <s2e/s2e.h>

#include "commands.h"

/* These are declared in kernel/s2e/vars.c */
extern char s2e_linux_monitor_enabled;
extern struct task_struct *s2e_current_task;

static inline void s2e_linux_process_load(pid_t pid, const char *name, const struct task_struct *t, const char *path,
                                          uintptr_t entry)
{
    if (s2e_linux_monitor_enabled) {
        struct S2E_LINUXMON_COMMAND cmd = { 0 };
        cmd.version = S2E_LINUXMON_COMMAND_VERSION;
        cmd.Command = LINUX_PROCESS_LOAD;
        cmd.currentPid = pid;
        strncpy(cmd.currentName, name, sizeof(cmd.currentName));
        cmd.ProcessLoad.start_code = t->mm->start_code;
        cmd.ProcessLoad.end_code = t->mm->end_code;
        cmd.ProcessLoad.start_data = t->mm->start_data;
        cmd.ProcessLoad.end_data = t->mm->end_data;
        cmd.ProcessLoad.start_stack = t->mm->start_stack;
        cmd.ProcessLoad.process_id = t->pid;
        cmd.ProcessLoad.entry_point = entry;
        strncpy(cmd.ProcessLoad.process_path, path, sizeof(cmd.ProcessLoad.process_path));

        s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
    }
}

static inline void s2e_linux_segfault(pid_t pid, const char *name, uint64_t pc, uint64_t address, uint64_t fault)
{
    if (s2e_linux_monitor_enabled) {
        struct S2E_LINUXMON_COMMAND cmd = { 0 };
        cmd.version = S2E_LINUXMON_COMMAND_VERSION;
        cmd.Command = LINUX_SEGFAULT;
        cmd.currentPid = pid;
        strncpy(cmd.currentName, name, sizeof(cmd.currentName));
        cmd.SegFault.pc = pc;
        cmd.SegFault.address = address;
        cmd.SegFault.fault = fault;

        s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
    }
}

static inline void s2e_linux_trap(pid_t pid, const char *name, uint64_t pc, int trapnr, int signr, long error_code)
{
    if (s2e_linux_monitor_enabled) {
        struct S2E_LINUXMON_COMMAND cmd = { 0 };
        cmd.version = S2E_LINUXMON_COMMAND_VERSION;
        cmd.Command = LINUX_TRAP;
        cmd.currentPid = pid;
        strncpy(cmd.currentName, name, sizeof(cmd.currentName));
        cmd.Trap.pc = pc;
        cmd.Trap.trapnr = trapnr;
        cmd.Trap.signr = signr;
        cmd.Trap.error_code = error_code;

        s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
    }
}

static inline void s2e_linux_process_exit(pid_t pid, const char *name, uint64_t code)
{
    if (s2e_linux_monitor_enabled) {
        struct S2E_LINUXMON_COMMAND cmd = { 0 };
        cmd.version = S2E_LINUXMON_COMMAND_VERSION;
        cmd.Command = LINUX_PROCESS_EXIT;
        cmd.currentPid = pid;
        strncpy(cmd.currentName, name, sizeof(cmd.currentName));
        cmd.ProcessExit.code = code;

        s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
    }
}

static inline void s2e_linux_init(uint64_t page_offset, uint64_t current_task_address, uint64_t task_struct_pid_offset,
                                  uint64_t task_struct_tgid_offset)
{
    if (s2e_linux_monitor_enabled) {
        struct S2E_LINUXMON_COMMAND cmd = { 0 };
        cmd.version = S2E_LINUXMON_COMMAND_VERSION;
        cmd.Command = LINUX_INIT;
        cmd.currentPid = -1;
        cmd.Init.page_offset = page_offset;
        cmd.Init.current_task_address = current_task_address;
        cmd.Init.task_struct_pid_offset = task_struct_pid_offset;
        cmd.Init.task_struct_tgid_offset = task_struct_tgid_offset;

        s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
    }
}

#endif

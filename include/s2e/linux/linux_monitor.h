/// S2E Selective Symbolic Execution Platform
///
/// Copyright (c) 2017, Dependable Systems Laboratory, EPFL
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to
/// deal in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE OFTWARE.

#ifndef S2E_LINUX_MONITOR_H
#define S2E_LINUX_MONITOR_H

#include <linux/sched.h>

#include <s2e/s2e.h>

#include "commands.h"

/* These are declared in kernel/s2e/vars.c */
extern char s2e_linux_monitor_enabled;

static inline void s2e_linux_init_task(struct S2E_LINUXMON_TASK *lmt, struct task_struct *task)
{
	lmt->task_struct = task;
	lmt->pid = task->pid;
	lmt->tgid = task->tgid;
}

static inline struct S2E_LINUXMON_COMMAND s2e_linux_init_cmd(struct task_struct *task)
{
	struct S2E_LINUXMON_COMMAND cmd = {0};
	cmd.version = S2E_LINUXMON_COMMAND_VERSION;
	s2e_linux_init_task(&cmd.CurrentTask, task);
	return cmd;
}

static inline void s2e_linux_process_load(struct task_struct *task, const char *path)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_PROCESS_LOAD;

	cmd.ProcessLoad.process_path = path;
	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_module_load(const char *path, struct task_struct *task, uint64_t entry_point,
					 const struct S2E_LINUXMON_PHDR_DESC *phdr, size_t phdr_size)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_MODULE_LOAD;

	cmd.ModuleLoad.module_path = path;
	cmd.ModuleLoad.entry_point = entry_point;
	cmd.ModuleLoad.phdr = (uintptr_t)phdr;
	cmd.ModuleLoad.phdr_size = phdr_size;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_segfault(struct task_struct *task, uint64_t pc, uint64_t address, uint64_t fault)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_SEGFAULT;

	cmd.SegFault.pc = pc;
	cmd.SegFault.address = address;
	cmd.SegFault.fault = fault;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_trap(struct task_struct *task, uint64_t pc, int trapnr, int signr, long error_code)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_TRAP;

	cmd.Trap.pc = pc;
	cmd.Trap.trapnr = trapnr;
	cmd.Trap.signr = signr;
	cmd.Trap.error_code = error_code;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_process_exit(struct task_struct *task, uint64_t code)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_PROCESS_EXIT;
	cmd.ProcessExit.code = code;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_thread_exit(struct task_struct *task, uint64_t code)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_THREAD_EXIT;
	cmd.ThreadExit.code = code;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_init(uint64_t page_offset, uint64_t start_kernel)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(current);
	cmd.Command = LINUX_INIT;
	cmd.Init.page_offset = page_offset;
	cmd.Init.start_kernel = start_kernel;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_kernel_panic(const char *msg, unsigned msg_size)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(current);
	cmd.Command = LINUX_KERNEL_PANIC;
	cmd.Panic.message = (uintptr_t)msg;
	cmd.Panic.message_size = msg_size;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_mmap(struct task_struct *task, unsigned long addr, unsigned long len, unsigned long prot,
				  unsigned long flag, unsigned long pgoff)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_MEMORY_MAP;
	cmd.MemMap.address = addr;
	cmd.MemMap.size = len;
	cmd.MemMap.prot = prot;
	cmd.MemMap.flag = flag;
	cmd.MemMap.pgoff = pgoff;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_unmap(struct task_struct *task, unsigned long start, unsigned long end)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_MEMORY_UNMAP;
	cmd.MemUnmap.start = start;
	cmd.MemUnmap.end = end;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_mprotect(struct task_struct *task, unsigned long start, unsigned long len,
				      unsigned long prot)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(task);
	cmd.Command = LINUX_MEMORY_PROTECT;
	cmd.MemProtect.start = start;
	cmd.MemProtect.size = len;
	cmd.MemProtect.prot = prot;

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

static inline void s2e_linux_task_switch(struct task_struct *prev, struct task_struct *next)
{
	struct S2E_LINUXMON_COMMAND cmd = s2e_linux_init_cmd(current);
	cmd.Command = LINUX_TASK_SWITCH;
	s2e_linux_init_task(&cmd.TaskSwitch.prev, prev);
	s2e_linux_init_task(&cmd.TaskSwitch.next, next);

	s2e_invoke_plugin("LinuxMonitor", &cmd, sizeof(cmd));
}

#endif

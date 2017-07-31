/*
 * S2E Selective Symbolic Execution Platform
 *
 * Copyright (c) 2017, Dependable Systems Laboratory, EPFL
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <linux/module.h>

#include <s2e/s2e.h>
#include <s2e/decree/decree_monitor.h>

static int __init s2e_init(void)
{
    size_t task_struct_pid_offset = offsetof(struct task_struct, pid);

    /* Check if the DecreeMonitor plugin is enabled */
    if (boot_cpu_has(X86_FEATURE_S2E) && s2e_plugin_loaded("DecreeMonitor")) {
        s2e_decree_monitor_enabled = 1;
    }

    /* Send addresses and offsets to the DecreeMonitor plugin */
    if (s2e_decree_monitor_enabled) {
        s2e_decree_init(PAGE_OFFSET, task_struct_pid_offset);
    }

    return 0;
}

static void __exit s2e_exit(void)
{
    /* Nothing to do here */
}

module_init(s2e_init);
module_exit(s2e_exit);

MODULE_DESCRIPTION("S2E DecreeMonitor support");
MODULE_LICENSE("MIT");

import gdb
import os
import subprocess
import pynvim

class TmuxPaneControllerOld:
    def __init__(self):
        original_pane_id = subprocess.check_output(
            ["tmux", "display", "-p", "#{pane_id}"]
        ).decode().strip()

        self.tmux_proc = subprocess.Popen(
            ["tmux", "split-window", "-v", "-P", "-b", "-F", "#{pane_id}", "-I"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
        self.tmux_pane_id = self.tmux_proc.stdout.readline().strip()

        subprocess.run(["tmux", "select-pane", "-t", original_pane_id])

    def get_pane_height(self):
        height_str = subprocess.check_output([
            "tmux",
            "display-message",
            "-p",
            "-t",
            self.tmux_pane_id,
            "#{pane_height}"
        ]).decode().strip()
        return int(height_str)

    def send_to_pane(self, text):
        self.tmux_proc.stdin.write("\x1bc")  # ANSI clear screen
        self.tmux_proc.stdin.write(text)
        self.tmux_proc.stdin.flush()

    def get_source_pygments(self, filename, lineno, height):
        from pygments import highlight
        from pygments.lexers import guess_lexer
        from pygments.formatters import Terminal256Formatter
        half_height = height // 2
        start = max(lineno - half_height, 1)
        end = start + height - 1
        source = self.load_file(filename)
        lexer = guess_lexer(source)
        lines = highlight(source, lexer, Terminal256Formatter()).split("\n")
        output = list()
        for i in range(start, end):
            prefix = f"{i:4d} "
            line = lines[i - 1].rstrip()
            if i == lineno:
                output.append(f"\033[7m{prefix}{line}\033[0m")
            else:
                output.append(f"{prefix}{line}")
        output.append(f"\033[1;34m{filename}\033[0m")
        return "\r\n".join(output)

    def get_source_bat(self, filename, lineno, height):
        half_height = height // 2
        start = max(lineno - half_height, 1)
        end = start + height - 1
        lines = subprocess.check_output([
            "batcat",
            "--color=always",
            "--style=numbers",
            "--highlight-line",
            str(lineno),
            "--line-range",
            f"{start}:{end-1}",
            filename
        ], stderr=subprocess.DEVNULL).decode().strip().split("\n")
        lines.append(f"\033[1;34m{filename}\033[0m")
        return "\r\n".join(lines)

    def get_source_custom(self, filename, lineno, height):
        half_height = height // 2
        start = max(lineno - half_height, 1)
        end = start + height - 1
        lines = self.load_file(filename).splitlines()
        output = list()
        for i in range(start, end):
            prefix = f"{i:4d} "
            line = lines[i - 1].rstrip()
            if i == lineno:
                output.append(f"\033[7m{prefix}{line}\033[0m")
            else:
                output.append(f"{prefix}{line}")
        output.append(f"\033[1;34m{filename}\033[0m")
        return "\r\n".join(output)

    def jump_to(self, filename, lineno):
        filename = os.path.abspath(filename)
        height = self.get_pane_height()
        output = self.get_source_custom(filename, lineno, height)
        self.send_to_pane(output)

    def close(self):
        self.tmux_proc.stdin.close()
        self.tmux_proc.terminate()
        self.tmux_proc.wait()
        subprocess.run(["tmux", "kill-pane", "-t", self.tmux_pane_id])

class TmuxPaneController:
    def __init__(self):
        self.sock_path = "/tmp/gdb-nvim.sock"
        if os.path.exists(self.sock_path):
            self.nvim = pynvim.attach("socket", path=self.sock_path)
            self.tmux_pane_id = None
        else:
            original_pane_id = subprocess.check_output([
                "tmux",
                "display",
                "-p",
                "#{pane_id}"
            ]).decode().strip()

            self.tmux_pane_id = subprocess.check_output([
                "tmux",
                "split-window",
                "-v",  # Vertical split
                "-b",  # Open above
                "-P",  # Print pane ID
                "-F",
                "#{pane_id}",
                f"nvim --listen {self.sock_path}"
            ]).decode().strip()
            self.nvim = pynvim.attach("socket", path=self.sock_path)

            subprocess.run(["tmux", "select-pane", "-t", original_pane_id])

    def jump_to(self, filename, lineno):
        filename = os.path.abspath(filename)

        bufnr = None
        for b in self.nvim.buffers:
            if os.path.abspath(b.name or "") == filename:
                bufnr = b.number
                break

        if bufnr is None:
            self.nvim.command(f"edit {filename}")
            bufnr = self.nvim.current.buffer.number
        else:
            self.nvim.command(f"buffer {bufnr}")

        # move cursor (1-based row/col)
        self.nvim.current.window.cursor = (lineno, 0)
        self.nvim.command("normal! zz")

    def close(self):
        try:
            if self.tmux_pane_id:
                self.nvim.command("qa!")
                subprocess.run(["tmux", "kill-pane", "-t", self.tmux_pane_id])
        finally:
            self.nvim.close()

class TmuxViewerHook(gdb.Command):
    def __init__(self):
        super().__init__("tmux-viewer-init", gdb.COMMAND_USER)
        gdb.events.stop.connect(self.on_stop)
        gdb.events.exited.connect(self.on_exit)
        self.tmux_controller = None
        self.current_filename = None
        self.current_file = None

    def on_exit(self, event):
        if self.tmux_controller:
            self.tmux_controller.close()
            self.tmux_controller = None

    def load_file(self, filename):
        if self.current_filename == filename:
            return self.current_file
        self.current_filename = filename
        self.current_file = open(filename).read().strip()
        return self.current_file

    def update_source_pane(self):
        try:
            frame = gdb.selected_frame()
            sal = frame.find_sal()
            if not sal or not sal.symtab:
                return
            filename = sal.symtab.fullname()
            lineno = sal.line

            if not self.tmux_controller:
                self.tmux_controller = TmuxPaneController()
            self.tmux_controller.jump_to(filename, lineno)
        except Exception as e:
            gdb.write(f"[tmux-viewer] Error: {e}\n", gdb.STDERR)


    def on_stop(self, event):
        self.update_source_pane()

    def invoke(self, arg, from_tty):
        pass

tmux_viewer = TmuxViewerHook()

def prompt_handler():
    tmux_viewer.update_source_pane()

gdb.events.before_prompt.connect(prompt_handler)

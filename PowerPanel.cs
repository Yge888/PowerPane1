using System;
using System.Windows.Forms;
using System.Drawing;
using System.Diagnostics;

namespace PowerPanel {
    class Program {
        [STAThread]
        static void Main() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }

    class MainForm : Form {
        ComboBox cmbAction;
        NumericUpDown numDelay;
        Label lblCountdown, lblStatus;
        Timer timer;
        int remaining;
        string pendingAction;
        string pendingExe, pendingArgs;

        public MainForm() {
            Text = "电源控制面板";
            Size = new Size(420, 380);
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            BackColor = Color.FromArgb(30, 30, 30);
            Font = new Font("Microsoft YaHei", 10);

            var lblAction = new Label { Text = "操作:", Location = new Point(20, 25), AutoSize = true, ForeColor = Color.White };
            Controls.Add(lblAction);

            cmbAction = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Location = new Point(90, 22), Size = new Size(280, 28) };
            cmbAction.Items.AddRange(new object[] { "关机", "重启", "锁屏", "睡眠", "休眠" });
            cmbAction.SelectedIndex = 0;
            Controls.Add(cmbAction);

            var lblDelay = new Label { Text = "延迟(秒):", Location = new Point(20, 70), AutoSize = true, ForeColor = Color.White };
            Controls.Add(lblDelay);

            numDelay = new NumericUpDown { Location = new Point(110, 68), Size = new Size(120, 28), Minimum = 0, Maximum = 86400, Value = 60 };
            Controls.Add(numDelay);

            var lblHint = new Label { Text = "0 = 立即执行", Location = new Point(240, 70), AutoSize = true, ForeColor = Color.Gray };
            Controls.Add(lblHint);

            var btnExec = new Button { Text = "执 行", Location = new Point(20, 120), Size = new Size(350, 55) };
            btnExec.Font = new Font("Microsoft YaHei", 14, FontStyle.Bold);
            btnExec.BackColor = Color.FromArgb(200, 50, 50);
            btnExec.ForeColor = Color.White;
            btnExec.FlatStyle = FlatStyle.Flat;
            btnExec.Click += BtnExec_Click;
            Controls.Add(btnExec);

            var btnCancel = new Button { Text = "取消计划", Location = new Point(20, 190), Size = new Size(170, 40) };
            btnCancel.BackColor = Color.FromArgb(60, 60, 60);
            btnCancel.ForeColor = Color.White;
            btnCancel.FlatStyle = FlatStyle.Flat;
            btnCancel.Click += (s, e) => {
                Run("cmd.exe", "/c shutdown /a");
                StopTimer();
                lblStatus.Text = "已取消";
                lblStatus.ForeColor = Color.Cyan;
            };
            Controls.Add(btnCancel);

            var btnAbort = new Button { Text = "中止倒计时", Location = new Point(200, 190), Size = new Size(170, 40) };
            btnAbort.BackColor = Color.FromArgb(60, 60, 60);
            btnAbort.ForeColor = Color.White;
            btnAbort.FlatStyle = FlatStyle.Flat;
            btnAbort.Click += (s, e) => { StopTimer(); lblStatus.Text = "倒计时已中止"; lblStatus.ForeColor = Color.Yellow; };
            Controls.Add(btnAbort);

            lblCountdown = new Label { Text = "", Location = new Point(20, 250), Size = new Size(350, 35), ForeColor = Color.Lime, Font = new Font("Consolas", 16, FontStyle.Bold) };
            Controls.Add(lblCountdown);

            lblStatus = new Label { Text = "", Location = new Point(20, 295), Size = new Size(350, 30), ForeColor = Color.Gray };
            Controls.Add(lblStatus);

            timer = new Timer { Interval = 1000 };
            timer.Tick += Timer_Tick;
        }

        void BtnExec_Click(object sender, EventArgs e) {
            string action = cmbAction.SelectedItem.ToString();
            int delay = (int)numDelay.Value;

            if (delay == 0) {
                Execute(action);
                return;
            }

            pendingAction = action;
            Prepare(action);
            remaining = delay;
            lblCountdown.Text = FormatTime(remaining);
            lblStatus.Text = action + " 计划中...";
            lblStatus.ForeColor = Color.Orange;
            timer.Start();
        }

        void Prepare(string action) {
            switch (action) {
                case "关机": pendingExe = "cmd.exe"; pendingArgs = "/c shutdown /s /t 0"; break;
                case "重启": pendingExe = "cmd.exe"; pendingArgs = "/c shutdown /r /t 0"; break;
                case "锁屏": pendingExe = "rundll32.exe"; pendingArgs = "user32.dll,LockWorkStation"; break;
                case "睡眠": pendingExe = "rundll32.exe"; pendingArgs = "powrprof.dll,SetSuspendState 0,1,0"; break;
                case "休眠": pendingExe = "rundll32.exe"; pendingArgs = "powrprof.dll,SetSuspendState 1,0,0"; break;
            }
        }

        void Timer_Tick(object sender, EventArgs e) {
            remaining--;
            lblCountdown.Text = FormatTime(remaining);
            if (remaining <= 0) {
                timer.Stop();
                Execute(pendingAction);
            }
        }

        void Execute(string action) {
            Prepare(action);
            Run(pendingExe, pendingArgs);
            lblCountdown.Text = "";
            lblStatus.Text = action + " 已执行";
            lblStatus.ForeColor = Color.Lime;
        }

        void StopTimer() {
            timer.Stop();
            lblCountdown.Text = "";
            Run("cmd.exe", "/c shutdown /a");
        }

        void Run(string exe, string args) {
            try { Process.Start(new ProcessStartInfo(exe, args) { WindowStyle = ProcessWindowStyle.Hidden }); }
            catch { }
        }

        string FormatTime(int s) {
            int h = s / 3600, m = (s % 3600) / 60, sec = s % 60;
            if (h > 0) return string.Format("{0:D2}:{1:D2}:{2:D2}", h, m, sec);
            return string.Format("{0:D2}:{1:D2}", m, sec);
        }
    }
}
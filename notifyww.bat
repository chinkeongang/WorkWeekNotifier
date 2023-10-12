// 2>nul||@goto :batch
/*
:batch
@echo off
setlocal

:: find csc.exe
set "csc="
for /r "%SystemRoot%\Microsoft.NET\Framework\" %%# in ("*csc.exe") do  set "csc=%%#"

if not exist "%csc%" (
   echo no .net framework installed
   exit /b 10
)

REM if not exist "%~n0.exe" (
   call %csc% /target:winexe /nologo /w:0 /out:"%~n0.exe" "%~dpsfnx0" || (
      exit /b %errorlevel% 
   )
REM )
%~n0.exe %*
endlocal & exit /b %errorlevel%

*/

using System;
using System.Drawing;
using System.Windows.Forms;
using Microsoft.Win32;
using System.IO;

class Program
{
    static NotifyIcon notifyIcon;
    static DateTime lastNotificationDate = DateTime.MinValue;

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        // Create and configure the NotifyIcon
        notifyIcon = new NotifyIcon
        {
            Icon = new Icon(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "notifyww.ico")),
            Visible = true
        };

        // Create the context menu for the NotifyIcon
        ContextMenu contextMenu = new ContextMenu();
        contextMenu.MenuItems.Add("Work Week", Work_Week_Click);
        contextMenu.MenuItems.Add("Exit", Exit_Click);

        // Assign the context menu to the NotifyIcon
        notifyIcon.ContextMenu = contextMenu;

        // Handle double-clicks on the NotifyIcon (optional)
        notifyIcon.DoubleClick += NotifyIcon_DoubleClick;

        // Hide the main form
        Form mainForm = new Form();
        mainForm.ShowInTaskbar = false;
        mainForm.WindowState = FormWindowState.Minimized;
        mainForm.Visible = false;

        // Subscribe to the SessionSwitch event
        SystemEvents.SessionSwitch += SystemEvents_SessionSwitch;
        
        PromptWorkWeekNumber(false);

        Application.Run();
    }

    static void Exit_Click(object sender, EventArgs e)
    {
        // Clean up and exit the application
        notifyIcon.Visible = false;
        Application.Exit();
    }
    
    static void Work_Week_Click(object sender, EventArgs e)
    {
        PromptWorkWeekNumber(false);
    }


    static void NotifyIcon_DoubleClick(object sender, EventArgs e)
    {
        // Handle double-click on the NotifyIcon (e.g., show/hide the main form)
        // For example: mainForm.Visible = !mainForm.Visible;
        PromptWorkWeekNumber(false);
    }

    static void SystemEvents_SessionSwitch(object sender, SessionSwitchEventArgs e)
    {
        // Handle the SessionSwitch event (e.g., user unlocks the computer)
        if (e.Reason == SessionSwitchReason.SessionUnlock)
        {
            // Check if we already showed the notification today
            DateTime currentDate = DateTime.Now.Date;
            if (lastNotificationDate != currentDate)
            {
                PromptWorkWeekNumber(true);
            }
        }
    }
    
    static void PromptWorkWeekNumber(bool RememberPrompted)
    {
        DateTime currentDate = DateTime.Now.Date;
        string currentDateStr = DateTime.Now.ToString("yyyy-MM-dd");
        
        // Get the current date and calculate the work week number
        int workWeekNumber = GetWorkWeekNumber(currentDate);
        
        // Get the current day of the week as a number (0 for Sunday, 1 for Monday, etc.)
        int dayOfWeekNumber = (int)DateTime.Now.DayOfWeek;
        
        // Show a message box with the work week number
        MessageBox.Show ("Today is " + currentDateStr + "\nCurrent Work Week: " + workWeekNumber + "." + dayOfWeekNumber, "Welcome back!");
        
        if (RememberPrompted)
        {
            lastNotificationDate = currentDate; // Update the last notification date
        }
    }

    static int GetWorkWeekNumber(DateTime date)
    {
        // Determine the first day of the year and the day of the week it falls on
        DateTime jan1 = new DateTime(date.Year, 1, 1);
        int jan1DayOfWeek = (int)jan1.DayOfWeek;
    
        // Calculate the offset to the first Sunday of the year
        int offsetToSunday = (7 - jan1DayOfWeek + (int)DayOfWeek.Sunday) % 7;
    
        // Adjust the date by the offset
        DateTime startOfWeek = jan1.AddDays(offsetToSunday);
    
        // Calculate the number of days between the date and the start of the week
        int days = (date - startOfWeek).Days;
    
        // Calculate the work week number
        int workWeekNumber = (days / 7) + 1;
    
        return workWeekNumber;
    }

}

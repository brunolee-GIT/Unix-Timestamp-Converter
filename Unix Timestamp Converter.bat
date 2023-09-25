@echo off
set Title=Unix TimeStamp Converter
title %Title%
mode con cols=100 lines=30
color 07


: Banner
powershell -Command "[Console]::CursorVisible=0"
chcp 850>NUL
echo. 
echo   [46;4m                                                                                                [0m
echo   [104m                                                                                                [0m
echo   [104;97m                                    UNIX TIMESTAMP CONVERTER                                    [0m
echo   [104m                                     Batch Code by brunolee                                     [0m
echo   [104;4;30m                                                                                                [0m
echo   [44;30m                                                                                                [0m

: Converter Window
::calendar clock and textbox / for multiline bypass characters like: ,;)=
for /f "tokens=1-9 delims=[]" %%1 in ('^
	powershell -Command^
		Add-Type -AssemblyName System.Windows.Forms^;^
		Add-Type -AssemblyName System.Drawing^;^
		$font ^= New-Object System.Drawing.Font^;^
^
		$form ^= New-Object Windows.Forms.Form -Property @{^
			StartPosition	^= [Windows.Forms.FormStartPosition]::CenterScreen^;^
			FormBorderStyle ^= [Windows.Forms.FormBorderStyle]::FixedDialog^;^
			MaximizeBox		^= $false^;^
			MinimizeBox		^= $false^;^
			Size			^= New-Object Drawing.Size 492^, 155^;^
			ForeColor		^= 'white'^;^
			BackColor		^= '#282828'^;^
			Text			^= '%Title%'^;^
			Topmost			^= $true^;^
			Font			^= 'Consolas^, 13'^
		}^;^
^
		$TextLabel ^= New-Object Windows.Forms.Label -Property @{^
			Location		^= New-Object Drawing.Point 5^, 5^;^
			Size			^= New-Object Drawing.Size 476^, 20^;^
			Text			^= 'Enter the date and time: '+' '+' Enter the TimeStamp:'^;^
		}^;^
		$form.Controls.Add($TextLabel^)^;^
^
		$DatePicker ^= New-Object System.Windows.Forms.DateTimePicker -Property @{^
			Location		^= New-Object Drawing.Point 10^, 35^;^
			Size			^= New-Object Drawing.Size 120^;^
			CustomFormat	^= 'dd/MM/yyyy'^;^
			Format			^= [windows.forms.DateTimePickerFormat]::custom^;^
		}^;^
		$form.Controls.Add($DatePicker^)^;^
^
		$TimePicker ^= New-Object System.Windows.Forms.DateTimePicker -Property @{^
			Location		^= New-Object Drawing.Point 140^, 35^;^
			Size			^= New-Object Drawing.Size 100^;^
			CustomFormat	^= 'HH:mm:ss'^;^
			ShowUpDown		^= $true^;^
			Format			^= [windows.forms.DateTimePickerFormat]::custom^;^
		}^;^
		$form.Controls.Add($TimePicker^)^;^
^
		$DateTimeButton ^= New-Object Windows.Forms.Button -Property @{^
			Location		^= New-Object Drawing.Point 10^, 75^;^
			Size			^= New-Object Drawing.Size 230^, 30^;^
			Text			^= 'Date to TimeStamp'^;^
			DialogResult	^= [Windows.Forms.DialogResult]::OK^;^
			Font			^= 'Microsoft Sans Serif^, 13'^
		}^;^
		$form.Controls.Add($DateTimeButton^)^;^
^
		$TimeStampPicker ^= New-Object Windows.Forms.TextBox -Property @{^
			Location		^= New-Object Drawing.Point 275^, 35^;^
			Size			^= New-Object Drawing.Size 191^;^
			Text			^= [int][double]::Parse((Get-Date (get-date^).touniversaltime(^) -UFormat %%s^)^)^;^
			MaxLength		^= 11^;^
		}^;^
		$form.Controls.Add($TimeStampPicker^)^;^
^
		$TimeStampPicker.Add_TextChanged({^
			if ($this.Text -match '\D+'^) {^
				$cursorPos				^= $this.SelectionStart^;^
				$this.Text				^= $this.Text -replace '\D+'^, ''^;^
				$this.SelectionStart	^= $cursorPos - 1^;^
				$this.SelectionLength	^= 0^;^
			}^;^
		}^)^;^
^
		$TimeStampButton ^= New-Object Windows.Forms.Button -Property @{^
			Location		^= New-Object Drawing.Point 275^, 75^;^
			Size			^= New-Object Drawing.Size 191^, 30^;^
			Text			^= 'TimeStamp to Date'^;^
			DialogResult	^= [Windows.Forms.DialogResult]::YES^;^
			Font			^= 'Microsoft Sans Serif^, 13'^
		}^;^
		$form.Controls.Add($TimeStampButton^)^;^
^
		$result ^= $form.ShowDialog(^)^;^
		if ($result -eq [Windows.Forms.DialogResult]::OK^) {^
			$date ^= ($DatePicker^).value.ToShortDateString(^)^, ($TimePicker^).value.ToShortTimeString(^)^;^
			Write-Host $date'[Date2TimeStamp]'^;^
		}^;^
		if ($result -eq [Windows.Forms.DialogResult]::YES^) {^
			$TimeStamp ^= ($TimeStampPicker^).Text^;^
			Write-Host $TimeStamp'[TimeStamp2Date]'^;^
		}^
') do set Result=%%1&set GoNext=%%2
for /f %%a in ('powershell -Command "Get-Date -UFormat '%%Z'"') do set timezone=%%a
if "%GoNext%"=="Date2TimeStamp" set TimeAndDate=%Result%&goto %GoNext%
if "%GoNext%"=="TimeStamp2Date" set TimeStamp=%Result%&goto %GoNext%
echo.
echo  [90m[[31m![90m] [33mCANCELED!
timeout 3 >NUL&exit


: Date2TimeStamp
echo.

echo  [90m[ ] [93mConverting Date [92m%TimeAndDate%[93m to Unix TimeStamp . . .[0m
rem powershell -Command "[int][double]::Parse((Get-Date (get-date).ToString('U') -UFormat %%s))"
for /f %%a in ('powershell -Command "[int][double]::Parse((Get-Date ('%TimeAndDate%') -UFormat %%s))"') do set MYTimeStamp=%%a
set TimeStamp=%MYTimeStamp%
if "%timezone:~0,1%"=="+" set /a TimeStamp=%MYTimeStamp%-(3600*%timezone:~1%)
if "%timezone:~0,1%"=="-" set /a TimeStamp=%MYTimeStamp%+(3600*%timezone:~1%)
call :function_epochDate %TimeStamp%
goto Result


: TimeStamp2Date
echo.
echo  [90m[ ] [93mConverting Unix TimeStamp [92m%TimeStamp%[93m to human readable date . . .[0m
call :function_epochDate %TimeStamp%
goto Result


: Result
if "%GoNext%"=="Date2TimeStamp" echo  [90m[[92mx[90m] [93mUnix TimeStamp: [92m%TimeStamp%
if "%GoNext%"=="TimeStamp2Date" echo  [90m[[92mx[90m] [93mMy time zone date: [92m%HumanReadableDate%
echo  [90m[[92mx[90m] [93mUTC date: [92m%UTCHumanReadableDate%
echo.
call :function_Diference "%HumanReadableDate%"
echo  [90m[[92mx[90m] [93mDiference: [92m%DiferenceText%[0m
echo.
echo  Press any key to exit . . .&pause>NUL&exit


:function_epochDate
for /f "tokens=*" %%a in ('powershell "Function get-epochDate ($epochDate) {[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($epochDate))}; get-epochDate %1"') do set HumanReadableDate=%%a
for /f "tokens=*" %%a in ('powershell "Function get-epochDate ($epochDate) {(([datetime]'1/1/1970').AddSeconds($epochDate))}; get-epochDate %1"') do set UTCHumanReadableDate=%%a
goto :EOF

:function_Diference
for /f "tokens=*" %%a in ('powershell -Command "$Date=Get-Date;(New-TimeSpan -Start '%1' -End $Date).TotalSeconds, $Date"') do (
	if not defined TotalSeconds set TotalSeconds=%%a
	set MyDate=%%a
)
echo  [90m[ ] [93mMy Date now: [92m%MyDate% [32mUTC%timezone% [93mcalculating diference...[0m
for /f "tokens=1 delims=-," %%1 in ("%TotalSeconds%") do set Seconds=%%1

for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/31556926)"') do set Years=%%a
for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/2629743)"') do set Months=%%a
for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/604800)"') do set Weeks=%%a
for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/86400)"') do set Days=%%a
for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/3600)"') do set Hours=%%a
for /f %%a in ('powershell -Command "[math]::Round(%Seconds%/60)"') do set Minutes=%%a
if not "%Seconds%"=="0" set Diference=%Seconds%&set DiferenceType=Second/s
if not "%Minutes%"=="0" set Diference=%Minutes%&set DiferenceType=Minute/s
if not "%Hours%"=="0" set Diference=%Hours%&set DiferenceType=Hour/s
if not "%Days%"=="0" set Diference=%Days%&set DiferenceType=Day/s
if not "%Weeks%"=="0" set Diference=%Weeks%&set DiferenceType=Week/s
if not "%Months%"=="0" set Diference=%Months%&set DiferenceType=Month/s
if not "%Years%"=="0" set Diference=%Years%&set DiferenceType=Year/s
if "%TotalSeconds:~0,1%"=="-" (set DiferenceText=In %Diference% %DiferenceType%) else (set DiferenceText=It was %Diference% %DiferenceType% ago)
goto :EOF
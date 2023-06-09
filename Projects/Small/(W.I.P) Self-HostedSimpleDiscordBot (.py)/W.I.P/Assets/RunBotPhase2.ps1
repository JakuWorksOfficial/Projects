# No multiline strings were used to improve readability.

$BeforeWorkingDirectory = Get-Location
if ($BeforeWorkingDirectory -eq "Assets") {
    Set-Location -Path ".\.."
}

# Variables

$AssetsFolder = ".\Assets"
$BotScriptPath = ".\Assets\main.py"
$TokenFilePath = ".\Assets\Token.txt"

$RequiredPythonVersion = Get-Content -Path "$AssetsFolder\required-python-version.txt"
$RequirementsFilePath = "$AssetsFolder\requirements.txt"
$Requirements_Content = Get-Content -Path $RequirementsFilePath

# Python file exit codes:
$OverrideRetryExitCode = 1001

# Added a few spaces to make correctly defining the overlines/underlines easier.
$PythonVersionComment_Correct_Overline =  "      \/--------------------------------\/"
$PythonVersionComment_Correct =           "   *** C O R R E C T  V E R S I O N ! ! ! ***"
$PythonVersionComment_Correct_UnderLine = "      /\--------------------------------/\"

$VenvError_FirstTimeWrongAnswer = $true

$RestartBotIfStops = $false
$RestartBotIfStops_Answer_FirstTimeWrongAnswer = $true
$ResetDiscordBotToken_FirstTimeWrongAnswer = $true
$RestartBotIfStops_Answer = $false
$BotRetryDoBreak = $false

$BotCurrentRetriesCount = 0
$BotMaxRetriesCount = 3600
$BotRetrySleepSeconds = 10

# Script

Write-Output ""
Write-Output "-------------------------------------->"
Write-Output "NOTES:"
Write-Output " - Answer 'Y' means 'Yes'"
Write-Output " - Answer 'N' means 'No'"
Write-Output " - lowercase answers are also accepted"
Write-Output "<--------------------------------------"

Write-Output ""
Write-Output "----------------------------------------------->"
Write-Output "Attempting to activate the Virtual Environment!"
Write-Output "<-----------------------------------------------"


try {
    . ".\venv\Scripts\activate.ps1"
}


catch {

    while ($true) {

        $UserPythonVersion = python --version
        $PythonVersion_IsCorrect = $false

        $PythonVersionComment_Wrong = ""

        if ($UserPythonVersion -eq $RequiredPythonVersion) {
            $PythonVersion_IsCorrect = $true
        } else {
            $PythonVersionComment_Wrong = ", so the bot may not work properly."
        }

        Write-Output ""
        Write-Output "------------------------------------------------------------->"
        Write-Output "Something went wrong while activating the virtual environment:"
        Write-Output ""
        Write-Output "    Error:"
        Write-Output "    $_"
        Write-Output ""
        Write-Output "The script might run by using Your Python version and not the Virtual Environment's one."
        Write-Output "           -----"
        Write-Output ""
        Write-Output "$UserPythonVersion is currently used."
        Write-Output "This script was written for $RequiredPythonVersion$PythonVersionComment_Wrong"
        if ($PythonVersion_IsCorrect -eq $true) {
            Write-Output ""
            Write-Output $PythonVersionComment_Correct_Overline
            Write-Output $PythonVersionComment_Correct
            Write-Output $PythonVersionComment_Correct_Underline
        }
        Write-Output ""
        Write-Output "All the necessary modules will be installed."
        Write-Output ""
        Write-Output "    All necessary modules:"
        Write-Output "    Pattern: Module==Version"
        Write-Output ""
        Write-Output "    $Requirements_Content"
        Write-Output ""
        Write-Output "QUESTION:"
        Write-Output "    Do You want to continue? (Y/N)"
        $IgnoreVenvError = Read-Host
        Write-Output ""


        $IgnoreVenvError_ToLower = $IgnoreVenvError.ToLower()


        if ($IgnoreVenvError_ToLower -eq "y") {

            Write-Output "Registered answer: Y, continuing the script..."
            Write-Output "<-------------------------------------------------------------"
            break

        } elseif ($IgnoreVenvError_ToLower -eq "n") {

        Write-Output "Registered answer: N, ending the script..."
        Write-Output "<-------------------------------------------------------------"
        exit

        } else {

            Write-Output ""
            Write-Output "-------------------------------------->"
            Write-Output "YOUR ANSWER:"
            Write-Output $IgnoreVenvError
            Write-Output "WASN'T " '"Y", NOR "N"'

            if ($VenvError_FirstTimeWrongAnswer -eq $true) {

                $VenvError_FirstTimeWrongAnswer = $false

                Write-Output "Repeating the question in 3 seconds..."
                Write-Output "<--------------------------------------"
                Start-Sleep -Seconds 3

            } else {

                # If the user held enter instead of answering, there would be an insanely long ammount of time to wait, so the in next 'wrong answer' the script just won't sleep.

                Write-Output "Repeating the question..."
                Write-Output "<--------------------------------------"

            }

        }

    }

}


Write-Output ""
Write-Output "---------------------------------------------------->"
Write-Output "Making sure all the necessary modules are installed."
Write-Output "<----------------------------------------------------"
Write-Output ""


pip install -r $RequirementsFilePath --quiet --disable-pip-version-check


$TokenFileContent = Get-Content -Path $TokenFilePath

if ($TokenFileContent.Length -ne 0) {
    
    while ($true) {

        Write-Output ""
        Write-Output "------------------------------------------------------------------------------->"
        Write-Output "QUESTION:"
        Write-Output "    Previously You passed the following text as the Token of Your Discord bot:"
        Write-Output "    $TokenFileContent"
        Write-Output "    Do You want to use the Token You passed previously? (Y/N)"
        $ResetDiscordBotToken_Answer = Read-Host

        $ResetDiscordBotToken_Answer_ToLower = $ResetDiscordBotToken_Answer.ToLower()

        if ($ResetDiscordBotToken_Answer_ToLower -eq "y") {

            Write-Output "Registered answer: Y. The previous Token will be used. Continuing the script..."
            Write-Output "<-------------------------------------------------------------------------------"
            break

        } elseif ($ResetDiscordBotToken_Answer_ToLower -eq "n") {
            
            Clear-Content -Path $TokenFilePath

            Write-Output "Registered answer: N. The Token has been cleared..."
            Write-Output "<-------------------------------------------------------------------------------"
            break

        } else {
            Write-Output ""
            Write-Output "-------------------------------------->"
            Write-Output "YOUR ANSWER:"
            Write-Output $ResetDiscordBotToken_Answer
            Write-Output "WASN'T " '"Y", NOR "N"'

            if ($ResetDiscordBotToken_FirstTimeWrongAnswer -eq $true) {

                $ResetDiscordBotToken_FirstTimeWrongAnswer = $false
            
                Write-Output "Repeating the question in 3 seconds..."
                Write-Output "<--------------------------------------"
                Start-Sleep -Seconds 3

            } else {

                Write-Output "Repeating the question..."
                Write-Output "<--------------------------------------"

            }
        }

    }

}


while ($true) {
    Write-Output ""
    Write-Output "----------------------------------------------------------------------------------->"
    Write-Output "QUESTION:"
    Write-Output "    Do You want to automatically restart the bot in case it crashes or stops? (Y/N)"
    $RestartBotIfStops_Answer = Read-Host

    $RestartBotIfStops_Answer_ToLower = $RestartBotIfStops_Answer.ToLower()

    if ($RestartBotIfStops_Answer_ToLower -eq "y") {

        $RestartBotIfStops = $true
        Write-Output "Registered answer: Y. The bot WILL automatically restart."
        Write-Output "<-----------------------------------------------------------------------------------"
        break

    } elseif ($RestartBotIfStops_Answer_ToLower -eq "n") {

        $RestartBotIfStops = $false
        Write-Output "Registered answer: N. The bot WON'T automatically restart."
        Write-Output "<-----------------------------------------------------------------------------------"
        break

    } else {
        
        Write-Output ""
        Write-Output "-------------------------------------->"
        Write-Output "YOUR ANSWER:"
        Write-Output $RestartBotIfStops_Answer
        Write-Output "WASN'T " '"Y", NOR "N"'

        if (($RestartBotIfStops_Answer_FirstTimeWrongAnswer -eq $true) ) {

            $RestartBotIfStops_Answer_FirstTimeWrongAnswer = $false
            
            Write-Output "Repeating the question in 3 seconds..."
            Write-Output "<--------------------------------------"
            Start-Sleep -Seconds 3

        } else {

            Write-Output "Repeating the question..."
            Write-Output "<--------------------------------------"

        }

    }

}


Write-Output ""
Write-Output "------------------------->"
Write-Output "Setup Finished!"
Write-Output "Starting the Discord bot!"
Write-Output "<-------------------------"
Write-Output ""


if ($RestartBotIfStops -eq $true) {

    while ($BotRetryDoBreak -eq $false -and $LASTEXITCODE -ne $OverrideRetryExitCode) {

        $BotRetriesCountBefore = $BotCurrentRetriesCount


        try {
            
            python $BotScriptPath

            Write-Output ""
            Write-Output ""
            Write-Output "--------------------------------------------------------------------------------------------------------->"
            Write-Output "The $BotScriptPath file has stopped its execution!"
            if ($LASTEXITCODE -ne $OverrideRetryExitCode) {
                Write-Output "The Discord Bot has stopped and needs to retry!"
                Write-Output "Relaunching $BotScriptPath in $BotRetrySleepSeconds seconds..."
            }
            Write-Output "<---------------------------------------------------------------------------------------------------------"

        }


        catch {

            $BotCurrentRetriesCount = $BotCurrentRetriesCount + 1

            Write-Output ""
            Write-Output "------------------------------------------->"
            Write-Output "Couldn't launch $BotScriptPath."
            Write-Output ""
            Write-Output "    ERROR:"
            Write-Output "    $_"
            Write-Output ""
            Write-Output "Retrying in $BotRetrySleepSeconds seconds.."
            Write-Output "Retry: $BotCurrentRetriesCount out of $BotMaxRetriesCount."
            Write-Output "<-------------------------------------------"
        }


        if ($BotCurrentRetriesCount -eq $BotRetriesCountBefore) { # If there was no retry (this could be replaced by 'else' in programming languages)

            $BotCurrentRetriesCount = 0 # Reset the counter if there was a successful retry.

        } elseif ($BotCurrentRetriesCount -ge $BotMaxRetriesCount) {

            Write-Output ""
            Write-Output ""
            Write-Output ""
            Write-Output "==================================================================>"
            Write-Output " ********** IMPORTANT **********"
            Write-Output " MAX AMMOUNT OF RETRIES REACHED ($BotMaxRetriesCount)"
            Write-Output ""
            Write-Output " THE SCRIPT WILL STOP EXECUTING AND NO LONGER RETRY TO SAVE POWER."
            Write-Output " ********** IMPORTANT **********"
            Write-Output "<=================================================================="
            
            break

        }

        if ($LASTEXITCODE -ne $OverrideRetryExitCode) {

            Start-Sleep $BotRetrySleepSeconds

            Write-Output ""
            Write-Output "----------->"
            Write-Output "Retrying..."
            Write-Output "<-----------"

        }
    }


} else {
    python $BotScriptPath
}


Write-Output ""
Write-Output ""
Write-Output "--------------------------------------------------------------------------------------------------------->"
Write-Output "This script has finished it's execution Bye!"
Write-Output "The Discord Bot has stopped! The $BotScriptPath file has stopped its execution!"
Write-Output "<---------------------------------------------------------------------------------------------------------"
Write-Output ""
Write-Output "Close the terminal or restart the bot if You want to..."
Write-Output ""

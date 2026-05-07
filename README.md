# hanwha-people-counting-web
A lightweight PowerShell middleware that fetches real-time people counting data from Hanwha AI cameras and displays it on a clean web dashboard for Nx Witness layouts.

Hanwha Vision Occupancy Dashboard for Nx Witness

A lightweight PowerShell middleware that fetches real-time people counting data from Hanwha AI cameras and displays it on a clean web dashboard for Nx Witness layouts.
What it does

    Live Extraction: Polls Hanwha SUNAPI every second for In/Out counts.

    Occupancy Logic: Calculates how many people are currently inside (In - Out).

    HTML Generation: Overwrites a local index.html file used by IIS.

    Nx Witness Integration: Allows the dashboard to be added as a "Web Page" in the VMS.

Prerequisites

    Windows 10/11 or IoT with IIS (Internet Information Services) enabled.

    Hanwha AI Camera (Q or X series) with People Counting enabled on Line 1.

    Nx Witness VMS to display the result.

Quick Setup

    IIS: Create a website on port 28999 pointing to C:\inetpub\Comptage.

    Script:

        Download hanwha-nx-occupancy.ps1.

        Edit the $cameraIp, $userCam, and $passCam variables.

        Run the script as Administrator (to allow file writing).

    Nx Witness: Add a new Web Page with the URL: http://127.0.0.1:28999.

Configuration

The script is highly customizable via the header variables:

    $refresh: Update frequency in seconds (default: 1).

    $htmlPath: Destination path for the web page.

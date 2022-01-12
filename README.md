[![DOI](https://zenodo.org/badge/447045677.svg)](https://zenodo.org/badge/latestdoi/447045677)

# Egg Yolk Counter Macro
This macro allows for user-assisted counting of egg-yolks within a single large egg-sac.

Briefly this macro finds objects within a user drawn ROI, and then allows for user-directed refinement (deletion/addition).

This macro is written in the ImageJ Macro Language.


## Running the script
1. The first screen to appear is the main splash screen displaying information about the script and its author.
2. The second dialog box warns the user to note what the file extension is and that the next screen is the directory location window.
3. Next, the user can select the working directory location.
4. The following window allows the user to set parameters for this script it includes the expected file extension.
5. Next the first image will open, and the user is asked to draw around the total egg-sac.
6.The script will then attempt to automaticaly find the yolks using the find maxima command. The user can update the prominance number here.
Decreasing the prominance will result in more yolks being found, and increasing it will result in less being found.
Once satisfied, check the box on the dialog prompt and the script will continue.
7. Next the script enters deletion mode. Here windows are synchronised (under prompt) and the user draws around errant points flagging them for deletion.
The user can confirm no more points require deletion before moving on.
8. Next the script enters additiona mode. Here again windows are sycronised and any extra yolks can be added by clicking on their location in the Points window.
9. Once completed the script will move to the next image file in the directory, or finish.

## Output Files
- Log.txt - This records the script version, run date and time.
- Results.csv - This is the tabulated count spreadsheet
- Filename_All-Points.zip - Total Yolk ROIs
- Filename_points.tif - Image File of points
- Filename_totalAreaROI.zip - Egg Sac ROI area

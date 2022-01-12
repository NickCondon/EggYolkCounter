print("\\Clear");

//	This script has been made with the help of Nicholas Condon's script Generator

//	MIT License
//	Copyright (c) 2021 Nicholas Condon , n.condon@uq.edu.au
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//Script info
scripttitle= "Weili - Find Maxima Script";
version= "1.0";
date= "11-06-2021";
description= "This script asks the user to first generate an ROI around the egg region, then allows for user directred deletion excess selections, and the ability to add any that were missed.";

showMessage("ImageJ Script Information Box", "<html>
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> 
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><h4> </P4>"
    +"<h3>   <h3>"    
    +"<p1><font size=3  i>"+description+"</p1>
    +"<p1><font size=3> <br><br> Output results are saved into a results directory including an image of the found points and a tabulated spreadsheet. </p1>"  
	   +"<h0><font size=5> </h0>"
    +"");
//Reporting script info to log
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" Version Date: "+date);
print("By Nicholas Condon (2021) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder for output files) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
  	Dialog.addMessage("All open windows, ROIs, Results will be closed or cleared if continueing.");
Dialog.show(); 

//Cleaning up Workspace
run("Clear Results");
roiManager("reset");
while(nImages>0){close();}

//Working Directory Location & File List
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
getDateAndTime(year, month, week, day, hour, min, sec, msec);

//Input parameters
ext = ".tif";
Dialog.create("Settings");
Dialog.addString("File Extension: ", ext);
Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
Dialog.show();
ext = Dialog.getString();

//Reporting parameters to log	
print("**** Parameters ****");
print("File extension: "+ext);
print("");

//Creates Directory for output images/logs/results table
resultsDir = path+"_Results_ROIs"+"_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/"; 
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);
print(" * * * * * * * * * * * * * * * * * * * * *");
print("");

//Saves and clears the log window
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");
print("\\Clear");

//Prints headers for the output CSV
print("Filename, ImageNum, Initial eggs found, NumEggs after deletion, NumEggs Added, Final NumEggs");
		
//Main script file opening loops
for (z=0; z<list.length; z++) {
if (endsWith(list[z],ext)){

	//Cleaning Workspace
	run("Clear Results");
	roiManager("reset");

	//Opening image & getting file name
	run("Bio-Formats Importer", "open=["+path+list[z]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	windowtitle = getTitle();
	windowtitlenoext = replace(windowtitle, ext, "");

	//Making a copy of the image to create egg sac ROI
	run("Duplicate...", "title=inverted");
	run("Invert");

	//Getting ready for User input Drawing Selection
	selectWindow(windowtitle);
	run("Clear Results");
	setTool("freehand");
	waitForUser("Draw around the egg area in the image and then click OK");

	//exit if no selection made
	if (selectionType()==-1) {
		waitForUser("No selection was made, moving on to next image.");
		break;
		}
	//Adding selection to ROI Manager + Saving ROIS
	roiManager("add");
	roiManager("save", resultsDir+ windowtitlenoext+"_totalAreaROI.zip");

	//User adjustable settings for individual egg detection
	prominence=0;
	maxima = 35;

	//Finding initial sweep of eggs	
	while (prominence==0) {
		//Selects main window and ensures the totalArea ROI is loaded
		selectWindow(windowtitle);
		roiManager("reset");
		roiManager("Open", resultsDir+ windowtitlenoext+"_totalAreaROI.zip");
		roiManager("select",0);
		//Finds maxima points within the user defined ROIs
		run("Find Maxima...", "prominence="+maxima+" strict output=[Single Points]");
		rename("points");
		run("Dilate");
		run("Dilate");
		run("Tile");
		//Clears ROI manager ready for new points found
		roiManager("reset");
		selectWindow("points");
		run("Analyze Particles...", "exclude add");
		predeleteROI = roiManager("count");
		selectWindow(windowtitle);
		roiManager("Show All without labels");
		
		roiManager("Set Color", "yellow");
		roiManager("Set Line Width", 10);
		
		Dialog.create("Maxima Check");
			Dialog.addMessage("Does that maxima prominence work?");
			Dialog.addNumber("Maxima Used", maxima);
			Dialog.addMessage("Change the number above if you want to try again.");
			Dialog.addCheckbox("Happy with this Maxima and ready to move on.", 0);
			Dialog.show();
		maxima = Dialog.getNumber();
		prominence = Dialog.getCheckbox();
		if(prominence==0){
			selectWindow("points");
			close();
			}
		}
		
		predeleteROI = roiManager("count");

	//Deleting excess points loop
		waitForUser("Script will now enter deleting mode.");
		delete = 0;
		run("Synchronize Windows");
		waitForUser("Click Synchronize All button");
		waitForUser("Script will now enter deleting mode.");

		while(delete == 0){
			//Setting up for deletion
			setBackgroundColor(0, 0, 0);
			setForegroundColor(0, 0, 0);
			run("Select None");	
			setTool("freehand");
			selectWindow("points");
			roiManager("reset");
			run("Analyze Particles...", "exclude add");
			selectWindow("inverted");
			roiManager("show all without labels");
			roiManager("Set Color", "black");
			roiManager("Set Line Width", 5);
			selectWindow("points");
			roiManager("show all without labels");
			roiManager("Set Color", "yellow");
			//Prompts user to draw around excess selections to mark for deletion
			waitForUser("Draw around an area of points to delete.");
			selectWindow("points");
			if(selectionType() !=-1) {
				setForegroundColor(0, 0, 0); 
				run("Fill", "slice");
				}
						
			Dialog.create("Deleting Points Completion");
				Dialog.addMessage("If there are no more points to delete and you are ready to move onto the next image click the following checkbox");
				Dialog.addCheckbox("Finished this image?", 0);
				Dialog.show();
			delete = Dialog.getCheckbox();
			}

		//Finds and counts number of ROIs after deleting
		selectWindow("points");
		run("Select None");	
		roiManager("reset");
		run("Analyze Particles...", "exclude add");
		afterdelROI = roiManager("count");


	//Adding any missed ROIs loop
		selectWindow("points");
		getDimensions(width, height, channels, slices, frames);
		add = 0;
		waitForUser("Script will now enter adding mode. Remember to always work on the Black image called Points");
		
		while(add == 0){
			setBackgroundColor(0, 0, 0);
			setForegroundColor(255, 255, 255);
			lastROI = roiManager("count");
			selectWindow("inverted");
			run("Select None");	
			selectWindow("points");
			run("Select None");	
			setTool("multipoint");
			waitForUser("On the image window called Points, click on any points that have been missed. Clicking OK will then add them to the image. You can add more after this.");
			//If any new points added loop will run
			if(selectionType() !=-1){
				roiManager("add");
				newImage("newpoints", "8-bit black", width, height, 1);
				roiManager("select", lastROI);
				run("Enlarge...", "enlarge=4");
				run("Fill", "slice");
				run("Dilate");
				run("Select All");
				imageCalculator("XOR", "points","newpoints");
				selectWindow("newpoints");close();
				}
			//Finds and adds the points to the ROI list
			selectWindow("points");
			roiManager("reset");
			run("Select None");	
			run("Analyze Particles...", "exclude add");
			selectWindow("inverted");
			roiManager("show all without labels");

			Dialog.create("Adding Step Completion");
				Dialog.addMessage("If there are no more points to add click the following checkbox");
				Dialog.addCheckbox("Finished adding points?", 0);
				Dialog.show();
			add = Dialog.getCheckbox();
			}
		//Updates ROI list with any new points and updates count info.
		selectWindow("points");
		roiManager("reset");
		run("Analyze Particles...", "exclude add");
		//Calculates out the number of ROIs and adds it to the output list.
		afterAddROI = roiManager("count");
		numROIadded = afterAddROI-afterdelROI;
		print(windowtitle+","+(z+1)+","+predeleteROI+","+afterdelROI+","+numROIadded+","+afterAddROI);
		//Saves output image points
		selectWindow("points");
		saveAs("Tiff", resultsDir+ windowtitlenoext+"_points.tif");
		//If theres anything in the ROI manage it will be saved
		if (roiManager("count") !=0){ 
			roiManager("save", resultsDir+ windowtitlenoext+"_All-Points.zip");
			}
		while(nImages>0){close();}
	}
}

//Saves the output results as a CSV
selectWindow("Log");
saveAs("Text", resultsDir+"Results.csv");
//exit message to notify user that the script has finished.
title = "Batch Completed";
msg = "Put down that coffee! Your analysis is finished";
waitForUser(title, msg);

// Define the input directory (contains one folder for each figure)
inputDir = getDirectory("Select master folder");
outputDir = substring(inputDir, 0, lengthOf(inputDir) - 1) + "__bw_output/";
File.makeDirectory(outputDir);

// each folder in 'figures' contains one folder for every condition presented in the figure
figures = getFileList(inputDir);

// Loop through each folder in the directory
for (k = 0; k < figures.length; k++) {
	// each folder in conds contains 9 images (3 BR * 3 TR) for one condition
	conds = getFileList(inputDir + figures[k]);
	
	File.makeDirectory(outputDir + figures[k]);
	File.makeDirectory(outputDir + "Results/");
	
	for (l = 0; l < conds.length; l++) {
		// Get a list of all files in the directory
		files = getFileList(inputDir + figures[k] + conds[l]);
		File.makeDirectory(outputDir + figures[k] + conds[l]);
		File.makeDirectory(outputDir + figures[k] + conds[l] + "1_Mask/");
		File.makeDirectory(outputDir + figures[k] + conds[l] + "2_RemoveOutliers/");
		File.makeDirectory(outputDir + figures[k] + conds[l] + "3_Drawing/");
		File.makeDirectory(outputDir + figures[k] + conds[l] + "4_Overlay/");
		
		// Loop through each file in the directory
		
		for (i = 0; i < files.length; i++) {
			start_time = getTime();
		    // Get the full path of the current file
		    filePath = inputDir + figures[k] + conds[l] + files[i];
		    
		    // Open the current file
		    open(filePath);
			run("8-bit");
			setAutoThreshold("Default no-reset");
			//run("Threshold...");
			setThreshold(0, 135, "raw");
			//setThreshold(0, 100);
			run("Convert to Mask");
			saveAs("Tiff", outputDir + figures[k] + conds[l] + "1_Mask/" + "mask_" + files[i]);
			selectImage("mask_" + files[i]);
			
			run("Despeckle");
			run("Remove Outliers...", "radius=30 threshold=50 which=Bright");
			//run("Remove Outliers...", "radius=11 threshold=50 which=Dark");
			run("Fill Holes");
			//run("Watershed");
			saveAs("Tiff", outputDir + figures[k] + conds[l] + "2_RemoveOutliers/" + "outliers_" + files[i]);
			selectImage("outliers_" + files[i]);

			run("Analyze Particles...", "size=1300-Infinity show=Outlines display overlay");
			saveAs("Tiff", outputDir + figures[k] + conds[l] + "3_Drawing/" + "drawing_" + files[i]);
			open(filePath);
			run("Add Image...", "image=[drawing_" + files[i] + "] x=0 y=0 opacity=60");
			run("Flatten");
			saveAs("Tiff", outputDir + figures[k] + conds[l] + "4_Overlay/" + "overlay_" + files[i]);
			close("*");	
			end_time = getTime();
			time_taken = end_time - start_time;
			print("Time taken:", time_taken);
		}
	}
	selectWindow("Results");
	saveAs("Results", outputDir + "Results/" + substring(figures[k], 0, lengthOf(figures[k]) - 1) + ".csv");
	run("Close");

}
print("end");
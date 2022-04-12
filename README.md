# ventricle-detection
A tool for ventricular contours detection. 

<p align="center">
  <img src="https://user-images.githubusercontent.com/75421723/163014118-ec0cbe04-7944-48c3-b0fb-03dd9115603f.gif" alt="9TBP" width="300"/>
</p>

An hospital needs to evaluate some new software for automated detection of ventricular contours. In order to provide them with a tool to obtain a “gold standard” manually traced contours, an m-code is implemented that:
- it allows the user, by using the proper I-O interface, to select the first file from a folder containing DICOM images acquired with the same sequence;
- from the selected file, it proceed in reading the information contained in the DICOM header: find the image dimensions and the total number of images, then use these parameters to initialize a 3D array of zeros named Icat; 
- it reads the DICOM images from the first to the last, so to fill in the ```Icat``` array; 
- for each frame, it performs histogram stretching, then ask the user to trace the contours of the endocardium (the inner contour) of the left ventricle (you can close the contours at the ventricular base). From the obtained polygon, it extracts the coordinates of its boundaries and save the coordinates as proper field in a struct array;
- when finished, it visualizes each frame with its contours overimposed as red dots (use hold on and plot), and it asks the user if he is satisfied with the traced contours: if yes, it saves the 3D struct array, if not, go back to the previous point.



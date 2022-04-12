clear all
close all
clc

% The I-O interface is implemented using the uigetfile function that displays 
% a dialog box in order to allow the user to select the first '.IMA' DICOM image from
% the current folder. The function returns the filename and path strings of
% the selected image. 

[filename, pathname] = uigetfile('*.IMA', 'Pick the first DICOM file');

% Once obtained the filename string of the selected image, the DICOM image is
% read using the proper dicomread MATLAB command. The function returns the
% data of the image in the matrix 'I' and in the case of indexed image the color map 'm'.
% In the 'figure (1)', the selected image is shown. 

[I, m]= dicomread(filename); 
figure (1), imshow(I, []), title ('Selected Original Image'); 

% The DICOM header information content of the selected image is read using the dicominfo
% command. The header information can be read accessing the resulting
% struct array 'info'. 

info= dicominfo (filename); 

% The image dimensions (height and width) and the total number of images 
% are extracted from the header struct array using the reported notation. 

im_height=info.Height; 
im_width= info.Width; 
im_num= info.CardiacNumberOfImages; 

% The 'Icat' 3D array has been initialized using the command zeros. The resulting 3D
% array has as dimensions 'im_height-by-im_width-by-im_num'.

Icat= zeros (im_height, im_width, im_num); 

% In order to fill the Icat array with the DICOM images, all the images in the 
% current folder are firstly listed in the folder 'images' using the dir command. 
% Then using a loop all the images listed are read and saved in the 'Icat' array 
% using the dicomread function. In order to avoid the saturation of the
% uint16 video intensity values, prior the filling of the Icat double
% array, the conversion to double values is performed using the im2double
% command. The display of all the images is proposed. 

images = dir ('*.IMA'); 
for i=1:length (images)
    Icat (:, :, i)=im2double(dicomread(images(i).name)); 
    figure (26), subplot (5, 5, i),  imshow (Icat (:, :, i), []), title(['Image ',num2str(i),'']); 
    
     
    % In order to enhance the contrast in the images, the stretchlim function
    % has been used to find the optimal gray value limits to then stretch
    % the histogram images with the imadjust command. 
    % In 'figure (28)' the high contrast images are shown. 
    
    
    Icat_st (:, :, i)= imadjust (Icat (:, :, i), stretchlim (Icat (:, :, i)), []);
   
    figure (28), subplot (5, 5, i),  imshow (Icat_st (:, :, i), []), title(['Stretched Image ',num2str(i),'']); 
end 

% An I-O interface is proposed using the questdlg command in order to ask the user 
% to select a ROI for each image.   

ans = 'No';
while strcmp (ans, 'No')
    
    for i=1:length (images)
        
        n_ans = 'No';
        p_ans = questdlg('Do you want to select a ROI?','Yes','No');
        
        % A positive answer allows the user to trace the desired contours of a ROI
        % with the imfreehand command, a negative one allows the user to skip the 
        % current image contouring and to proceed with the subsequent one. 
        
        if strcmp(p_ans,'Yes')
            while strcmp(n_ans,'No')

               figure (i),imshow (Icat_st (:, :, i)), title(['Image ',num2str(i),'']); 
               e =imfreehand;  
               
               % Visualization of the binary image of the traced contour. 
               
               m= createMask (e); 
               c = bwperim(m); 
               figure (29), imshow(c), title(['Contour Image  ',num2str(i),'']); 
               
               % For each image the result confirmation is asked to the user,
               % a positive answer allows the user to proceed with the
               % contouring of the subsequent image and the coordinates of
               % the contour to be saved in the 'coord_cont' struct;
               % a negative one offers the user the chance to try the contouring again.
               
               n_ans = questdlg('Confirm the selected ROI?','Yes','No');
               [row_y, col_x] = find(c); 
               coord_cont(i).x= col_x;
               coord_cont(i).y= row_y;

               % At each iteration the resulting contouring is shown in red
               % superimposed to the current contrasted image. 
               
               figure (30), subplot (5, 5, i),  imshow (Icat_st (:, :, i)), title(['Image ',num2str(i),'']),...
                      hold on, plot ( coord_cont(i).x (:, :), coord_cont(i).y (:, :),'.r'); 
               
            end

        end   
    end

% At the end, the final result is shown and the user is asked if satisfied
% of the traced contours. 

ans = questdlg('Are you satisfied with the traced contours?','Yes','No');

end 

% A positive answer to the previous question allows the user to save the
% struct containing the coordinates of the contours traced for each image
% 'coord_cont' with the desidered name; a negative one brings the user back to
% the ROI selection (Ex. 1.2d section). 

[name_coord, path_coord]=uiputfile('*.mat', 'Save the coordinates of the ROI as:');

if isequal(name_coord,0) || isequal(path_coord,0)|| exist ('coord_cont')==0
   disp('User pressed cancel')
else 
   disp(['User selected ', fullfile(path_coord,name_coord)])
   save (name_coord, 'coord_cont')
end 

    


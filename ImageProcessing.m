%Uploaded image onto matlab workspace
% problems
% problem detecting my no shape kinematics available
% need to fix orientation for all the circles
picturePath = 'C:\Users\Owner\Documents\semester 8\CEG4158\Picture 31.jpg';
outputDataPath = 'C:\Users\Owner\Documents\semester 8\CEG4158\data.txt';
I = imread(picturePath);

% cropping to a desired image
cropImage = imcrop(I,[0 70 600 450]); % crops I starting at 0,0 for origin and the width 550 and the height 200
%converting to gray scale
grayImage = rgb2gray(cropImage); % turning the image into a gray scale image
grayThreshold = graythresh(grayImage);
% taking the binary representation for easier manipulation
BW = im2bw(grayImage, grayThreshold-.05 ); % perform a binary representating of the image
BW = ~BW;
%morphing

BW = bwmorph(BW, 'clean',100);
BW = bwmorph(BW, 'diag',100);
BW = bwmorph(BW, 'spur',100);
BW = bwmorph(BW, 'fill',100);
fileID = fopen(outputDataPath,'w');
fprintf(fileID, 'macro Project\n'); 
fprintf(fileID, 'move all to 0 \n');
imtool(BW)
%setting boundaries
[B,L] = bwboundaries(BW, 'noholes');
% region props
STATS = regionprops(L, 'all'); % we need 'BoundingBox' and 'Extent'
% Setting minimum parameters for comparison
referenceSet = false;
minPrec = 149 ;  minPsqu = 118;  minPtri = 85;  minPcir = 90;   %minimum Perimeter for a : Rectangle ; Square ; Triangle ; Circle
minArec = 1450; minAsqu =920 ; minAtri =500;   minAcir =810;  % minimum Area for an Object : Triangle ; Circle
minRefArea = 4900;  minRefPer = 400; % minimum Reference Area and perimeter
recAreaObjthreshFrame = 1200 ; squAreaObjthreshFrame =600; % to distinguish area difference between frame and object of a : rectangle ;
CirTriareaDifferenceThresh = 265; % to determine the threshold between an object and triangle frame
detectingHoles = 70; % used ti detect holes in the image and forget about them
rectangle = 'rectangle' ; triangle = 'triangle' ; square = 'square' ; circle = 'Circle';
frame = 'frame' ; object = 'object';
closingGrip = 250;
%design a structure to hold each shape in the image
shape = struct('Sperimeter', {} , 'Sarea' , {} , 'Scentroid1', {} , 'Scentroid2' , {} ,'orientation' , {}, 'Sname' , {} ,'Stype', {} );
%set the structure shape parameters
for i = 1 : length(STATS) 
    centroid = STATS(i).Centroid;
    area = STATS(i).Area;
    perimeter= STATS(i).Perimeter; %perimeter
    orientation = STATS(i).Orientation;
    shape(i).Sperimeter = perimeter;
    shape(i).Sarea = area;
    shape(i).Scentroid1 = centroid(1);
    shape(i).Scentroid2 = centroid(2);
    shape(i).orientation = orientation;
    
end

% detetmining if the shape is a triangle, circle, rectangle , square or a
% reference
setSquareobj = 0;
setSquareFrame = 0;
setCircleobj = 0;
setCircleFrame = 0;
for i = 1 : length(STATS)
    
    if(shape(i).Sarea > detectingHoles) %detect holes
        % tests if it is a reference
        if shape(i).Sperimeter > minRefPer
                shape(i).Sname = 'reference';
                shape(i).Stype = 'reference';
        
        % test if it is a rectangle
        elseif shape(i).Sperimeter > minPrec && shape(i).Sperimeter < minRefArea
           
                shape(i).Sname = 'rectangle';
                if shape(i).Sarea < recAreaObjthreshFrame  %  to distinguish between frame and object of a rectangle
                    shape(i).Stype = 'frame';
                else
                    shape(i).Stype = 'object'; 
                end
       
       %test if it is a square
        elseif shape(i).Sperimeter > minPsqu && shape(i).Sperimeter < minPrec && (setSquareobj == 0 || setSquareFrame == 0)
                shape(i).Sname = 'square';
                if shape(i).Sarea < squAreaObjthreshFrame && setSquareFrame ==0 % to distinguish between frame and object of a square
                    shape(i).Stype = 'frame';
                    setSquareFrame = 1;
                    
                elseif shape(i).Sarea > squAreaObjthreshFrame && setSquareobj ==0
                    shape(i).Stype = 'object'; 
                    setSquareobj = 1;
                end
       %tests if it is a circle or a triangle
        elseif shape(i).Sperimeter > minPtri && shape(i).Sperimeter < minPsqu 
                %checks if it is a circle object
                if shape(i).Sarea > minAcir  && setCircleobj == 0 % to detect it is a circle and an object
                    shape(i).Sname = 'Circle';
                    shape(i).Stype = 'object'; 
                    setCircleObj =1 ;
      %checks if it is a triangle object
                elseif shape(i).Sarea <minAcir && shape(i).Sarea > minAtri % to detect it is a triangle and an object
                    shape(i).Sname = 'triangle';
                    shape(i).Stype = 'object';
                    
      %checks if it s circle frame
                elseif shape(i).Sarea > CirTriareaDifferenceThresh && setCircleFrame ==0 % to detect if its a frame circle
                    shape(i).Sname = 'Circle';
                    shape(i).Stype = 'frame'; 
                    setCircleFrame = 1;
      
       %checks if it s triangle frame
                elseif shape(i).Sarea < CirTriareaDifferenceThresh  %  to detect if its a frame triangle
                    shape(i).Sname = 'triangle';
                    shape(i).Stype = 'frame'; 
                end
        end
    % define it is not a shape
    else
        shape(i).Sname = 'notAshape';
        shape(i).Stype = 'notAshape';
    end
end

% Develop Matrix

% start with Rectangle
% followed by square
% followed by circle
% followed by Triangle
allshapeFound = 0;
for k = 1:length(STATS)
    if strcmp(shape(k).Stype , object) == 1
        allshapeFound = allshapeFound + 1;
    end
end

foundRec = 0; foundTri = 0; foundSqu = 0; foundCir = 0;
Rxpix = 533;
Rypix = 42;
pixtomm = 1.3437;

Q1 = [0 1 0 307 ; 1 0 0 -224; 0 0 -1 7.58 ; 0 0 0 1];
Q2 = [1 0 0 (Rxpix/pixtomm) ; 0 1 0 (Rypix/pixtomm) ; 0 0 1 0 ; 0 0 0 1];


safeguard = 50;
while allshapeFound > 0 && safeguard  > 0
  i = 1; 
    while i <= length(STATS)
    j =1;
  
    if (strcmp(shape(i).Sname ,rectangle)==1) && (strcmp(shape(i).Stype , object) == 1) && (i <= length(STATS)) && (foundRec == 0)

     while j <= length(STATS) && foundRec == 0
             
            if strcmp(shape(j).Sname , rectangle)==1 && strcmp(shape(j).Stype , frame) ==1
                if shape(i).orientation < 0
                    Qrecobj = [cosd(shape(i).orientation) -sind(shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(shape(i).orientation) cosd(shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                elseif shape(i).orientation > 0 
                    Qrecobj = [cosd(-shape(i).orientation) -sind(-shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(-shape(i).orientation) cosd(-shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                end
                if shape(j).orientation < 0
                    Qrecframe = [cosd(shape(j).orientation) -sind(shape(j).orientation) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(shape(j).orientation+90) cosd(shape(j).orientation+90) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                elseif shape(j).orientation > 0    
                    Qrecframe = [cosd(-shape(j).orientation) -sind(-shape(j).orientation) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(-shape(j).orientation) cosd(-shape(j).orientation) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                end
                        fprintf('Found Rectangle \n');
                         Qrectangleobj = Q1*Q2*Qrecobj;
                A = Qrectangleobj;
                fprintf(fileID , 'move 6 to -1400 \n');
                A(1) = -1*A(1);
                A(2) = -1*A(2);
                A(5) = -1*A(5);
                A(6) = -1*A(6);
                InverseKinematicsAlgorithm(A, fileID);
            
                fprintf(fileID , 'move 6 to %.0f \n', closingGrip);
               
                fprintf(fileID, 'move 3 to 0 \n');
                fprintf(fileID, 'move 4 to 0 \n');
                QrectangleFrame = Q1*Q2*Qrecframe;
                A = QrectangleFrame;
                A(1) = -1*A(1);
                A(2) = -1*A(2);
                A(5) = -1*A(5);
                A(6) = -1*A(6);
            InverseKinematicsAlgorithm(A, fileID);
        
            fprintf(fileID , 'move 6 to -1400 \n');
             fprintf(fileID, 'move 1 by -150 \n');
            fprintf(fileID, 'move 3 to 0 \n');
            fprintf(fileID, 'move 4 to 0 \n');
            foundRec = 1;
            allshapeFound = allshapeFound - 1;
            j = 0;
            end
             j = j+1;

      end
  
    end
    
     if strcmp(shape(i).Sname , square)==1 && strcmp(shape(i).Stype , object) ==1 && i <= length(STATS) && foundSqu == 0
        
          while j <= length(STATS) && foundSqu == 0
            if strcmp(shape(j).Sname , square)==1 && strcmp(shape(j).Stype , frame) ==1
                if shape(i).orientation < 0
                    Qsquobj = [cosd(shape(i).orientation) -sind(shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(shape(i).orientation) cosd(shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                elseif shape(i).orientation > 0 
                    Qsquobj = [cosd(-shape(i).orientation) -sind(-shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(-shape(i).orientation) cosd(-shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                end
                Qsquframe = [cosd(shape(j).orientation) -sind(shape(j).orientation) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(shape(j).orientation) cosd(shape(j).orientation) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
            %enter code here to determine  Square Matrix 
            fprintf('Found Square \n');
            Qsquareobj = Q1*Q2*Qsquobj;
            A = Qsquareobj;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            fprintf(fileID , 'move 6 to -1400 \n');

            InverseKinematicsAlgorithm(A , fileID);
           %  fprintf(fileID, 'move 1 by 100 \n');
            fprintf(fileID , 'move 6 to %.0f \n', closingGrip);
            fprintf(fileID, 'move 3 to 0 \n');
            fprintf(fileID, 'move 4 to 0 \n');
            QsquareFrame = Q1*Q2*Qsquframe;
            A = QsquareFrame;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            InverseKinematicsAlgorithm(A , fileID);
            %fprintf(fileID, 'move 1 by 100 \n');
            fprintf(fileID , 'move 6 to -1400 \n');
            fprintf(fileID, 'move 1 by -150 \n');
            fprintf(fileID, 'move 3 to 0 \n');
            fprintf(fileID, 'move 4 to 0 \n');
            foundSqu = 1;
            allshapeFound = allshapeFound - 1;
            j = 0;
            end
            j = j+1;

          end
          
   
         
     end
         
        if strcmp(shape(i).Sname ,circle)==1 && strcmp(shape(i).Stype , object) ==1 && i <= length(STATS) && foundCir == 0
        
          while j <= length(STATS) && foundCir == 0
            if strcmp(shape(j).Sname ,circle)==1 && strcmp(shape(j).Stype ,frame) == 1
            Qcirobj = [cosd(-60) -sind(-60) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(-60) cosd(-60) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
            Qcirframe = [cosd(-60) -sind(-60) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(-60) cosd(-60) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
            %enter code here to determine  Square Matrix 
             fprintf('Found Circle \n');
            Qcircleobj = Q1*Q2*Qcirobj;
            A = Qcircleobj;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            fprintf(fileID , 'move 6 to -1400 \n');
            InverseKinematicsAlgorithm(A,fileID);
         
             fprintf(fileID , 'move 6 to %.0f \n', closingGrip);
               
                fprintf(fileID, 'move 3 to 0 \n');
                fprintf(fileID, 'move 4 to 0 \n');
            QcircleFrame = Q1*Q2*Qcirframe;
            A = QcircleFrame;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            InverseKinematicsAlgorithm(A,fileID);
         
            fprintf(fileID , 'move 6 to -1400 \n');
             fprintf(fileID, 'move 1 by -150 \n');
            fprintf(fileID, 'move 3 to 0 \n');
            fprintf(fileID, 'move 4 to 0 \n');
            foundCir = 1;
            allshapeFound = allshapeFound - 1;
           j = 0;
            end
            j= j+1;

        
          end      
        end
    
        if strcmp(shape(i).Sname , triangle)==1 && strcmp(shape(i).Stype , object)==1 && i <= length(STATS) && foundTri == 0
        
          while j <= length(STATS) && foundTri == 0
            if strcmp(shape(j).Sname , triangle) && strcmp(shape(j).Stype , frame) ==1
              
                if shape(i).orientation < 0
                    Qtriobj = [cosd(shape(i).orientation) -sind(shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(shape(i).orientation) cosd(shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                elseif shape(i).orientation > 0 
                    Qtriobj = [cosd(-shape(i).orientation) -sind(-shape(i).orientation) 0 -1*((shape(i).Scentroid1)/pixtomm); sind(-shape(i).orientation) cosd(-shape(i).orientation) 0  -1*((shape(i).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                end
                if shape(j).orientation < 0
                    Qtriframe = [cosd(shape(j).orientation) -sind(shape(j).orientation) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(shape(j).orientation+90) cosd(shape(j).orientation+90) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                elseif shape(j).orientation > 0    
                    Qtriframe = [cosd(-shape(j).orientation) -sind(-shape(j).orientation) 0 -1*((shape(j).Scentroid1)/pixtomm); sind(-shape(j).orientation) cosd(-shape(j).orientation) 0  -1*((shape(j).Scentroid2)/pixtomm); 0 0 1 0 ; 0 0 0 1];
                end
                %enter code here to determine  Square Matrix
            fprintf('Found Triangle \n');
            Qtriangleobj = Q1*Q2*Qtriobj;
            A = Qtriangleobj;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            fprintf(fileID , 'move 6 to -1400 \n');
            InverseKinematicsAlgorithm(A,fileID);
             fprintf(fileID, 'move 1 by -50 \n');
                fprintf(fileID , 'move 6 to %.0f \n', closingGrip);
                fprintf(fileID, 'move 3 to 0 \n');
                fprintf(fileID, 'move 4 to 0 \n');
            QtriangleFrame = Q1*Q2*Qtriframe;
            A = QtriangleFrame;
            A(1) = -1*A(1);
            A(2) = -1*A(2);
            A(5) = -1*A(5);
            A(6) = -1*A(6);
            InverseKinematicsAlgorithm(A,fileID);
             fprintf(fileID, 'move 1 by -100 \n');
            fprintf(fileID , 'move 6 to -1400 \n');
            fprintf(fileID, 'move 1 by -150 \n');
            fprintf(fileID, 'move 3 to 0 \n');
            fprintf(fileID, 'move 4 to 0 \n');
            foundTri = 1;
            allshapeFound = allshapeFound - 1;
            j = 0;
            
            end
            j=j+1;

          end
         
        end
     i = i+1;
    
    end
  safeguard = safeguard -1;
end
fprintf(fileID, 'move all to 1400 \n');
fprintf(fileID,'end\n');

fprintf(fileID, 'Project 1');
 fclose(fileID);


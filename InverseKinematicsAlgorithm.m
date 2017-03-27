%parameters
%syms q11 q22 q21 q32 q31 q33 q23 q13 Tx Ty Tz
function InverseKinematicsAlgorithm(A , fileID)
q11 = A(1);
q21 = A(2);
q31 = A(3);
%q41 = A(4);
q12 = A(5);
q22 = A(6);
q32 = A(7);
q42 = A(8);
q13 = A(9);
q23 = A(10);
q33 = A(11);
q43 = A(12);
Tx = A(13);
Ty = A(14);
Tz = A(15);
q41 = A(16);
theta1 = 'empty';
theta2 = 'empty';
theta3 = 'empty';
theta4 = 'empty';
theta5 = 'empty';
%Predefining Functions

try

%Theta 5
if q31 ~= 0
theta5 = atan(-q32 / q31);
end
%if(q33 =)
    
    %add another method to findf theta 5

%end

%Theta 4

sintheta4 = q33*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2) - sqrt(q13^2 + q23^2) * ((Tz-150-100*q33)/60);
costheta4 = sqrt(q13^2 + q23^2) * sqrt(1 - ((Tz - 150 - 100*q33)/60)^2) + q33*((Tz-150-100*q33)/60);


theta4 = atan(sintheta4 / costheta4);

%Theta 3

theta3  = asin((Tz - 150 - 100*q33) / 60);



if q33 ~= 1 || q33 ~= -1
%Theta 1
costheta1 = (Tx - (q13/sqrt(q13^2 + q23^2))*(90+100*sqrt(q13^2 + q23^2) + 60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2)))/90;
sintheta1 = (Ty - (q23/sqrt(q13^2 + q23^2))*(90+100*sqrt(q13^2 + q23^2) + 60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2)))/90;
theta1 = atan(sintheta1 / costheta1);
%Theta 2
costheta2 = (q13 / sqrt(q13^2 + q23^2))*costheta1 + (q23 / sqrt(q13^2 + q23^2))*sintheta1;
sintheta2 = (q23 / sqrt(q13^2 + q23^2))*costheta1 - (q13 / sqrt(q13^2 + q23^2))*sintheta1;
theta2 = atan(sintheta2 / costheta2);

end
%theta2 another method
if Ty < 0 
theta2 = atan2(-sqrt(1 - ((Tx^2 + Ty^2 - 90^2 - (90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))^2)/(2*90*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))))^2),(Tx^2+Ty^2 - 90^2 - (90 +60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))^2) / (2*90*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))));

%finalmethod for theta1
theta1 = atan2(-sqrt(1 - ((Tx*(90 + (90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*cos(theta2) ) + Ty*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*sin(theta2))/(Tx^2 + Ty^2))^2),(Tx*(90+(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*cos(theta2))+Ty*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*sin(theta2))/(Tx^2 + Ty^2));

end
if Ty > 0 
    theta2 = atan2(sqrt(1 - ((Tx^2 + Ty^2 - 90^2 - (90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))^2)/(2*90*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))))^2),(Tx^2+Ty^2 - 90^2 - (90 +60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))^2) / (2*90*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))));

%finalmethod for theta1
theta1 = atan2(sqrt(1 - ((Tx*(90 + (90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*cos(theta2) ) + Ty*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*sin(theta2))/(Tx^2 + Ty^2))^2),(Tx*(90+(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*cos(theta2))+Ty*(90+60*sqrt(1 - ((Tz - 150 - 100*q33)/60)^2))*sin(theta2))/(Tx^2 + Ty^2));

%final theta5
end
%convert from rad to deg
if q11>0
theta5 = -1*atan2((sin(theta1+theta2))^2,(cos(theta1+theta2)*q33)^2) + atan2(sqrt((sin(theta1+theta2))^2 + (cos(theta1+theta2)*q33)^2 - q11^2),q11);
end
if q11<0
  theta5 = -1*atan2(sin(theta1+theta2)^2,(cos(theta1+theta2)*q33)^2) + atan2(sqrt(sin(theta1+theta2)^2 + (cos(theta1+theta2)*q33)^2 - q11^2),q11);
 
end

theta5 = theta5*180/pi;
theta4 = theta4*180/pi;
theta3 = theta3*180/pi;
theta2 = theta2*180/pi;
theta1 = theta1*180/pi;


if theta5 > 90 || theta5 < -90 || theta4 > 90 || theta4 < -90 || theta3 > 90 || theta3 < -90  ||theta2 > 90 || theta2 < -90  ||theta1 > 90 || theta1 < -90 

    display('Error there is no solution to pick up the object')
    
else
    
      
    fprintf('theta5 = %.1f \n', theta5);
    fprintf('theta4 = %.1f \n', theta4);
    fprintf('theta3 = %.1f \n', theta3);
    fprintf('theta2 = %.1f \n', theta2);
    fprintf('theta1 = %.1f \n', theta1);
   
    servo1 = -1*((theta1 -5 )*18.67);
    servo2 = -1*((theta2 -5.5 )*18.06);
    servo3 = -1*((theta3 -7.8 )*19.23);
    servo4 = ((theta4 +3.5 )*16.77);
    servo5 = -1*((theta5 -4.7 )*15.6);
    
   if servo1 > 1400
       servo1 = 1400;
   end
   if servo1 < -1400
       servo1 = -1400;
   end
   if servo2 > 1400
       servo2 = 1400;
   end
   if servo2 < -1400
       servo2 = -1400;
   end
   if servo3 > 1400
       servo3 = 1400;
   end
   if servo3 < -1400
       servo3 = -1400;
   end
   if servo4 > 1400
       servo4 = 1400;
   end
   if servo4 < -1400
       servo4 = -1400;
   end
   if servo5 > 1400
       servo5 = 1400;
   end
   if servo5 < -1400
       servo5 = -1400;
   end
   
    
    fprintf(fileID , 'move 5 to %.0f \n', servo5);
    fprintf(fileID ,'move 2 to %.0f \n', servo2);
    fprintf(fileID,'move 1 to %.0f \n', servo1+100);
    fprintf(fileID, 'move 4 to %.0f \n', servo4);
    fprintf(fileID,'move 3 to %.0f \n', servo3);
    fprintf(fileID,'move 1 to %.0f \n', servo1-125);
    
   
    
end
    
    
catch
  display('Error there is no solution please make sure it is with range of robot')  
end
    

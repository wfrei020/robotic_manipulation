%Forward kinematic model
%A=A0*A1*A2*A3*A4
%syms t1 t2 t3 t4 t5
% controlled inputs

t1 = 45*pi/180;
t2 = 0*pi/180; % degree should equal to translation
t3 = -45*pi/180;
t4 = -45*pi/180;
t5 = 76*pi/180;

% DH - Table Parameters
t4 = t4 + pi/2;
% alpha parameters
a1=0;
a2=pi/2;
a3=0;
a4=pi/2;
a5=0;
% l parameters
L1=90;
L2=90;
L3=60;
L4=0;
L5=0;
% d parameters
d1=150;
d2=0;
d3=0;
d4=0;
d5=100;
% Ai matrix
A1=[cos(t1), -sin(t1), 0, L1*cos(t1); sin(t1), cos(t1), 0, L1*sin(t1); 0, 0, 1, d1; 0, 0, 0, 1];
A2=[cos(t2), 0, sin(t2), L2*cos(t2); sin(t2), 0, -cos(t2), L2*sin(t2); 0, 1, 0, 0; 0, 0, 0, 1];
A3=[cos(t3), -sin(t3), 0, L3*cos(t3); sin(t3), cos(t3), 0, L3*sin(t3); 0, 0, 1, 0; 0, 0, 0, 1];
A4=[cos(t4), 0, sin(t4), 0; sin(t4), 0, -cos(t4),0; 0, 1, 0, 0; 0, 0, 0, 1];
A5=[cos(t5), -sin(t5), 0, 0; sin(t5), cos(t5), 0, 0; 0, 0, 1, d5; 0, 0, 0, 1];
% over all A matric  (forward kinematic model)
A=A1*A2*A3*A4*A5
% simplifying function
%simplify(A, 'steps' ,100)

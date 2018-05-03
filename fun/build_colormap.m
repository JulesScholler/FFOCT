function Colormap_final = build_colormap(handles)
%Author: Ivan Flores Esparza Institut Langevin/LLTech 23/04/2018


%Creates HS Colormap between frequencies and  HS composants
%   H_val = [borne min blue borne max red]
%   S_val = [borne min dark borne max white]
%   F_val = [min freq blue max freq red]
%   DF_val = [min df white max df dark]
%

centre_cercle = [250 270];
rayon_cercle = 260;

H_min = 0;
H_max = 0.66; 

S_min = 0;
S_max = 0.95; 

F_min = round(handles.exp.dffoct.Hmin*100)/100;
F_max = round(handles.exp.dffoct.Hmax*100)/100;

DF_min = round(handles.exp.dffoct.Smin*100)/100;
DF_max = round(handles.exp.dffoct.Smax*100)/100;

H_Freq = linspace(F_min,F_max,20);
S_Freq = linspace(DF_min,DF_max,20);
% 
H_pas = 5;
S_pas = 10;

wheel=imread('hsv-shading.png');


wheelhsv = rgb2hsv(wheel);

wheel_H = wheelhsv(:,:,1);
wheel_S = wheelhsv(:,:,2);
wheel_L = wheelhsv(:,:,3);

h = 1/360; % rapport degres H couleur et valeurs en matlab mat/degré
s = 1/rayon_cercle; % rapport valeur saturation et taille du disque

H_lim_blue = H_max; % unites matlab
H_lim_red = H_min; % unites matlab

S_lim_white = 1 - S_max;
S_lim_dark = 1 - S_min;

S_lim_white_dist = S_lim_white/s;
S_lim_dark_dist = S_lim_dark/s;

H_lim_blue_degre = H_lim_blue/h;

H_lim_red_degre = H_lim_red/h;

wheel_S(wheel_H>H_lim_blue) = 0;
wheel_S(wheel_H<H_lim_red) = 0;

wheel_S(wheel_S<S_lim_white) = 0;
wheel_S(wheel_S>S_lim_dark) = 0;


wheelhsv(:,:,2) = wheel_S;

wheelrgb = hsv2rgb(wheelhsv);
S_fmin=min(S_Freq);
S_fmax=max(S_Freq);

size_S_Freq=size(S_Freq);
size_S_Freq=size_S_Freq(2);

theta_S = H_lim_blue_degre*pi/180;
fact_x = -25;
fact_y = 25;
r_S = linspace(S_lim_white_dist+30,S_lim_dark_dist-20,floor(size_S_Freq)/S_pas+1);

x_S = r_S*cos(theta_S)+centre_cercle(1)-fact_x;
y_S = r_S*sin(theta_S)+centre_cercle(2)-fact_y;

S_text = cell(floor(size_S_Freq)/S_pas+1,1);

cont = 1;


for ii=1:S_pas:size_S_Freq
    temp = floor(S_Freq(size_S_Freq-ii+1));
    S_text{cont}=[num2str(temp) 'Hz'];    
    cont = cont+1;
end
S_text{1} = [num2str(S_fmax) 'Hz'];
S_text{floor(size_S_Freq)/S_pas+1} = [num2str(S_fmin) 'Hz'];


S_position = [x_S;y_S]';


RGB = insertText(wheelrgb,S_position,S_text,'BoxColor','white','TextColor','red');


%%Segmentation cercle H

size_H_Freq=size(H_Freq);
size_H_Freq=size_H_Freq(2);
H_text = cell(floor(size_H_Freq)/H_pas+1,1);

H_fmin=min(H_Freq);
H_fmax=max(H_Freq);

cont = 1;

for ii=1:H_pas:size_H_Freq
    temp = floor(H_Freq(ii));
    H_text{cont}=[num2str(temp) 'Hz'];    
    cont = cont+1;
end
H_text{1} = [num2str(H_fmin) 'Hz'];
H_text{floor(size_H_Freq)/H_pas+1} = [num2str(H_fmax) 'Hz'];

centre_cercle = [250 270];
rayon_cercle = 260;
theta = linspace(H_lim_blue_degre*pi/180,H_lim_red_degre*pi/180,floor(size_H_Freq)/H_pas+1);


rayon = rayon_cercle-S_lim_white_dist;
x = rayon*cos(theta)+centre_cercle(1);
y = rayon*sin(theta)+centre_cercle(2);
position_3 = [x; y];

position_3 = position_3';

RGB_2 = insertText(RGB,position_3,H_text,'BoxColor','white','TextColor','black');


Colormap_final = RGB_2;

Colormap_final = insertText(Colormap_final,[0 520], 'Characteristic frequency [Hz]','BoxColor', 'white', 'TextColor', 'black');
Colormap_final = insertText(Colormap_final,[250 100], 'Frequency bandwidth [Hz]','BoxColor', 'white', 'TextColor', 'red');

end


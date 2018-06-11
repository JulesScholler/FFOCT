function handles = autofocus(handles)

r = 5;
step = 0.5;

n = round(2*r/step+1);

move=round(handles.motors.sample.Units.positiontonative(-r*1e-6)*5);
handles.motors.sample.moverelative(move);

data = zeros(handles.octCam.Nx, handles.octCam.Nx, n);
for i = 1:n
    data(:,:,i) = oct_2phases(handles);
    move=round(handles.motors.sample.Units.positiontonative(step*1e-6)*5);
    handles.motors.sample.moverelative(move);
    pause(1)
end

for i = 1:size(data,3)
    c(i) = corr2(data(:,:,i),handles.dffoct.target);
end

[~,ind] = max(c);
d = (ind-n)*step;

move=round(handles.motors.sample.Units.positiontonative(d*1e-6)*5);
handles.motors.sample.moverelative(move);
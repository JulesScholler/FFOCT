function saveParameters(handles)
% Function to save the parameters into a text file.

fid=fopen([handles.save.path '\' handles.save.t '\parameters.txt'],'a');

% General Parameters
fprintf(fid,'GENERAL\r\n');
fprintf(fid,'\r\n');
fprintf(fid,'Acquisition done on (yyyy_mm_dd_HH_MM_ss): ');
fprintf(fid,'%s \r\n',handles.save.t);
fprintf(fid,'zStackStart: %d \r\n', handles.save.zStackStart);
fprintf(fid,'zStackEnd: %d \r\n', handles.save.zStackEnd);
fprintf(fid,'zStackStep: %d \r\n', handles.save.zStackStep);
fprintf(fid,'Repeat acquisition: %d times (every %d s.)\r\n', handles.save.repeatN,handles.save.repeatTime);
fprintf(fid,'Number of images recorded : %d\r\n', length(handles.save.zStackStart:handles.save.zStackStep:handles.save.zStackEnd));

% OCT Parameters
if handles.gui.oct
    fprintf(fid,'\r\n');
    fprintf(fid,'Adimec Parameters (OCT)\r\n');
    fprintf(fid,'\r\n');
    switch handles.exp.piezoMode
        case 1
            fprintf(fid,'Acquistion mode: Direct Image\r\n');
        case 2
            fprintf(fid,'Acquistion mode: 2 Phases Steps\r\n');
        case 3
            fprintf(fid,'Acquistion mode: 4 Phases Steps\r\n');
        case 5
            fprintf(fid,'Acquistion mode: 5 Phases\r\n');
    end
    fprintf(fid,'X0: %d\r\n', handles.octCam.X0);
    fprintf(fid,'Y0: %d\r\n', handles.octCam.Y0);
    fprintf(fid,'Nx: %d\r\n', handles.octCam.Nx);
    fprintf(fid,'Ny: %d\r\n', handles.octCam.Ny);
    fprintf(fid,'ExpTime[ms]: %f\r\n', handles.octCam.ExpTime);
    fprintf(fid,'FCamOCT[fps]: %f\r\n', handles.octCam.FcamOCT);
    fprintf(fid,'Naccu: %d\r\n', handles.octCam.Naccu);
    fprintf(fid,'AmplPiezo[V]: %f\r\n', handles.exp.AmplPiezo);
    fprintf(fid,'PhiPiezo [rad]: %f\r\n', handles.exp.PhiPiezo);
end

% Fluo Parameters
if handles.gui.fluo
    fprintf(fid,'\r\n');
    fprintf(fid,'PCO Parameters (Fluo)\r\n');
    fprintf(fid,'\r\n');
    fprintf(fid,'X0: %d\r\n', handles.fluoCam.X0);
    fprintf(fid,'Y0: %d\r\n', handles.fluoCam.Y0);
    fprintf(fid,'Nx: %d\r\n', handles.fluoCam.Nx);
    fprintf(fid,'Ny: %d\r\n', handles.fluoCam.Ny);
    fprintf(fid,'ExpTime[ms]: %f\r\n', handles.fluoCam.ExpTime);
    fprintf(fid,'FCamOCT[fps]: %f\r\n', handles.fluoCam.Fcam);
    fprintf(fid,'Naccu: %d\r\n', handles.fluoCam.Naccu);
    
end

if handles.gui.oct
    % Timestamps
    fprintf(fid,'\r\n');
    fprintf(fid,'Timestamps OCT\r\n');
    fprintf(fid,'\r\n');
    for i=1:length(handles.save.timeOCT)
        fprintf(fid,'Frame %d: %f\r\n', i,handles.save.timeOCT(i)-handles.save.timeOCT(1));
    end
end

if handles.gui.fluo
    % Timestamps
    fprintf(fid,'\r\n');
    fprintf(fid,'Timestamps Fluo\r\n');
    fprintf(fid,'\r\n');
    for i=1:length(handles.save.timeFluo)
        fprintf(fid,'Frame %d: %f\r\n', i,handles.save.timeFluo(i)-handles.save.timeFluo(1));
    end
end
fclose(fid);
function quitgui(handles)
% On efface les données créées, notamment ceux qui font appel aux divers
% appareils connectés (caméra, Piezo, etc...)

if isfield(handles,'octCam')
    if(isrunning(handles.octCam.vid))
        stop(handles.octCam.vid);
        stop(handles.DAQ.s);
        queueOutputData(handles.DAQ.s,SignalTest); % Est ce que je mettrais pas un signal continu plutôt?
        startBackground(handles.DAQ.s);
        stop(handles.DAQ.s)
    end
    delete(handles.octCam.vid);
end

if isfield(handles,'motors')
    if(strcmp(handles.motors.port.Status,'open'))
        fclose(handles.motors.port);
    end
end

if isfield(handles,'DAQ')
    stop(handles.DAQ.s);
    delete(handles.DAQ.lh);
end

if isfield(handles,'fluoCam')
    if(isrunning(handles.fluoCam.vid))
        stop(handles.fluoCam.vid);
        stop(handles.DAQ.s);
        queueOutputData(handles.DAQ.s,SignalTest); % Est ce que je mettrais pas un signal continu plutôt?
        startBackground(handles.DAQ.s);
        stop(handles.DAQ.s)
    end
    delete(handles.fluoCam.vid);
end

% if isfield(handles,'fluoCam')
% stop_camera(handles.fluoCam.glvar.out_ptr);
%     if(libisloaded('GRABFUNC'))
%         unloadlibrary('GRABFUNC');
%     end
%     if(handles.fluoCam.glvar.camera_open==1)
%         handles.fluoCam.glvar.do_close=1;
%         handles.fluoCam.glvar.do_libunload=1;
%         pco_camera_open_close(handles.fluoCam.glvar);
%     end
% end

fprintf('The program has exited properly.\n');

close all
clear all
function [dffoct,handles] = dffoct_gpu(im,handles)
% Function for DFFOCT computation given a stack of direct raw images.

% Hard coded parameters
n_std = handles.exp.dffoct.n_std;     % Number of sample in the moving STD.
freq_min = 4;   % Minimum frequency to consider in Fourier domain.

% We normalize each frame to remove sensor frame to frame instabilities.
im = double(squeeze(im));
s = size(im);
directMean = squeeze(mean(mean(im,1),2));
for i = 1:s(3)
    im(:,:,i)=im(:,:,i)/directMean(i);
end

% We divide the image in 9 sub-images in order to reduce the memory
% footprint on the GPU (change it depending on your hardware).
for x = 1:3
    for y = 1:3
        % V component with average of moving STD
        imGPU = gpuArray(double(im(s(1)/3*(x-1)+1:s(1)/3*x,s(2)/3*(y-1)+1:s(2)/3*y,:)));
        V = zeros(s(1)/3,s(2)/3,s(3)/16,'gpuArray');
        for i = 1:floor((s(3)-n_std)/16)
            V(:,:,i) = std(imGPU(:,:,(i-1)*16+1:(i-1)*16+n_std),[],3);
        end
        V = mean(V,3);
        
        % Average 4 samples
        imMean = zeros(s(1)/3,s(2)/3,s(3)/4,'gpuArray');
        for i = 1:s(3)/4
            imMean(:,:,i) = mean(imGPU(:,:,(i-1)*4+1:i*4),3);
        end
        clear imGPU
        
        % Compute Fourier transform and normalize as if it were a
        % probability distribution
        data_freq = abs(fft(imMean,[],3));
        clear imMean
        data_freq = data_freq(:,:,freq_min:s(3)/8+1);
        normL1 = reshape(repmat(sum(data_freq,3),1,s(3)/8-freq_min+2),s(1)/3,s(2)/3,s(3)/8-freq_min+2);
        data_freq = data_freq./normL1;
        clear normL1
        
        f = reshape(repelem(gpuArray.linspace(0,handles.octCam.FcamOCT/4,s(3)/8-2),s(1)*s(2)/9),s(1)/3,s(2)/3,s(3)/8-freq_min+2);
        % S component is computed as the probability distribution STD
        S = sqrt(dot(data_freq,f.^2,3)-dot(data_freq,f,3).^2);
        data_freq = data_freq - reshape(repmat(min(data_freq,[],3),1,s(3)/8-2),s(1)/3,s(2)/3,s(3)/8-freq_min+2);
        % H component is computed as the probability distribution mean.
        H = dot(data_freq,f,3);
        clear data_freq f
        
        Ht(s(1)/3*(x-1)+1:s(1)/3*x,s(2)/3*(y-1)+1:s(2)/3*y) = gather(H);
        St(s(1)/3*(x-1)+1:s(1)/3*x,s(2)/3*(y-1)+1:s(2)/3*y) = gather(S);
        Vt(s(1)/3*(x-1)+1:s(1)/3*x,s(2)/3*(y-1)+1:s(2)/3*y) = gather(V);
        
    end
end

% We saturate 0.01% of V pixels and rescale it between 0 and 1
Vf = Vt;
if ~isfield(handles.exp, 'dffoct')
    handles.exp.dffoct.Vmax = prctile(Vt(:),99.9);
end
Vf(Vt> handles.exp.dffoct.Vmax) =  handles.exp.dffoct.Vmax;
Vf = rescale(Vf,0,1);

% We saturate 5% of S pixels and rescale it between 0 and 0.95 (if there
% are previously computed images, then the previous saturation is applyied
% in order to obtain a consistant colormap).
Sf = St;
Sf = rescale(Sf, 0, 0.95);
if ~isfield(handles.exp.dffoct, 'Smin')
    handles.exp.dffoct.Smin = prctile(Sf(:),5);
    set(handles.editSmin, 'String', num2str(handles.exp.dffoct.Smin))
    handles.exp.dffoct.Smax = prctile(Sf(:),100);
    set(handles.editSmax, 'String', num2str(handles.exp.dffoct.Smax))
end
Sf(Sf>handles.exp.dffoct.Smax) = handles.exp.dffoct.Smax;
Sf(Sf<handles.exp.dffoct.Smin) = handles.exp.dffoct.Smin;
Sf = rescale(-Sf, 0, 0.95);

% We saturate 0.1% of H pixels and rescale it between 0 (red) and 0.66 (blue) (if there
% are previously computed images, then the previous saturation is applyied
% in order to obtain a consistant colormap).
Hf = imgaussfilt(rescale(Ht,0,1),4);
Hf = rescale(Hf,0,0.66);
if ~isfield(handles.exp.dffoct, 'Hmin')
    handles.exp.dffoct.Hmin = prctile(Hf(Vf>0.5),0.1);
    set(handles.editHmin, 'String', num2str(handles.exp.dffoct.Hmin))
    handles.exp.dffoct.Hmax = prctile(Hf(Vf>0.5),99.9);
    set(handles.editHmax, 'String', num2str(handles.exp.dffoct.Hmax))
end
Hf(Hf<handles.exp.dffoct.Hmin) = handles.exp.dffoct.Hmin;
Hf(Hf>handles.exp.dffoct.Hmax) = handles.exp.dffoct.Hmax;
Hf = rescale(-Hf,0,0.66);

% We construct the DFFOCT image.
dffoct_hsv(:,:,1) = Hf;
dffoct_hsv(:,:,2) = Sf;
dffoct_hsv(:,:,3) = Vf;

dffoct = hsv2rgb(dffoct_hsv);

end

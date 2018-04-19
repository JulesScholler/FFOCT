function [dffoct, f, df] = dffoct_gpu(im, fs)

im = double(squeeze(im));
directMean = squeeze(mean(mean(im,1),2));
for i = 1:512
    im(:,:,i)=im(:,:,i)/directMean(i);
end

for x = 1:3
    for y = 1:3
        imGPU = gpuArray(double(im(480*(x-1)+1:480*x,480*(y-1)+1:480*y,:)));
        V = gpuArray(zeros(480,480,512/16));
        for i = 1:floor((512-50)/16)
            V(:,:,i) = std(imGPU(:,:,(i-1)*16+1:(i-1)*16+50),[],3);
        end
        V = mean(V,3);
        
        imMean = gpuArray(zeros(480,480,512/4));
        for i = 1:512/4
            imMean(:,:,i) = mean(imGPU(:,:,(i-1)*4+1:i*4),3);
        end
        clear imGPU
        
        data_freq = abs(fft(imMean,[],3));
        clear imMean
        data_freq = data_freq(:,:,2:65);
        normL1 = reshape(repmat(sum(data_freq,3),1,64),480,480,64);
        data_freq = data_freq./normL1;
        clear normL1
        
        f = gpuArray(reshape(repelem(linspace(0,fs,64),480*480),480,480,64));
        S = sqrt(dot(data_freq,f.^2,3)-dot(data_freq,f,3).^2);
        data_freq = data_freq - reshape(repmat(min(data_freq,[],3),1,64),480,480,64);
        H = dot(data_freq,f,3);
        clear data_freq f
        
        Ht(480*(x-1)+1:480*x,480*(y-1)+1:480*y) = gather(H);
        St(480*(x-1)+1:480*x,480*(y-1)+1:480*y) = gather(S);
        Vt(480*(x-1)+1:480*x,480*(y-1)+1:480*y) = gather(V);
        
    end
end

Vf = Vt;
Vf(Vt>prctile(Vt(:),99.9)) = prctile(Vt(:),99.9);
Vf = rescale(Vf,0,1);

Sf = rescale(1-imgaussfilt(St,2),0,1);
Smin = prctile(Sf(:),0);
Smax = prctile(Sf(:),95);
Sf(Sf>Smax) = Smax;
Sf(Sf<Smin) = Smin;
df(1) = (1 - Smax)*fs/2;
df(2) = (1 - Smin)*fs/2;
Sf = rescale(Sf, 0, 0.95);

Hf = rescale(1 - imgaussfilt(Ht,1),0,1);
Hmin = prctile(Hf(Vf>0.5),0.1);
Hmax = prctile(Hf(Vf>0.5),99.9);
Hf(Hf<Hmin) = Hmin;
Hf(Hf>Hmax) = Hmax;
f(1) = (1 - Hmax)*fs/2;
f(2) = (1 - Hmin)*fs/2;
Hf = rescale(Hf,0,0.66);

dffoct_hsv(:,:,1) = Hf;
dffoct_hsv(:,:,2) = Sf;
dffoct_hsv(:,:,3) = Vf;

dffoct = hsv2rgb(dffoct_hsv);

end

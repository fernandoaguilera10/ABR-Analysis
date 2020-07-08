%% Read in the ABR waveforms
function load_abr_data

global abr_Stimuli abr_data_dir	num dt line_width abr freq attn spl date data freq_level ...
    abr_time ABRmag invert noise_local dataFolderpath viewraw dimcheck

if isempty(viewraw) %if viewraw does not exist, look at a files
    viewraw = 0;
end

pic = ParseInputPicString_V2(abr_Stimuli.abr_pic);
num=length(pic);

clear global 'reff'
clear global 'frequency'

data.threshold=NaN;
data.z.intercept=NaN;
data.z.slope=NaN;
data.z.score=NaN*ones(1,num);
data.amp_thresh=NaN;
data.amp=NaN*ones(1,num);
data.x=NaN*ones(10,num);
data.y=NaN*ones(10,num);
data.y_forfig=NaN*ones(10,num);
data.amp_null=NaN*ones(1,num);

date=abr_Stimuli.dir(4:13);
ABRmag=NaN*ones(num,4);
line_width=1;

%ExpDir=fullfile(abr_data_dir,abr_Stimuli.dir);
ExpDir = dataFolderpath;
cd(ExpDir);

%% Read in the ABR waveforms
%GO HERE
abr=[];
freqs=NaN*ones(1,num);
attn=NaN*ones(1,num);
%HG ADDED 2/26/20
if viewraw == 0 %AC corrected data
    hhh=dir(sprintf('a%04d*',pic(1)));
else %RAW data
    hhh=dir(sprintf('araw%04d*',pic(1)));
end
%Make sure you are looking at a file, NOT ARAW file
if (contains(hhh.name,'araw') && (viewraw == 0))
    errordlg('The code is analyzing an ARAW file. This is an error. Go to load_abr_data, line 37 to fix.','ERROR');
end
if exist(hhh.name,'file') && ~isempty(hhh)
    for i=1:num
        if viewraw == 0 %AC corrected data
            fname=dir(sprintf('a%04d*',pic(i)));
        else %RAW data
            fname=dir(sprintf('araw%04d*',pic(i)));
        end
        filename=fname.name(1:end-2);
        eval(['x=' filename ';'])
        if ~(x.Stimuli.clickYes)
            freqs(1,i)=x.Stimuli.freq_hz;
        else
            freqs(1,i)=0; % means click
        end
        attn(1,i)=-x.Stimuli.atten_dB;
        abr(:,i)=x.AD_Data.AD_Avg_V'-mean(x.AD_Data.AD_Avg_V); % removes DC offset
        if abr(end,i)>max(abr(1:end-1,i)) % Weird DC except at last point. Remove DC, remove last point, again remove new DC.
            abr(end,i)=0;
            abr(:,i)=abr(:,i)-mean(abr(:,i));
        end
    end
else
    for i=1:num %Does it ever go into here? This may be unnecessary?
        fname=dir(sprintf('p%04d*',pic(i)));
        filename=fname.name(1:end-2);
        eval(['x=' filename ';'])
        
        if ~(x.Stimuli.clickYes)
            freqs(1,i)=x.Stimuli.freq_hz;
        else
            freqs(1,i)=0; % means click
        end
        
        attn(1,i)=-x.Stimuli.atten_dB;
        if iscell(x.AD_Data.AD_Avg_V)
            abr(:,i)=(x.AD_Data.AD_Avg_V{1}-mean(x.AD_Data.AD_Avg_V{1}))'; %#ok<*AGROW> % removes DC offset
        else
            abr(:,i)=x.AD_Data.AD_Avg_V'-mean(x.AD_Data.AD_Avg_V); % removes DC offset
        end
        if abr(end,i)>max(abr(1:end-1,i))
            abr(end,i)=0;
        end
    end
end

noise_local=concat_noise(pwd);
noise_local=noise_local';

dt=500/x.Stimuli.RPsamprate_Hz; %sampling period after oversampling (the function "bin_of_time" uses ms as input time)

%% Invert -- check this???
if exist('invert','var')
    if invert==1
        abr=-1*abr; %if traces are inverted uncomment this.
    end
end

%% sort abrs in order of increasing attenuation
[~, order]=sort(-attn);
abr2=abr(:,order);
attn=attn(:,order);
freqs=freqs(:,order);

abr3=-abr2/20000*1000000; % in uV, invert to make waveforms look "normal"
abr=resample(abr3,2,1); %double sampling frequency of ABRs
freq_mean=mean(freqs);
freq=round(freqs(1,1)/500)*500; %round to nearest 500 Hz
abr_time=(0:dt:time_of_bin(length(abr)));

%% Determine SPL of stimuli
CalibFile  = sprintf('p%04d_calib', str2double(abr_Stimuli.cal_pic));
command_line = sprintf('%s%s%c','[xcal]=',CalibFile,';');
eval(command_line);
freq_loc = find(xcal.CalibData(:,1)>=(freq_mean/1000));
freq_level = xcal.CalibData(freq_loc(1),2);
spl=freq_level+attn;

if freqs ~= freq_mean
    error('Multiple stimulus frequencies selected!')
end
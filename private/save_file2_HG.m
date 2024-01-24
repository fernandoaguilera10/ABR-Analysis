function save_file2_HG

global num freq spl animal date freq_level data abr ABRmag w hearingStatus abr_out_dir abr_Stimuli ...
    AR_marker abr_time abr_FIG
today = datetime('now');
today_date = datestr(today);
today_date = today_date(1:11);
q_fldr = strcat('Q', num2str(animal));
ChinDir = [abr_out_dir,'/', q_fldr];

if ~isdir(ChinDir)
    mkdir(ChinDir);
end
cd(ChinDir)
x = dir;
for i = 1:length(x)
    if (~contains(x(i).name,'.'))&&(~contains(x(i).name,'.DS_Store','IgnoreCase',true))
        fldr = x(i).name;
    else
        fldr = '';
    end
end
currChinDir = strcat(ChinDir, fldr);
cd(currChinDir)
file_check = dir(sprintf('*Q%s_%s_%dHz_%s*.mat',num2str(animal),hearingStatus,freq,date));
filename = {file_check.name};
%HG ADDED 9/30/19
%Make sure saving is done in correct folder
if freq~=0 %HG EDITED 9/30/19
    filename2= strrep(horzcat('Q',num2str(animal),'_',hearingStatus,'_', num2str(freq), 'Hz','_',date), '-', '_');
else
    filename2= strrep(horzcat('Q',num2str(animal),'_',hearingStatus,'_', 'click','_',date), '-', '_');
end
freq2=ones(1,num)*freq; replaced=0;
if ~isempty(filename) && ~isempty(abr_FIG.parm_txt(9).String) % Replace file contents if file exists and is active
    check = find(ismember(filename,abr_FIG.parm_txt(9).String) == 1);
    if ~isempty(check)
        overwrite_msg = questdlg(sprintf('Would you like to replace current peak file?\n\n%s\n',abr_FIG.parm_txt(9).String),...
            'Save Peak File', 'Yes', 'No','I dont know');
        answer = {overwrite_msg};
        if contains(answer, 'Yes') %Replaces file if file already exists
            prompt_peak_save = sprintf('\nReplacing File...\n\nSubject: Q%s \nStimulus: %.1f kHz\n',animal, freq/1000);
            load(abr_FIG.parm_txt(9).String)
            if exist('abrs','var')
                waitbar(0,prompt_peak_save);
                pause(.5)
                close;
                if ismember(freq,abrs.thresholds(:,1))
                    abrs.thresholds(abrs.thresholds(:,1)==freq,:)=[];
                    abrs.z.par(abrs.z.par(:,1)==freq,:)=[];
                    abrs.z.score(abrs.z.score(:,1)==freq,:)=[];
                    abrs.amp(abrs.amp(:,1)==freq,:)=[];
                    abrs.x(abrs.x(:,1)==freq,:)=[];
                    abrs.y(abrs.y(:,1)==freq,:)=[];
                    abrs.waves(abrs.waves(:,1)==freq,:)=[];
                    replaced=1;
                end
                
                if size(abrs.x,2)<12
                    abrs.x=[abrs.x nan(size(abrs.x,1),12-size(abrs.x,2))];
                    abrs.y=[abrs.y nan(size(abrs.y,1),12-size(abrs.y,2))];
                end
                waitbar(0.5,prompt_peak_save);
                pause(1);
                close;
                abrs.thresholds = [abrs.thresholds; freq data.threshold data.amp_thresh -freq_level];
                abrs.z.par = [abrs.z.par; freq data.z.intercept data.z.slope];
                abrs.z.score = [abrs.z.score; freq2' spl' data.z.score' w'];
                abrs.amp = [abrs.amp; freq2' ABRmag];
                abrs.x = [abrs.x; freq2' spl' data.x'];
                abrs.y = [abrs.y; freq2' spl' data.y'];
                abrs.waves = [abrs.waves; freq2' spl' abr'];
                % Plotting structure
                abrs.plot.waveforms = abrs.waves(:,3:end);
                abrs.plot.waveforms_time = abr_time;
                abrs.plot.peak_latency = abrs.x(:,3:end);
                abrs.plot.peak_amplitude = abrs.y(:,3:end);
                abrs.plot.levels = abrs.x(:,2);
                abrs.plot.peaks = ["p1" "n1" "p2" "n2" "p3" "n3" "p4" "n4" "p5" "n5"];
                abrs.plot.freq = abrs.x(1,1);
                %HG ADDED 2/11/20
                abrs.AR_marker = AR_marker;
                idx = strfind(abr_FIG.parm_txt(9).String,'.mat');
                filename_out = [abr_FIG.parm_txt(9).String(1:idx-12-1) '_' today_date];
                save(filename_out, 'abrs','-append'); clear abrs;
            else
                abrs.thresholds = [freq data.threshold data.amp_thresh -freq_level];
                abrs.z.par = [freq data.z.intercept data.z.slope];
                abrs.z.score = [freq2' spl' data.z.score' w'];
                abrs.amp = [freq2' ABRmag];
                abrs.x = [freq2' spl' data.x'];
                abrs.y = [freq2' spl' data.y'];
                abrs.waves = [freq2' spl' abr'];
                % Plotting structure
                abrs.plot.waveforms = abrs.waves(:,3:end);
                abrs.plot.waveforms_time = abr_time;
                abrs.plot.peak_latency = abrs.x(:,3:end);
                abrs.plot.peak_amplitude = abrs.y(:,3:end);
                abrs.plot.levels = abrs.x(:,2);
                abrs.plot.peaks = ["p1" "n1" "p2" "n2" "p3" "n3" "p4" "n4" "p5" "n5"];
                abrs.plot.freq = abrs.x(1,1);
                abrs.AR_marker = AR_marker;
                idx = strfind(abr_FIG.parm_txt(9).String,'.mat');
                filename_out = [abr_FIG.parm_txt(9).String(1:idx-12-1) '_' today_date];
                save(filename_out, 'abrs','-append'); clear abrs;
                save(filename2, 'abrs','-append'); clear abrs;
            end
        elseif  contains(answer, 'No') || isempty(filename) || isempty(abr_FIG.parm_txt(9).String)%Creates new version file
            prompt_peak_save = sprintf('\nSaving New File...\n\nSubject: Q%s \nStimulus: %.1f kHz\n',animal, freq/1000);
            waitbar(0,prompt_peak_save);
            pause(.5);
            close;
            abrs.thresholds = [freq data.threshold data.amp_thresh -freq_level];
            abrs.z.par = [freq data.z.intercept data.z.slope];
            abrs.z.score = [freq2' spl' data.z.score' w'];
            abrs.amp = [freq2' ABRmag];
            abrs.x = [freq2' spl' data.x'];
            abrs.y = [freq2' spl' data.y'];
            abrs.waves = [freq2' spl' abr'];
            % Plotting structure
            abrs.plot.waveforms = abrs.waves(:,3:end);
            abrs.plot.waveforms_time = abr_time;
            abrs.plot.peak_latency = abrs.x(:,3:end);
            abrs.plot.peak_amplitude = abrs.y(:,3:end);
            abrs.plot.levels = abrs.x(:,2);
            abrs.plot.peaks = ["p1" "n1" "p2" "n2" "p3" "n3" "p4" "n4" "p5" "n5"];
            abrs.plot.freq = abrs.x(1,1);
            file_check = dir(sprintf('*%s_v*.mat',filename2));
            [~,c] = size({file_check.name});
            if ~isempty(file_check)
                file_num = c + 1;
                filename3 = sprintf('%s_v%d',filename2,file_num);
                while exist(sprintf('*%s_v*.mat',filename2),'file')
                    filename3 = strcat(filename2, '_v', file_num);
                    file_num = file_num + 1;
                end
                filename_out = [filename3 '_' today_date];
                save(filename_out,'abrs');
                filename_out = [filename3 '_' today_date];
            elseif ~exist(strcat(filename2, '.mat'),'file')
                filename_out = [filename2 '_v1_' today_date];
                save(filename_out, 'abrs');
            end
            %HG ADDED 2/11/20
            abrs.AR_marker = AR_marker;
            waitbar(0.5,prompt_peak_save);
            pause(.5);
            close;
        end
    end
elseif ~isempty(filename) && isempty(abr_FIG.parm_txt(9).String) %Save new file if prior files exist
    prompt_peak_save = sprintf('\nSaving New File...\n\nSubject: Q%s \nStimulus: %.1f kHz\n',animal, freq/1000);
    waitbar(0,prompt_peak_save);
    pause(.5);
    close;
    abrs.thresholds = [freq data.threshold data.amp_thresh -freq_level];
    abrs.z.par = [freq data.z.intercept data.z.slope];
    abrs.z.score = [freq2' spl' data.z.score' w'];
    abrs.amp = [freq2' ABRmag];
    abrs.x = [freq2' spl' data.x'];
    abrs.y = [freq2' spl' data.y'];
    abrs.waves = [freq2' spl' abr'];
    % Plotting structure
    abrs.plot.waveforms = abrs.waves(:,3:end);
    abrs.plot.waveforms_time = abr_time;
    abrs.plot.peak_latency = abrs.x(:,3:end);
    abrs.plot.peak_amplitude = abrs.y(:,3:end);
    abrs.plot.levels = abrs.x(:,2);
    abrs.plot.peaks = ["p1" "n1" "p2" "n2" "p3" "n3" "p4" "n4" "p5" "n5"];
    abrs.plot.freq = abrs.x(1,1);
    file_check = dir(sprintf('*%s_v*.mat',filename2));
    [~,c] = size({file_check.name});
    if ~isempty(file_check)
        file_num = c + 1;
        filename3 = sprintf('%s_v%d',filename2,file_num);
        while exist(sprintf('*%s_v*.mat',filename2),'file')
            filename3 = strcat(filename2, '_v', file_num);
            file_num = file_num + 1;
        end
        filename_out = [filename3 '_' today_date];
        save(filename_out,'abrs');
        filename_out = [filename3 '_' today_date];
    elseif ~exist(strcat(filename2, '.mat'),'file')
        filename_out = [filename2 '_v1_' today_date];
        save(filename_out, 'abrs');
    end
    %HG ADDED 2/11/20
    abrs.AR_marker = AR_marker;
    waitbar(0.5,prompt_peak_save);
    pause(.5);
    close;
else    %Save first file if no prior files exist
    prompt_peak_save = sprintf('\nSaving New File...\n\nSubject: Q%s \nStimulus: %.1f kHz\n',animal, freq/1000);
    waitbar(0,prompt_peak_save);
    pause(.5);
    close;
    abrs.thresholds = [freq data.threshold data.amp_thresh -freq_level];
    abrs.z.par = [freq data.z.intercept data.z.slope];
    abrs.z.score = [freq2' spl' data.z.score' w'];
    abrs.amp = [freq2' ABRmag];
    abrs.x = [freq2' spl' data.x'];
    abrs.y = [freq2' spl' data.y'];
    abrs.waves = [freq2' spl' abr'];
    % Plotting structure
    abrs.plot.waveforms = abrs.waves(:,3:end);
    abrs.plot.waveforms_time = abr_time;
    abrs.plot.peak_latency = abrs.x(:,3:end);
    abrs.plot.peak_amplitude = abrs.y(:,3:end);
    abrs.plot.levels = abrs.x(:,2);
    abrs.plot.peaks = ["p1" "n1" "p2" "n2" "p3" "n3" "p4" "n4" "p5" "n5"];
    abrs.plot.freq = abrs.x(1,1);
    filename_out = [filename2 '_v1_' today_date];
    waitbar(0.5,prompt_peak_save);
    pause(.5);
    close;
    save(filename_out, 'abrs');
end
saved_prompt = sprintf('\nFiles Saved!\n\nFilename: %s\n\nFolder: %s\n',filename_out,currChinDir);
saved_box = msgbox(saved_prompt); set(get(get(saved_box, 'CurrentAxes'), 'title'), 'Interpreter', 'none'); movegui(saved_box,'center');
clear abrs;
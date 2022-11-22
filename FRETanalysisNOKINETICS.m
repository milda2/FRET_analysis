%% promt
clc; close all;
 
opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Ok';
% Use the TeX interpreter to format the question
%quest1 = ({'This is a semi-automated FRET analysis script.';...
%     'Please check that you have your script and data files';...
%     'in the same folder. If you want to modify figures,';...
%     'you can do that manually by changing the code.'} );
%answer7 = questdlg(quest1,'Information',...
%                   'Ok',opts);            

prompt = {'\fontsize{16}What is your file name? Case sensitive! '};
Title = 'Input'; 
defaultans = {''}; 
opts.Interpreter = 'tex'; 
answer = inputdlg(prompt,Title,[1, 120],defaultans, opts);

str=answer{1,1};  % This is our cell array.
str1 = char(str);

fn = {'Gain of FRET', 'Loss of FRET'};
[indx,tf] = listdlg('PromptString',{'Select your sensor:'},...
    'SelectionMode','single','ListSize',[150, 50],'ListString',fn);
%% load data
[RawNumbers,~,~] = xlsread(str1);

%% clean data - find and remove NaN (= remove zero clock, etc)
[row, ~] = find(isnan(RawNumbers));
if isempty(row)
    row=0;
end
row = max(row);
CleanedData = RawNumbers((row+1):end, :); 

%% analyse data
[CFP, YFP] = subtract_background (CleanedData);
r1 = ratio (CFP, YFP, indx);
f1 = FRET_change (r1);
c1 = cyan_normal (CFP);
y1 = yellow_normal (YFP);
[~, y2]  = size (CFP);

%% write analysed data into .csv
[x, ~]  = size (CFP);
Empty = zeros(x,1);
BCK = [ CFP, Empty, YFP, Empty, r1, Empty, f1, Empty, c1, Empty, y1];
Labels =['CFP', '', 'YFP', '', 'RATIO', '', 'FRET CHANGE', '', 'CFP NORM', '', 'YFP NORM'];
% writecell({BCK, Labels}, "Analysed_"+str1+".csv")
%str1
% xlswrite("Analysed_"+str1+".csv", [Labels, BCK])
writematrix(BCK,"Analysed_"+str1+".csv") %% 

%% plot data all

figure (90)
subplot (2,2,1)
plot (CleanedData(:, 1), mean(CFP,2), 'b','LineWidth', 2)
hold on;
plot (CleanedData(:, 1), mean(YFP,2), 'y','LineWidth', 2)
hold off;
xlabel('Time (ms)');
ylabel('CFP and YFP');

subplot (2, 2, 2)
plot (CleanedData(:, 1), r1,'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Ratio');

subplot (2, 2, 3)
plot (CleanedData(:, 1), f1, 'LineWidth', 2)
xlabel('Time (ms)');
ylabel('FRET change, %');
legend ('ROI2', 'ROI3', 'ROI4', 'ROI5', 'Location', 'northwest');

subplot (2, 2, 4)
plot (CleanedData(:, 1), mean(c1,2), 'b', 'LineWidth', 2)
hold on;
plot (CleanedData(:, 1), mean(y1,2), 'y', 'LineWidth', 2)
hold off;
xlabel('Time (ms)');
ylabel('Norm. cyan/yellow');

%% SAVE FIGURE
saveas(figure(90), "Figure_"+str1+".tiff");

%% Calculate the FRET change at specified times
%First, calculate the baseline/starting FRET values and Max

baseline=[];
RealMax=[];
[~,x7] = size(f1);

for i=1:x7
    trace1=f1(:,i);
    [maxFRET, timemax] = max(trace1);
    baseline(1,i) = mean( trace1( 10:20 ));
    bb = timemax-2; %take 3 numbers
    %%manual mean
    RealMax(1,i) = (sum( trace1(bb:timemax, 1), 'all'))/3 - baseline(1,i); %5 is the number of variables in the array
    %avMax(1, i) = mean( f1( bb:bbd) )
    %RealMax(1,i) = avMax(1,i)-baseline(1,i)
    i=i+1;
end

%Calcualte basal ratios
basal_ratios = mean (r1(12:22,:));

%Calculate Stim 1
prompt = {'\fontsize{16}Enter time (ms) for Stim1 FRET change extraction - not the time of treatment'};
Title = 'Input'; 
defaultans = {''}; 
opts.Interpreter = 'tex'; 
answer8 = inputdlg(prompt,Title,[1, 120],defaultans, opts);
Stim1_time = str2num(answer8{1});
Stim1_time = round(Stim1_time/5); %cycle number cause time is every 5 ms
RealStim1=[];
[~,rr] = size(f1);
    for p=1:rr
        trace2=f1(:,p);
        baseline2(1,p) = mean( trace2( 12:22 ));
        bbp = Stim1_time-2;
        bbdp=Stim1_time+2;
        selection = trace2( bbp:bbdp);
        avStim2(1,p) = mean( selection );
    
        RealStim1(1,p) = avStim2(1,p)-baseline2(1,p);
        p=p+1;
    end
% Include the desired Default answer
opts.Default = 'Ok';

%Calculate Stim2
prompt = {'\fontsize{16}Enter time (ms) for Stim2 FRET change extraction - not the time of treatment'};
Title = 'Input'; 
defaultans = {''}; 
opts.Interpreter = 'tex'; 
answer11 = inputdlg(prompt,Title,[1, 120],defaultans, opts);
Stim2_time = str2num(answer11{1});
Stim2_time = round(Stim2_time/5); %cycle number cause time is every 5 ms
RealStim2=[];
[~,rd] = size(f1);
    for pp=1:rd
        trace3=f1(:,pp);
        baseline3(1,pp) = mean( trace3( 12:22 ));
        bbpp = Stim2_time-2;
        bbdpp=Stim2_time+2;
        selection22 = trace3( bbpp:bbdpp);
        avStim3(1,pp) = mean( selection22 );
    
        RealStim2(1,pp) = avStim3(1,pp)-baseline3(1,pp);
        pp=pp+1;
    end
opts.Default = 'Ok';

%Calcaulte Stim3

prompt = {'\fontsize{16}Enter time (ms) for Stim3 FRET change extraction - not the time of treatment'};
Title = 'Input'; 
defaultans = {''}; 
opts.Interpreter = 'tex'; 
answer19 = inputdlg(prompt,Title,[1, 120],defaultans, opts);
Stim3_time = str2num(answer19{1});
Stim3_time = round(Stim3_time/5); %cycle number cause time is every 5 ms
RealStim3=[];
[~,rdd] = size(f1);
    for ppd=1:rdd
        trace4=f1(:,ppd);
        baseline4(1,ppd) = mean( trace4( 12:22 ));
        bbpp1 = Stim3_time-2;
        bbdpp1=Stim3_time+2;
        selection222 = trace4( bbpp1:bbdpp1);
        avStim4(1,ppd) = mean( selection222 );
    
        RealStim3(1,ppd) = avStim4(1,ppd)-baseline4(1,ppd);
        ppd=ppd+1;
    end
opts.Default = 'Ok';

%Calcualte kinetics

%% write analysed data into .csv
[x, ~]  = size (CFP);
Empty = zeros(x,1);
BCK = [ CFP, Empty, YFP, Empty, r1, Empty, f1, Empty, c1, Empty, y1];
%Labels =['CFP', '', 'YFP', '', 'RATIO', '', 'FRET CHANGE', '', 'CFP NORM', '', 'YFP NORM'];
%writetable(BCK, Labels, "Analysed_"+str1+".csv")
%str1
writematrix(BCK,"Analysed_"+str1+".csv") %% 

%% write calcualtions data into .csv

basal_ratios=basal_ratios.';
max_fret = RealMax.';
Stim1 = RealStim1.';
Stim2 = RealStim2.';
Stim3 = RealStim3.';
[x5, ~]  = size (basal_ratios);
Empty2 = zeros(x5,1);
BCK5 = [basal_ratios, Empty2, max_fret, Empty2, ...
    Stim1, Empty2, Stim2, Empty2, Stim3];
% Labels5 ={'basal ratios', '', 'Max FRET change', '', 'Stim1', '', ...
%     'Stim2', '', 'Stim3'};
%str1
writematrix(BCK5,"Calculated_"+str1+".csv") %% 

%%close figure
%close(figure(90));


%% functions

function [CFP, YFP] = subtract_background (RAWdata)
R = RAWdata;
[~, y]  = size (R);
y = y-1-6; % y=total length, -1 for time, -3 for the background, -3 for the final three
a=0;
    for i = 0:3:y % increase in increments =3, start from 0 giving 0, 3, 6 etc.
        W1bck(:,1+a) = R(:, 5+i)-R (:, 2); %R starts from 5 cause 1st is time, 2-4 is bcground
        W2bck(:,1+a) = R(:, 6+i) - R(:, 3);
        a=a+1;
    end
CFP = W1bck;
YFP = W2bck;
end

function r1 = ratio (CFP, YFP, indx)
    if indx == 2
     r1 = CFP./YFP;
    else
     r1 = YFP./CFP;
    end
end

function f1 = FRET_change (r1)
avg3 = mean (r1(12:22,:)); %% From the 12th to the 22th value of the basal, 10 value, averaged before adding first stimulus at 24
f1 = ((r1./avg3)*100)-100;
end

function c1 = cyan_normal (CFP)
avg1 = mean (CFP(10:50, :));
c1 = ((CFP./avg1)*100)-100;
end

function y1 = yellow_normal (YFP)
avg2 = mean (YFP(10:50, :));
y1 = ((YFP./avg2)*100)-100;
end





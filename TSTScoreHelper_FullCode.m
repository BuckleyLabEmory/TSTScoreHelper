clear

%% Constants
GUI_fig_pos = [400 678 800 500];
mobility_definition_text = ["Tail climbing attempts";"Running movement with all four feet";"Jolting and twitching movments"];
immobility_definition_text = ["Hanging without moving";"Paddling with only two feet";"Pendulum swinging from mouse’s momentum"];
settings = struct('results_filepath',"Select Filepath",...
    'show_video_time_checkbox',1,...
    'show_video_name_checkbox',0,...
    'exclude_first_2_min_checkbox',0,...
    'clip_length_minimum',0.5,...
    'mobility_definition',mobility_definition_text,...
    'immobility_definition',immobility_definition_text);


%% Starting GUI
starting_GUI_fig = createStartingGUI(GUI_fig_pos,settings);

%% Starting screen
function GUI_fig = createStartingGUI(GUI_fig_pos,settings)
    % %close the fig opened previously
    % figTag = 'fig';
    % close(findobj('tag', figTag));
    
    %create new fig
    GUI_fig = figure('Name','TSTScoreHelper','position',GUI_fig_pos,'MenuBar','none','tag','start_screen_fig','Resize','off','NumberTitle','off');
    movegui(GUI_fig,'center');
    
    %create title
    titlePosition = [0.15 0.6 0.7 0.3];
    uicontrol('style','text','String','What would you like to do?','FontSize',30,'Parent',GUI_fig,'Units','Normalized','Position',titlePosition,'BackgroundColor',GUI_fig.Color);
    
    %functionality radio buttons
    functionality_button_group = uibuttongroup(GUI_fig, 'Position', [0.34 0.47 0.32 0.2]);
    info_symbol = char(9432);
    score_button = uicontrol(functionality_button_group, 'unit', 'normalized', 'style', 'radiobutton', 'string', ['Score entire videos  ' info_symbol], 'FontSize', 15, 'position', ...
        [0.05 0.56 0.9 0.3], 'BackgroundColor', 'White');
    score_button.Tooltip = sprintf('Watch the full TST video and mark\nwhen the subject is mobile and immobile');
    rescore_button = uicontrol(functionality_button_group, 'unit', 'normalized', 'style', 'radiobutton', 'string', ['Rescore videos  ' info_symbol], 'FontSize', 15, 'position', ...
        [0.05 0.13 0.9 0.3], 'BackgroundColor', 'White');
    rescore_button.Tooltip = sprintf('Rescore segments that previous scorers disagreed on');
    score_button.Value = 0;
    
    %scorer name textbox and label
    name_textbox = uicontrol(GUI_fig,'unit','normalized','style','edit','position',[0.3 0.25 0.4 0.1],'fontsize',20);
    name_textbox_label = uicontrol('style', 'text', 'String', 'Scorer Name: ', 'FontSize', 18, 'Parent', GUI_fig, ...
        'Units', 'Normalized', 'Position', [0.1 0.23 0.2 0.1], 'BackgroundColor', GUI_fig.Color);

    %settings button
    settings_button = uicontrol(GUI_fig,'Style','togglebutton','String','Settings','Units','Normalized','Position',[0.86 0.89 0.115 0.075],'FontSize',16);
    settings_button.Callback = {@openSettings,settings,settings_button};
    settings_button.UserData = settings;
    
    %start screen next button
    start_screen_next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontSize',20, ...
        'position', [0.8 0.1 0.15 0.1], 'tag', 'start_screen_next_button', 'KeyReleaseFcn', 'a');
    start_screen_next_button.Callback = {@starting_screen_completed, score_button, rescore_button, ...
        name_textbox,settings_button};

end

function starting_screen_completed(~, ~, score_button, rescore_button, name_textbox,settings_button)
    settings = settings_button.UserData;
    score_value = score_button.Value;
    rescore_value = rescore_button.Value;
    scorer_name = name_textbox.String;
    settings.scorer_name = scorer_name;
    if (score_value == 0) && (rescore_value == 0) && (scorer_name == 0)
        %need to enter what scoring and name
        score_and_name_error = msgbox('Error: Please select a scoring option and enter your name.','Error');
    elseif (score_value == 0) && (rescore_value == 0)
        score_error = msgbox('Error: Please select a scoring option.','Error');
    elseif (scorer_name == 0)
        name_error = msgbox('Error: Please enter your name.','Error');
    else
        close(findobj('tag', 'start_screen_fig'));
        if score_value == 1
            scoreTable(settings);
        else
            rescoreTable(settings);
        end
    end
end

function openSettings(~,~,settings,settings_button)
    length = 300;
    height = 500;
    %open settings fig
    settings_fig = uifigure('Name','Settings','Position',[400,400,length,height], 'MenuBar', 'none', 'tag', 'settings_fig','Resize','off','NumberTitle','off');
    movegui(settings_fig,'center');

    %save location
    save_location_title = uicontrol('Parent',settings_fig,'Style','text','String','Results Save Filepath','Units','normalized','Position',[0.1 0.915 0.8 0.05],'FontSize',12,'HorizontalAlignment','left');
    save_results_filepath_button = uicontrol('Parent',settings_fig,'Style','pushbutton','String',settings.results_filepath,'Units','normalized','Position',[0.05 0.85 0.45 0.07],'FontSize',12,'HorizontalAlignment','right');
    save_results_filepath_button.Callback = {@select_filepath,settings_fig};

    %show video time (checkbox)
    show_video_time_checkbox = uicontrol('Parent',settings_fig,'Style','checkbox','String','Display Video Time','Units','normalized','Position',[0.05 0.78 0.8 0.05],'FontSize',12,'Value',settings.show_video_time_checkbox);

    %show video name (checkbox)
    show_video_name_checkbox = uicontrol('Parent',settings_fig,'Style','checkbox','String','Display Video Name','Units','normalized','Position',[0.05 0.73 0.8 0.05],'FontSize',12,'Value',settings.show_video_name_checkbox);

    %score only after 2 minutes (checkbox)
    exclude_first_2_min_checkbox = uicontrol('Parent',settings_fig,'Style','checkbox','String','Exclude First 2 Minutes','Units','normalized','Position',[0.05 0.68 0.8 0.05],'FontSize',12,'Value',settings.exclude_first_2_min_checkbox);

    %minimum clip length
    clip_length_minimum = settings.clip_length_minimum;
    minimum_clip_length_text = uicontrol('Parent',settings_fig,'Style','text','String','Minimum Clip Length','FontSize',12,'Units','normalized','Position',[0.1 0.62 0.8 0.05],'HorizontalAlignment','left');
    minimum_clip_length_spinner = uispinner('Parent',settings_fig,'Value',settings.clip_length_minimum,'Limits',[0,Inf],'Step',0.1,'ValueDisplayFormat','%.01f s','Position',[(0.05*length) (0.55*height) (0.25*length) (0.07*height)],'FontSize',14);

    %mobility definition
    mobility_def_title = uicontrol('Parent',settings_fig,'Style','text','String','Mobility Definition:','Units','normalized','Position',[0.1 0.48 0.8 0.05],'FontSize',12,'HorizontalAlignment','left');
    mobility_def_textbox = uitextarea('Parent',settings_fig,'Value',settings.mobility_definition,'WordWrap','on','Position',[(0.05*length) (0.31*height) (0.9*length) (0.175*height)],'FontSize',14);
    
    %immobility defition
    immobility_def_title = uicontrol('Parent',settings_fig,'Style','text','String','Immobility Definition:','Units','normalized','Position',[0.1 0.25 0.8 0.05],'FontSize',12,'HorizontalAlignment','left');
    immobility_def_textbox = uitextarea('Parent',settings_fig,'Value',settings.immobility_definition,'WordWrap','on','Position',[(0.05*length) (0.08*height) (0.9*length) (0.175*height)],'FontSize',14);

    save_settings_button = uicontrol(settings_fig,'Style','pushbutton','String','Save','Units','normalized','Position',[.8 0.018 0.17 0.05]);
    save_settings_button.Callback = {@saveSettings,save_results_filepath_button,show_video_time_checkbox,show_video_name_checkbox,exclude_first_2_min_checkbox,minimum_clip_length_spinner,mobility_def_textbox,immobility_def_textbox,settings,settings_button};

end

function saveSettings(~,~,save_results_filepath_button,show_video_time_checkbox,show_video_name_checkbox,exclude_first_2_min_checkbox,minimum_clip_length_spinner,mobility_def_textbox,immobility_def_textbox,settings,settings_button)
    %save settings as settings array
    settings.results_filepath = save_results_filepath_button.String;
    settings.show_video_time_checkbox = show_video_time_checkbox.Value;
    settings.show_video_name_checkbox = show_video_name_checkbox.Value;
    settings.exclude_first_2_min_checkbox = exclude_first_2_min_checkbox.Value;
    settings.clip_length_minimum = minimum_clip_length_spinner.Value;
    settings.mobility_definition = mobility_def_textbox.Value;
    settings.immobility_definition = immobility_def_textbox.Value;
    settings_button.UserData = settings;

    settings_button.Callback{2} = settings;
    close(save_results_filepath_button.Parent);
end

function select_filepath(save_results_filepath_button,~,settings_fig)
    save_filepath = uigetdir();
    figure(settings_fig)
    movegui(save_results_filepath_button.Parent,'center');
    if save_filepath == 0 %user closed file select without selecting
        save_filepath = "Select Filepath";
    end
    save_results_filepath_button.String = save_filepath;
    save_results_filepath_button.Tooltip = save_filepath;
end

%% Calculate Immobility function

function [full_im_time,partial_im_time] = calculateImmobility(score_spreadsheet)
    try
        score_spreadsheet.Interval = datetime(score_spreadsheet.Interval,'Format','mm:ss.S');
    catch
        %score_spreadsheet.Interval is already in the correct format
    end
    score_spreadsheet.Mobility_status = zeros(height(score_spreadsheet),1);
    score_spreadsheet.Mobility_status(1:2:end) = 1;
    im_intervals = score_spreadsheet.Interval(score_spreadsheet.Mobility_status == 0);
    im_intervals_sec=(minute(im_intervals)*60) + second(im_intervals);
    full_im_time = sum(im_intervals_sec);

    try
        %calculate partial_im_time
        rows_post_2_min = find(score_spreadsheet.Total_sec >= 120);
        first_row_post_2_min = rows_post_2_min(1);
        score_spreadsheet_2_min_mark = [score_spreadsheet(1:first_row_post_2_min-1,:); table(datetime(0,0,0,"Format","mm:ss.SS"), datetime(0,0,0,0,2,0,"Format","mm:ss.SS"), 120, score_spreadsheet.Mobility_status(first_row_post_2_min+1), 'VariableNames',["Interval","Time","Total_sec","Mobility_status"]); score_spreadsheet(first_row_post_2_min:end,:)];
        score_spreadsheet_2_min_mark.Interval(2:end) = diff(score_spreadsheet_2_min_mark.Time) + datetime(0,0,0,"Format","mm:ss.S");
        
        partial_im_intervals = score_spreadsheet_2_min_mark.Interval(score_spreadsheet_2_min_mark.Mobility_status == 0 & score_spreadsheet_2_min_mark.Total_sec > 120);
        partial_im_intervals_sec = (minute(partial_im_intervals)*60) + second(partial_im_intervals);
        partial_im_time = sum(partial_im_intervals_sec);

    catch
        %Scoring doesn't reach 2 minutes so catch the empty array error and
        %set immobility time after 2 minutes to zero. This error happens if
        %the user presses next on scoring video before entering any marks
        %after 2 minutes. 
        partial_im_time = 0;
    end
end

%% findScoreDifferences function

function [differences,marks1,marks2] = findScoreDifferences(scorer_1_file_path,scorer_2_file_path,settings)
    %retrieve data
    stats1 = readtable(scorer_1_file_path{1}, 'VariableNamingRule', 'preserve');
    stats1.Interval = duration(stats1.Interval, 'InputFormat', 'mm:ss.SS', 'Format','mm:ss.SS');
    stats1.Interval_sec = seconds(stats1.Interval);
    stats1.Time = duration(stats1.Time, 'InputFormat', 'mm:ss.SS', 'Format','mm:ss.SS');
    stats1.Total_sec = seconds(stats1.Time);

    marks1 = stats1.Total_sec.';
    marks1 = marks1(:,1:length(marks1) - 1);

    stats2 = readtable(scorer_2_file_path{1}, 'VariableNamingRule', 'preserve','DatetimeType','exceldatenum');
    stats2.Interval = duration(stats2.Interval, 'InputFormat', 'mm:ss.SS', 'Format','mm:ss.SS');
    stats2.Interval_sec = seconds(stats2.Interval);
    stats2.Time = duration(stats2.Time, 'InputFormat', 'mm:ss.SS', 'Format','mm:ss.SS');
    stats2.Total_sec = seconds(stats2.Time);

    marks2 = stats2.Total_sec.';
    marks2 = marks2(:,1:length(marks2) - 1);

    %find how much the timing arrays are off by
    %mobility = 1, immobility = 0
    mobility_1 = ones(length(stats1.Time), 1);
    for a = 1:length(mobility_1)
        if mod(a, 2) == 0
            mobility_1(a, 1) = 0;
        end
    end
    timeline1 = timetable(stats1.Time, mobility_1);
    timeline1.Properties.VariableNames{1} = 'Mobility_score';
    timeline1 = rmmissing(timeline1);
    timeline1 = retime(timeline1, 'regular', 'previous', 'TimeStep', duration(0,0,0,1)); 
    timeline1 = rmmissing(timeline1);

    mobility_2 = ones(length(stats2.Time), 1);
    for a = 1:length(mobility_2)
        if mod(a, 2) == 0
            mobility_2(a, 1) = 0;
        end
    end
    timeline2 = timetable(stats2.Time, mobility_2);
    timeline2.Properties.VariableNames{1} = 'Mobility_score';
    timeline2 = rmmissing(timeline2);
    timeline2 = retime(timeline2, 'regular', 'previous', 'TimeStep', duration(0,0,0,1));
    timeline2 = rmmissing(timeline2);

    %longer signal needs to be first in xcorr
    if numel(timeline1) >= numel(timeline2)
        longer_timeline = timeline1;
        shorter_timeline = timeline2;
    else
        longer_timeline = timeline2;
        shorter_timeline = timeline1;
    end

    %xcorr to calculate lag       
    c = xcorr(longer_timeline.Mobility_score, shorter_timeline.Mobility_score);
    cmax = max(abs(c));

    %check to be sure there's no zero mark
    marks1 = transpose(nonzeros(marks1));
    marks2 = transpose(nonzeros(marks2));

    %shift marks by lag
    if numel(timeline1) >= numel(timeline2)
        marks1 = marks1 + (cmax/60000);
    else
        marks2 = marks2 - (cmax/60000);
    end

    %remove nan values, negative values(can be produced during xcorr), add
    %start marks, and cut off at shorter timeline length (6 min)
    trial_length = min(marks1(end), marks2(end));
    marks1 = rmmissing(marks1);
    marks1(marks1<0) = [];
    if marks1(1) ~= 0
        marks1 = [0 marks1];
    end
    marks2 = rmmissing(marks2);
    marks2(marks2<0) = [];
    if marks2(1) ~= 0
        marks2 = [0 marks2];
    end

    %Finding and correcting differences
    trial_length_in_ms = round(trial_length*1000);
    mob_1 = ones(trial_length_in_ms,1);
    mob_2 = ones(trial_length_in_ms,1);
    for a = 1:(length(marks1)-1)
        if mod(a,2) == 0
            first_mark = round(marks1(a)*1000);
            second_mark = round(marks1(a+1)*1000);
            mob_1(first_mark:second_mark) = 0;
        end
    end
    for a = 1:(length(marks2)-1)
        if mod(a,2) == 0
            first_mark = round(marks2(a)*1000);
            second_mark = round(marks2(a+1)*1000);
            mob_2(first_mark:second_mark) = 0;
        end
    end
    combined_mob = mob_1(1:trial_length_in_ms) + mob_2(1:trial_length_in_ms);

    disagreements = find(combined_mob == 1);
    changes = find([diff(disagreements); inf] > 1); %finds where there are runs of consecutive same numbers, returns an array of
    %the indexes of the disagreements array where the runs ends
    starts = [disagreements(1); disagreements(changes(1:end-1)+1)];
    ends = disagreements(changes);
    differences = table(starts, ends, ends-starts, (ends-starts)/1000, zeros(length(starts),1), zeros(length(starts),1));
    differences.Properties.VariableNames = ["Starts", "Ends", "Length_in_Milliseconds", "Length_in_Seconds", "Score", "Scored"];
    %take out clips before 2 minutes if setting is selected
    if settings.exclude_first_2_min_checkbox
        clips_before_2_min = find(differences.Ends(:) <= 120000);
        differences(clips_before_2_min,:) = [];
        if differences.Starts(1) <= 120000
            differences.Starts(1) = 120000;
        end
    end
    %mark clips that are too short to be scored
    clips_too_short = find(differences.Length_in_Seconds(:) <= settings.clip_length_minimum);
    differences.Scored(clips_too_short) = -1;

end
%% generateScoringTimeline function

function scoring_timeline_figure = generateScoringTimeline(rescoring,video_name,marks1,marks2,marks_rescore,scores)
    scoring_timeline_figure = figure('Visible', 'off', 'Position', [440, 643, 600, 200]);
    hold on
    mobile_color = "black";
    immobile_color = "#D0D0D0";

    if ~rescoring
        %only plotting the one scorer
        ylim([0 1])
        title(video_name,"FontSize",25)
        xlabel('Video Time (seconds)')
        yticks(0.5)
        
        marks1 = [0, marks1];
        for i = 1:(length(marks1) - 1)
            if mod(i, 2) == 1
                color = mobile_color;
            else
                color = immobile_color;
            end
            plot([marks1(i); marks1(i+1)], [0.5; 0.5], 'Color', color, 'LineWidth', 20)
        end

        max_x = max(marks1);
        xlim([0 max_x])
        
        %add padding around graph
        axes_row = isgraphics(scoring_timeline_figure.Children,'axes');
        timeline_axis = scoring_timeline_figure.Children(axes_row);
        pos = get(timeline_axis,'Position');
        timeline_axis.Position(2) = 1.75*pos(2);
        timeline_axis.Position(3) = 0.675;
        timeline_axis.Position(4) = 0.8*pos(4);

        timeline_axis.FontSize = 15;

        %add immobility value labels with score
        %score.full_im_time1,partial_im_time1
        score1_text = strcat('T_f','=',num2str(round(scores.full_im_time1,0)),', T_p','=',num2str(round(scores.partial_im_time1,0)));
        annotation('textbox',[.806 .5 .1 .1],'String',score1_text,'EdgeColor','none','FontSize',15)

        %legend
        h(1) = patch(NaN,NaN,'k');
        h(1).FaceColor = mobile_color;
        h(1).EdgeColor = mobile_color;
        h(2) = patch(NaN,NaN,'k');
        h(2).FaceColor = immobile_color;
        h(2).EdgeColor = immobile_color;
        fig_legend = legend(h,{'Mobile',"Immobile"},'Location','none','Orientation','horizontal','Color','none','Box','off');
        fig_legend.Position = [0.05 0.05 0.275 0.1];


    else
        %plotting both scorers and rescore
        ylim([0 2])
        title(video_name,"FontSize",25)
        xlabel('Time (Seconds)')
        yticks([0.5 1 1.5])
        yticklabels({'Rescore','Score 1','Score 2'})
        %set(scoring_timeline_figure, 'Position', [440, 643, 560, 170])

        %plot score 1
        for i = 1:(length(marks1) - 1)
            if mod(i, 2) == 1
                color = mobile_color; 
            else
                color = immobile_color; 
            end
            plot([marks1(i); marks1(i+1)], [1.5; 1.5], 'Color', color, 'LineWidth', 20)
        end

        %plot score 2
        for i = 1:(length(marks2) - 1)
            if mod(i, 2) == 1
                color = mobile_color; 
            else
                color = immobile_color; 
            end
            plot([marks2(i); marks2(i+1)], [1; 1], 'Color', color, 'LineWidth', 20)
        end

        %plot rescore
        marks_rescore = [marks_rescore, 360];
        for i = 1:(length(marks_rescore) - 1)
            if mod(i, 2) == 1
                color = mobile_color; %mobile
            else
                color = immobile_color; %immobile
            end
            plot([marks_rescore(i); marks_rescore(i+1)], [0.5; 0.5], 'Color', color, 'LineWidth', 20)
        end

        max_x = max([marks1(end),marks2(end),marks_rescore(end)]);
        xlim([0 max_x])
        %add padding around graph
        timeline_axis = scoring_timeline_figure.Children(1);
        pos = get(timeline_axis,'Position');
        timeline_axis.Position(2) = 1.75*pos(2);
        timeline_axis.Position(3) = 0.675;
        timeline_axis.Position(4) = 0.8*pos(4);

        timeline_axis.FontSize = 15;

        %add immobility value labels with score
        %score.full_im_time1,partial_im_time1,full_im_time2,partial_im_time2,full_im_time_rescore,partial_im_time_rescore
        score1_text = strcat('T_f','=',num2str(round(scores.full_im_time1,0)),', T_p','=',num2str(round(scores.partial_im_time1,0)));
        score2_text = strcat('T_f','=',num2str(round(scores.full_im_time2,0)),', T_p','=',num2str(round(scores.partial_im_time2,0)));
        rescore_text = strcat('T_f','=',num2str(round(scores.full_im_time_rescore,0)),', T_p','=',num2str(round(scores.partial_im_time_rescore,0)));
        annotation('textbox',[.806 .64 .1 .1],'String',score1_text,'EdgeColor','none','FontSize',15)
        annotation('textbox',[.806 .5 .1 .1],'String',score2_text,'EdgeColor','none','FontSize',15)
        annotation('textbox',[.806 .36 .1 .1],'String',rescore_text,'EdgeColor','none','FontSize',15)

        %legend
        h(1) = patch(NaN,NaN,'k');
        h(1).FaceColor = mobile_color;
        h(1).EdgeColor = mobile_color;
        h(2) = patch(NaN,NaN,'k');
        h(2).FaceColor = immobile_color;
        h(2).EdgeColor = immobile_color;
        fig_legend = legend(h,{'Mobile',"Immobile"},'Location','none','Orientation','horizontal','Color','none','Box','off');
        fig_legend.Position = [0.05 0.05 0.275 0.1];
    end
end

%% playVideo functions

function playVideo(play_button,~, video, start_time, end_time, pause_time, settings)
%This function plays the input video in the designated panel
    
    %determine what action is supposed to happen when button is pressed
    video_started_first_time = strcmp(play_button.String,'Start');
    video_paused = strcmp(play_button.String,'Pause');
    video_continue = strcmp(play_button.String,'Continue');
    strcmp(play_button.String,'Replay');

    video_fig = findall(0,'Type','figure','Tag','video_scoring_figure');

    v = VideoReader(video);
    if end_time == 0
        end_time = v.Duration*1000;
    end

    if video_paused
        play_button.String = 'Continue';
        play_button.Callback{5} = guidata(video_fig)*1000;
    elseif video_continue
        play_button.String = 'Pause';
        v.CurrentTime = (pause_time/1000);
    else
        %video_replay or video_started_first_time
        play_button.String = 'Pause';

        v.CurrentTime = (start_time/1000);
        if video_started_first_time
            start_text = findall(0,'Type','uicontrol','Tag','start_instructions_text');
            
            %set start text to invisible and set video panel dimensions
            set(start_text,'Visible','off')
    
            %get size of video
            video_width = v.Width;
            video_height = v.Height;
        
            video_panel_position = [0.05 0.3 0.5 0.5];
            GUI_fig_pos = video_fig.Position;
    
            if video_height/video_width <= (GUI_fig_pos(4)/GUI_fig_pos(3))
                %video height is the limiting dimemsion. Resize video to keep
                %aspect ratio by making video width = video panel width and finding
                %height that preserves aspect ratio
                video_panel_heigth = video_panel_position(4)*(video_height/video_width)*(GUI_fig_pos(3)/GUI_fig_pos(4));
                video_panel_bottom = video_panel_position(2)+(video_panel_position(4)/2)-(video_panel_heigth/2);
                video_panel_pos = [video_panel_position(1) video_panel_bottom video_panel_position(3) video_panel_height];
            else
                video_panel_width = video_panel_position(3)*(video_width/video_height)*(GUI_fig_pos(4)/GUI_fig_pos(3));
                video_panel_left = video_panel_position(1)+(video_panel_position(3)/2)-(video_panel_width/2);
                video_panel_pos = [video_panel_left 0.3 video_panel_width 0.5];
            end
            
            video_panel = findall(0,'Type','uipanel','Tag','video_display_panel');
            video_panel.Position = video_panel_pos;
    
            %create video timer
            if settings.show_video_time_checkbox
                video_timer = findobj('Tag','video_timer');
                if exist("video_timer","var")
                    %code doesn't have this var accesible at this point
                    %but it still exists. need to retreive it to delete it.
                    clear video_timer
                end
                video_length = round((end_time - start_time)/1000,1);
                timer_text = append("0/",string(round(video_length))," s");
                video_time_position = [0.05*800 0.25*500 0.2*800 0.05*500];
                video_timer = uilabel('Text',timer_text,'FontSize',16,'Parent',video_fig,'Position',video_time_position, ...
                    'BackgroundColor',video_fig(1).Color,'HorizontalAlignment','left','Tag','video_timer');
            end

        end
    end

    video_axis = findall(0,'Type','axes','Tag','video_display_axis');
    loop_start_time = tic;
    loop_marks = [];

    while hasFrame(v) && ((start_time/1000) <= v.CurrentTime) && (v.CurrentTime <= (end_time/1000)) && strcmp(play_button.String,'Pause')
        frame = readFrame(v);
        showFrame(video_axis, frame);
        %set v.CurrentTime to gui fig data so that it can be accessed by
        %the change in mobility mark function
        guidata(video_fig,v.CurrentTime);
        
        %calibrate video speed
        if length(loop_marks) == 25
            loop_lengths = loop_marks(2:end)-loop_marks(1:end-1);
            loop_lengths = loop_lengths(2:end); %remove first value since it is not always representative
            average_loop_length = sum(loop_lengths)/length(loop_lengths);
            loop_delay = 1/v.FrameRate - average_loop_length;
            pause('on')
        end
        if exist("loop_delay")
            pause(loop_delay)
        else
            loop_mark = toc(loop_start_time);
            loop_marks = [loop_marks; loop_mark];
        end
        
        if settings.show_video_time_checkbox
            %video/clip prograss bar
            video_timer = findall(0,'Type','uilabel','Tag','video_timer');
            %delete all extra instances of video timer
            video_timer = video_timer(1);
            video_length = round((end_time - start_time)/1000,1);
            video_progress = round(v.CurrentTime - (start_time/1000),1);
            if video_progress > video_length
                video_progress = video_length;
            end
            timer_text = append(string(video_progress),"/",string(video_length)," s");
            video_timer.Text = timer_text;
        end
        
    end
    
    if v.CurrentTime >= (end_time/1000)
        %when video is over, button text changes to replay
        play_button.String = 'Replay';
    end
    
end

function showFrame(video_axis, frame) 
    %based on function showFrameOnAxis function in 'Video in a Custom User Interface'
    %checkFrame(frame);
    frame = convertToUint8RGB(frame);

    try
        axis_child = get(video_axis, 'Children');
    catch
        return;
    end

    has_video_started = ~isempty(axis_child);
    if ~has_video_started
        %current_image = displayImage(video_axis, frame);
        displayImage(video_axis,frame)
    else
        current_image = axis_child;
        %checkFrameSize(current_image, size(frame))
        try
            set(current_image,'cdata',frame); drawnow;
        catch
            %figure closed
            return
        end
    end
end

function checkFrame(frame) %from 'Video in a Custom User Interface'
    % Validate input image
    validateattributes(frame, ...
    {'uint8', 'uint16', 'int16', 'double', 'single','logical'}, ...
    {'real','nonsparse'}, 'insertShape', 'I', 1)

    % Input image must be grayscale or truecolor RGB.
    errCond=(ndims(frame) >3) || ((size(frame,3) ~= 1) && (size(frame,3) ~=3));
    if (errCond)
        error('Input image must be grayscale or truecolor RGB');
    end
end

function frame = convertToUint8RGB(frame) %from 'Video in a Custom User Interface'
    %Convert input data type to uint8
    if ~isa(class(frame), 'uint8')
        frame = im2uint8(frame);
    end

    %If the input is grayscale, turn it into an RGB image 'Video in a Custom User Interface'
    if (size(frame,3) ~= 3) %must be 2d
        frame = cat(3,frame, frame, frame);
    end
end

function checkFrameSize(current_image, frame_size)
    % Check frame size
    prev_size = size(get(current_image, 'cdata'));
    if ~isequal(prev_size, frame_size)
        error('Frame size must remain the same');
    end
end

function displayImage(video_axis, frame)
    %Display image in the specified axis
    frameSize = size(frame);
    xdata = [1 frameSize(2)];
    ydata = [1 frameSize(1)];
    cdata = frame;
    cdatamapping = 'direct';

    image(xdata,ydata,cdata, ...
       'BusyAction', 'cancel', ...
       'Parent', video_axis, ...
       'CDataMapping', cdatamapping, ...
       'Interruptible', 'off');
    set(video_axis, ...
        'YDir','reverse',...
        'TickDir', 'out', ...
        'XGrid', 'off', ...
        'YGrid', 'off', ...
        'PlotBoxAspectRatioMode', 'auto', ...
        'Visible', 'off', ...
        'Tag', 'video_display_axis');
end

%% rescoreFigure functions

function [GUI_fig, videoPanel, play_button, next_button, clip_counter, start_text] = rescoreFigure(file_table,settings)    
    %create new fig
    GUI_fig_pos = [400 678 800 500];
    GUI_fig = uifigure('Name', 'TST Rescore', 'position', GUI_fig_pos, 'MenuBar', 'none', 'Tag', 'video_scoring_figure','Resize','off');
    movegui(GUI_fig,'center');
    
    %create video and button panels
    videoPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.3 0.5 0.5], 'BorderWidth',2,'BorderColor','k','Tag','video_display_panel');
    textPanel = uipanel('Parent',GUI_fig,'Units','Normalized','Position',[0.55 0.25 0.4 0.6],'BorderWidth',0,'Tag','mob_def_text_panel');
    buttonPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.05 0.9 0.2], 'BorderWidth', 0,'Tag','scoring_buttons_panel');
    
    %create axis
    video_axis = axes('position', [0 0 1 1], 'Parent', videoPanel,'Tag','video_display_axis');
    video_axis.XTick = [];
    video_axis.YTick = [];
    video_axis.XColor = [1 1 1];
    video_axis.YColor = [1 1 1];
    
    %create title
    title_position = [0.3 0.87 0.4 0.1];
    uicontrol('style', 'text', 'String', 'Mobility Analysis', 'FontSize', 30, 'Units', 'Normalized', 'Parent', GUI_fig, 'Position', title_position, 'BackgroundColor', GUI_fig.Color);
    
    %start text
    start_text_string = 'Press the start button.';
    start_text_pos = [0.3 0.35 0.4 0.3];
    start_text = uicontrol('style', 'text', 'String', start_text_string, 'FontSize', 20, 'Units', 'Normalized', 'Parent', videoPanel, ...
        'Position',start_text_pos,'BackgroundColor',videoPanel.BackgroundColor,'Tag','start_instructions_text');
    
    %mobility definition text
    mobility_definition = settings.mobility_definition;
    immobility_definition = settings.immobility_definition;
    %format text
    for i = 1:height(mobility_definition)
        mobility_definition(i) = append('-',mobility_definition(i));
    end
    for i = 1:height(immobility_definition)
        immobility_definition(i) = append('-',immobility_definition(i));
    end
    uicontrol('style', 'text', 'String', "Mobility:", 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.9 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
    uicontrol('style', 'text', 'String', mobility_definition, 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.5 0.9 0.4], 'HorizontalAlignment', 'left');
    uicontrol('style', 'text', 'String', "Immobility:", 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.4 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
    uicontrol('style', 'text', 'String', immobility_definition, 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.0 0.9 0.4], 'HorizontalAlignment', 'left');

    %keeping track of videos and clips that have been scored
    file_table.scored = zeros(height(file_table),1);
    video = file_table.video_filepath{1}; 
    [differences,marks1,marks2] = findScoreDifferences(file_table.score_1_filepath(1),file_table.score_2_filepath(1),settings);
    scorable_clips = find(differences.Scored ~= -1);
    first_clip = scorable_clips(1); %can't assume that first clip in differences is longer than clip_length_minimum so have to find rows that aren't excluded

    %set results filepath if not specified
    if strcmp(settings.results_filepath,"Select Filepath")
        [video_filepath,~] = fileparts(video);
        settings.results_filepath = video_filepath;
    end

    %clip counter
    number_of_videos = height(file_table);
    number_of_clips = sum(differences.Scored ~= -1);
    clip_counter_text = append("Video 1/",string(number_of_videos),", Clip 1/",string(number_of_clips));
    if settings.show_video_name_checkbox
        [~, video_name] = fileparts(video);
        clip_counter_text = append(clip_counter_text,", ",video_name);
    end
    clip_counter_pos = [0.05 0.805 0.5 0.05];
    clip_counter = uicontrol('style', 'text', 'String', clip_counter_text, 'FontSize', 16, ...
        'Units', 'Normalized', 'Parent', GUI_fig, 'Position', clip_counter_pos, 'BackgroundColor', GUI_fig.Color,'HorizontalAlignment','left');
        
    %play button
    play_button = uicontrol(GUI_fig, 'unit', 'Normalized', 'style', 'pushbutton', 'string', 'Start', 'FontSize', 18, 'position', [0.6 0.1 0.15 0.1], 'Tag', ...
    'video_play_button');
    play_button.Callback = {@playVideo, video, differences.Starts(first_clip), differences.Ends(first_clip), 0, settings};
    play_button.UserData = file_table;

    %mobility and immobility switch
    mobility_switch_position = [175 70 50 25];
    mobility_switch = uiswitch(buttonPanel,'slider','Items',{'Mobile','Immobile'},'FontSize',20,'Orientation','horizontal','Position',mobility_switch_position);%,'ValueChangedFcn',{@mobilityMark,GUI_fig});
    
    %next button
    next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontSize',18, ...
        'position', [0.8 0.1 0.15 0.1], 'tag', 'next_button');
    next_button.Callback = {@rescoreNext,mobility_switch,play_button,clip_counter,settings};
    scoring_data = struct("differences",differences,"marks1",marks1,"marks2",marks2);
    next_button.UserData = scoring_data;
end

%% rescoreNext functions

function next_button = rescoreNext(next_button,~,mobility_switch,play_button,clip_counter,settings)
    scoring_data = next_button.UserData;
    differences = scoring_data.differences;
    if strcmp(mobility_switch.Value,'Mobile')
        decision = 1;
    else
        decision = 0;
    end
    
    %find first row of file_table where score = 0, this is the clip just
    %scored
    not_scored_clip = find(differences.Scored == 0);
    %assign decision to differences row that was just scored
    differences.Score(not_scored_clip(1)) = decision;
    %update scored column to scored
    differences.Scored(not_scored_clip(1)) = 1;
    scoring_data.differences = differences;
    next_button.UserData = scoring_data;

    %set up next video/clip
    if isempty(find(differences.Scored == 0,1)) 
        %finds first row that has Scored = 0. If none are found, an empty 
        %vector is returned indicating that there are no unscored rows.
        %all clips scored so save the results move on to next video

        %save results
        saveResults(play_button,next_button.UserData,settings)

        %next video
        file_table = play_button.UserData;
        not_scored_video = find(file_table.scored == 0);
        just_scored = not_scored_video(1);
        file_table.scored(just_scored) = 1;
        play_button.UserData = file_table;

        if length(not_scored_video) >= 2
            next_video = not_scored_video(2);
            video = file_table.video_filepath{next_video};
            [differences,marks1,marks2] = findScoreDifferences(file_table.score_1_filepath(next_video),file_table.score_2_filepath(next_video),settings);
            scoring_data.differences = differences;
            scoring_data.marks1 = marks1;
            scoring_data.marks2 = marks2;
            next_button.UserData = scoring_data;

            scorable_clips = find(differences.Scored ~= -1);
            first_clip = scorable_clips(1);

            play_button.Callback = {@playVideo,video,differences.Starts(first_clip),differences.Ends(first_clip),NaN,settings};
            play_button.String = "Start";

            %update clip text too
            number_of_videos = string(height(file_table));
            current_video = string(next_video);
            number_of_clips = sum(differences.Scored ~= -1);
            clip_counter_text = append('Video ',current_video,'/',number_of_videos,", Clip 1/",string(number_of_clips));
            if settings.show_video_name_checkbox
                [~, video_name] = fileparts(video);
                clip_counter_text = append(clip_counter_text,", ",video_name);
            end
            clip_counter.String = clip_counter_text;
        else
            %that was the last video
            uialert(next_button.Parent,append("Finished scoring all videos. Results saved at ",settings.results_spreadsheet,"."),'Scoring Complete','Icon','success')
            
        end
    else
        %update clip counter
        clip_counter_text = clip_counter.String;

        commas = strfind(clip_counter_text,',');
        video_count = clip_counter_text(1:commas(1));
        current_clip_number = height(find(differences.Scored == 1))+1; %count how many clips have been scored and add 1
        number_of_clips = sum(differences.Scored ~= -1);
        clip_count = append(" Clip ",string(current_clip_number),"/",string(number_of_clips));
        clip_counter_text = append(video_count,clip_count);

        if settings.show_video_name_checkbox
            temp_clip_counter_text = clip_counter.String;
            %commas = strfind(temp_clip_counter_text,',');
            video_name = temp_clip_counter_text(commas(2):end);
            clip_counter_text = append(clip_counter_text,video_name);
        end
        
        clip_counter.String = clip_counter_text;

        %queue next clip
        next_clip = find(differences.Scored == 0,1);
        play_button.Callback{3} = differences.Starts(next_clip);
        play_button.Callback{4} = differences.Ends(next_clip);
        play_button.String = "Start";
    end
end

function saveResults(play_button,scoring_data,settings)
    %check for folder
    differences = scoring_data.differences;
    marks1 = scoring_data.marks1;
    marks2 = scoring_data.marks2;
    current_video = play_button.Callback{2};
    [~,video_name] = fileparts(current_video);
    scoring_folder = append(settings.results_filepath,filesep,video_name);
    if ~exist(scoring_folder,"dir")
        mkdir(scoring_folder)
    end
    
    %make scoring_table
    file_table = play_button.UserData;
    just_scored_video = find(file_table.scored == 0,1);
    just_scored_spreadsheet = readtable(file_table.score_1_filepath{just_scored_video(1)}, 'VariableNamingRule', 'preserve');
    just_scored_spreadsheet.Time = datetime(just_scored_spreadsheet.Time,'Format','mm:ss.S');
    just_scored_spreadsheet.Total_sec = (minute(just_scored_spreadsheet.Time)*60) + second(just_scored_spreadsheet.Time);
    scoring_timeline = ones((max(just_scored_spreadsheet.Total_sec)*1000),1);
    marks = just_scored_spreadsheet.Total_sec*1000;
    marks(1) = 1;
    marks = marks(1:end-1,:);
    for i = 1:height(marks)
        if mod(i,2) == 0
            scoring_timeline(marks(i-1):marks(i)) = 0;
        end
    end
    %edit differences decisions
    for i = 1:height(differences)
        if differences.Scored(i)
            scoring_timeline(differences.Starts(i):differences.Ends(i)) = differences.Score(i);
        end
    end
    %convert scoring table
    marks = find([diff(scoring_timeline); inf] ~= 0);
    total_sec = [0; marks/1000];
    time = datetime(0,0,0,0,floor(total_sec/60),mod(total_sec,60),'Format','mm:ss.SS');
    interval = [0; diff(time)];
    interval = interval + datetime(0,0,0,"Format","mm:ss.SS");
    scoring_table = table(interval,time,total_sec);
    scoring_table.Properties.VariableNames = {'Interval','Time','Total_sec'};

    %Write to spreadsheet
    file_name = append(video_name,"_rescore_",settings.scorer_name);
    if exist(append(scoring_folder,filesep,file_name,'.xlsx'),"file")
        time_now = datetime("now","Format",'yyyy-MM-dd_HHmmss');
        file_name = append(file_name,'_',string(time_now));
    end
    rescore_filepath = append(scoring_folder,filesep,file_name,'.xlsx');
    writetable(scoring_table,rescore_filepath);

    score2_spreadsheet = readtable(file_table.score_2_filepath{just_scored_video(1)}, 'VariableNamingRule', 'preserve');
    score2_spreadsheet.Time = datetime(score2_spreadsheet.Time, 'Format','mm:ss.S');
    score2_spreadsheet.Total_sec = (minute(score2_spreadsheet.Time)*60) + second(score2_spreadsheet.Time);

    marks_rescore = scoring_table.Total_sec.';
    marks_rescore = marks_rescore(:,1:length(marks_rescore)-1);

    %write immobility time to results spreadsheet
    [full_im_time1,partial_im_time1] = calculateImmobility(just_scored_spreadsheet);
    [full_im_time2,partial_im_time2] = calculateImmobility(score2_spreadsheet);
    [full_im_time_rescore,partial_im_time_rescore] = calculateImmobility(scoring_table);

    immobility_results_table = readtable(settings.results_spreadsheet);
    row = just_scored_video(1);

    immobility_results_table.Score_1_immobility_full(row) = full_im_time1;
    immobility_results_table.Score_1_immobility_after_2_min(row) = partial_im_time1;
    immobility_results_table.Score_2_immobility_full(row) = full_im_time2;
    immobility_results_table.Score_2_immobility_after_2_min(row) = partial_im_time2;
    immobility_results_table.Rescore_immobility_full(row) = full_im_time_rescore;
    immobility_results_table.Rescore_immobility_after_2_min(row) = partial_im_time_rescore;
    immobility_results_table.Rescore_filepath(row) = rescore_filepath;
    
    writetable(immobility_results_table,settings.results_spreadsheet,"WriteMode","overwrite");

    scores = struct('full_im_time1',full_im_time1,'partial_im_time1',partial_im_time1,'full_im_time2',full_im_time1,'partial_im_time2',partial_im_time2,'full_im_time_rescore',full_im_time_rescore,'partial_im_time_rescore',partial_im_time_rescore);
    scoring_timeline_fig = generateScoringTimeline(1,video_name,marks1,marks2,marks_rescore,scores);
    figure_name = append(scoring_folder,filesep,file_name,'.png');
    saveas(scoring_timeline_fig,figure_name)
end

%% rescoreTable functions

function rescoreTable(settings)
    GUI_fig_pos = [400 678 800 500];
    fig = uifigure('Name', 'Rescore File Select', 'position', GUI_fig_pos, 'MenuBar', 'none','Resize','off');
    movegui(fig,'center');

    %create title
    title_position = [0 0.85 1 0.1];
    rescore_file_select_title = uicontrol('Parent',fig,'Style','text','String','ReScore File Select','FontSize',30,'Units','Normalized','Position',title_position);
    
    %delete button
    delete_button = uicontrol('Parent',fig,'Units','normalized','style','pushbutton','string','Delete table','position',[0.8 0.25 0.15 0.1],'FontSize',14,'Visible','off');
    
    %table panel
    table_panel = uipanel('Parent',fig,'Units','Normalized','Position',[0.05 0.05 0.7 0.75],'BackgroundColor','white','BorderType','line','BorderWidth',2,'BorderColor','k');
    
    %table note
    table_note = uicontrol('Parent',fig,'Style','text','String',"Hover over table to see full text",'Units','normalized','Position',[0.05 0 0.7 0.048],'FontSize',12,'Visible','off','HorizontalAlignment','left');

    %instructions to add spredsheet
    table_instruction_text = uicontrol('Parent',table_panel,'Style','text','String','Add a spreadsheet of the trials to score.','FontSize',24,'Units','Normalized','Position',[0.1 0.45 0.8 0.25],'BackgroundColor','white');
    
    %next button
    next_button = uicontrol(fig,'unit','normalized','style','pushbutton','string','Next','position',[0.8 0.1 0.15 0.1],'FontSize',18);
    %next_button.Callback = {@rescore_nextScreen, file_data_table, fig, settings};
    %add KeyPressFcn to have enter call next button

    %upload button
    upload_table_button = uicontrol('Parent',table_panel,'Units','Normalized','style','pushbutton','string','Upload file','position',[0.375 0.33 0.25 0.13],'FontSize',19);
    upload_table_button.Callback = {@rescore_addTable,fig,table_panel,table_note,delete_button,next_button,settings};

end

function rescore_addTable(~,~,fig,table_panel,table_note,delete_button,next_button,settings) %took out ui_file_table = 
    [score_files_table_file_name, score_files_table_path] = uigetfile('*.xlsx','Select the spreadsheet of files to score', 'MultiSelect', 'off');
    if any([score_files_table_file_name == 0, score_files_table_path == 0])
        %the file name and/or path is empty
        uialert(fig,"Error:no file selected.","Error")
    else
        %make text and button invisible, essentially replaced by table.
        %invisible instead of deleted so that it can be reactivated if
        %table is deleted
        for i = 1:length(table_panel.Children)
            table_panel.Children(i).Visible = 'off';
        end
        try
            file_data_table = readtable([score_files_table_path filesep score_files_table_file_name]);
            ui_file_table = uitable(table_panel,'Data',file_data_table,'ColumnEditable',false,'ColumnWidth',{'1x','1x','1x'},'Units','normalized','Position',[0 0 1 1],'FontSize',16,'Tag','rescore_file_select_table');
            guidata(fig,file_data_table);
    
            %change column names on uitable (file_data_table keeps original
            %names)
            %not able to increase text size of column names, could cover with a
            %label but for now just leaving the text size small
            ui_file_table.ColumnName = {'Video'; 'Score 1'; 'Score 2'};
    
            %table styling
            sLeftClip = uistyle("HorizontalClipping","left");
            addStyle(ui_file_table,sLeftClip);
    
            sCenterAlignment = uistyle("HorizontalAlignment","center");
            addStyle(ui_file_table,sCenterAlignment,"column",1);
            addStyle(ui_file_table,sCenterAlignment,"column",2);
            addStyle(ui_file_table,sCenterAlignment,"column",3);
    
            figure(fig);
    
            %delete button
            delete_button.Callback = {@deleteTable,table_panel,ui_file_table,delete_button};
            delete_button.Visible = 'on';
    
            %next button callback
            next_button.Callback = {@rescore_nextScreen,fig,settings};
    
            %table note visible
            table_note.Visible = 'on';
        catch
            uialert(fig,'Error with spreadsheet. Please delete the table, fix the spreadsheet, and reupload.',"Error")
        end
    end
end

function deleteTable(~,~,table_panel,ui_file_table,delete_button)
    %delete ui_file_table
    delete(ui_file_table)

    %make text and button visible again
    for i = 1:length(table_panel.Children)
        table_panel.Children(i).Visible = 'on';
    end

    %make delete button and edit button invisible again
    delete_button.Visible = 'off';
end

function rescore_nextScreen(~,~,fig,settings)
    file_uitable = findall(0,'Type','uitable','Tag','rescore_file_select_table');
    file_table = file_uitable.Data;
    file_error = false;
    errors = [];
    
    for i = 1:height(file_table)
        %check video
        try
            video_filepath = file_table.video_filepath{i};
            VideoReader(video_filepath);
        catch ME
            file_error = true;
            errors = [errors; {[newline video_filepath newline ME.message]}];
        end

        %check score 1
        try
            score1_filepath = file_table.score_1_filepath{i};
            readtable(score1_filepath);
        catch ME
            file_error = true;
            errors = [errors; {[newline video_filepath newline ME.message]}];
        end

        %check score 2
        try
            score2_filepath = file_table.score_2_filepath{i};
            readtable(score2_filepath);
        catch ME
            file_error = true;
            errors = [errors; {[newline video_filepath newline ME.message]}];
        end
    end

    %check that number of columns is correct
    if width(file_table) ~= 3
        file_error = true;
        errors = [errors; {[newline 'Number of table columns should be 3.']}];
    end

    if ~file_error
        %randomize order
        new_order = randperm(height(file_table));
        file_table = file_table(new_order,:);

        results_spreadsheet_name = rescore_createResultsSpreadsheet(file_table,settings);
        %call function for rescoring
        settings.results_spreadsheet = results_spreadsheet_name;
        rescoreFigure(file_table,settings);
        close(fig);
    else
        uialert(fig,['Error with: '; errors; 'Please delete the table, fix the spreadsheet, and reupload.'],"Error")
    end
end

function results_spreadsheet_name = rescore_createResultsSpreadsheet(file_table,settings)
    %create table
    today_date = string(datetime("today"));
    num_trials = height(file_table);
    date = repelem(today_date,num_trials)';
    scorer_name = repelem(string(settings.scorer_name),num_trials)';
    %extract video names
    pattern = asManyOfPattern(wildcardPattern + filesep);
    video_names = extractAfter(file_table.video_filepath,pattern);
    data_table = table(date,scorer_name,video_names);
    data_table.Score_1_immobility_full = zeros(num_trials,1);
    data_table.Score_1_immobility_after_2_min = zeros(num_trials,1);
    data_table.Score_2_immobility_full = zeros(num_trials,1);
    data_table.Score_2_immobility_after_2_min = zeros(num_trials,1);
    data_table.Rescore_immobility_full = zeros(num_trials,1);
    data_table.Rescore_immobility_after_2_min = zeros(num_trials,1);
    data_table.Video_filepath = file_table.video_filepath;
    data_table.Score_1_filepath = file_table.score_1_filepath;
    data_table.Score_2_filepath = file_table.score_2_filepath;
    data_table.Rescore_filepath = strings([num_trials,1]);

    %create excelsheet and file paths
    if strcmp(settings.results_filepath,"Select Filepath")
        results_filepath = fileparts(file_table.video_filepath{1}); %folder of first video in list
    else
        results_filepath = settings.results_filepath;
    end

    results_spreadsheet_name = append(results_filepath,filesep,'Results_rescore_',settings.scorer_name,'.xlsx');
    if exist(results_spreadsheet_name,"file")
        results_spreadsheet_name = append(results_filepath,filesep,'Results_rescore_',settings.scorer_name,'_',string(datetime("now","Format","uuuu-MM-dd_HHmmss")),'.xlsx');
    end
    writetable(data_table,results_spreadsheet_name,'WriteMode','append','AutoFitWidth',false);
end

%% scoreTable functions

function scoreTable(settings)
    GUI_fig_pos = [400 678 800 500];
    fig = uifigure('Name', 'Score File Select', 'position', GUI_fig_pos, 'MenuBar', 'none','Resize','off');
    movegui(fig,'center');

    %create title
    title_position = [0 0.85 1 0.1];
    rescore_file_select_title = uicontrol('Parent',fig,'Style','text','String','Score File Select','FontSize',30,'Units','Normalized','Position',title_position);
    
    %delete button
    delete_button = uicontrol('Parent',fig,'Units','normalized','style','pushbutton','string','Delete table','position',[0.8 0.25 0.15 0.1],'FontSize',14,'Visible','off');

    %table panel
    table_panel = uipanel('Parent',fig,'Units','Normalized','Position',[0.05 0.05 0.7 0.75],'BackgroundColor','white','BorderType','line','BorderWidth',2,'BorderColor','k');
    
    %table note
    table_note = uicontrol('Parent',fig,'Style','text','String',"Hover over table to see full text",'Units','normalized','Position',[0.05 0 0.7 0.048],'FontSize',12,'Visible','off','HorizontalAlignment','left');

    %instructions to add spredsheet
    table_instruction_text = uicontrol('Parent',table_panel,'Style','text','String','Add a speadsheet of the trials to score.','BackgroundColor','white','FontSize',24,'Units','Normalized','Position',[0.1 0.45 0.8 0.25]);
    
    %next button
    next_button = uicontrol(fig,'unit','normalized','style','pushbutton','string','Next','position',[0.8 0.1 0.15 0.1],'FontSize',18);    

    %upload button
    upload_table_button = uicontrol('Parent',table_panel,'Units','Normalized','style','pushbutton','string','Upload file','position',[0.375 0.33 0.25 0.13],'FontSize',19);
    upload_table_button.Callback = {@score_addTable,fig,table_panel,table_note,delete_button,next_button,settings};

end

function score_addTable(~,~,fig,table_panel,table_note,delete_button,next_button,settings)
    [score_files_table_file_name, score_files_table_path] = uigetfile('*.xlsx','Select the spreadsheet of files to score', 'MultiSelect', 'off');
    if any([score_files_table_file_name == 0, score_files_table_path == 0])
        %the file name and/or path is empty
        uialert(fig,"Error: No file selected.","Error")
    else
        %make text and button invisible, essentially replaced by table.
        %invisible instead of deleted so that it can be reactivated if
        %table is deleted
        for i = 1:length(table_panel.Children)
            table_panel.Children(i).Visible = 'off';
        end
        try
            file_data_table = readtable([score_files_table_path filesep score_files_table_file_name]);
            ui_file_table = uitable(table_panel,'Data',table(file_data_table.video_filepath),'ColumnEditable',false,'Units','normalized','Position',[0 0 1 1],'FontSize',16,'Tag','score_file_select_table');
            guidata(fig,file_data_table);
    
            %change column names on uitable (file_data_table keeps original
            %names)
            %not able to increase text size of column names, could cover with a
            %label but for now just leaving the text size small
            ui_file_table.ColumnName = {'Video'};
    
            %table styling
            sLeftClip = uistyle("HorizontalClipping","left");
            addStyle(ui_file_table,sLeftClip);
    
            sCenterAlignment = uistyle("HorizontalAlignment","center");
            addStyle(ui_file_table,sCenterAlignment,"column",1);
    
            figure(fig);
    
            %tablenote
            table_note.Visible = 'on';
    
            %delete button
            delete_button.Callback = {@deleteTable,table_panel,ui_file_table,delete_button};
            delete_button.Visible = 'on';
    
            %next button callback
            next_button.Callback = {@score_nextScreen,fig,settings};
        catch
            uialert(fig,'Error with spreadsheet. Please delete the table, fix the spreadsheet, and reupload.',"Error")
        end
    end
    
end

% function deleteTable(~,~,table_panel,ui_file_table,delete_button)
%     %delete ui_file_table
%     delete(ui_file_table)
% 
%     %make text and button visible again
%     for i = 1:length(table_panel.Children)
%         table_panel.Children(i).Visible = 'on';
%     end
% 
%     %make delete button and edit button invisible again
%     delete_button.Visible = 'off';
% end

function score_nextScreen(~,~,fig,settings)
    file_uitable = findall(0,'Type','uitable','Tag','score_file_select_table');
    file_table = file_uitable.Data;
    file_table.Properties.VariableNames{1} = 'video_filepath'; %not sure if this is necessary
    file_error = false;
    errors = [];

    for i = 1:height(file_table)
        %check video works with matlab
        try 
            video_filepath = file_table.video_filepath{i};
            VideoReader(video_filepath);
        catch ME
            file_error = true;
            errors = [errors; {[newline video_filepath newline ME.message]}];
        end
    end

    if ~file_error
        %randomize list
        new_order = randperm(height(file_table));
        file_table = file_table(new_order,:);

        results_spreadsheet_name = score_createResultsSpreadsheet(file_table,settings);
        settings.results_spreadsheet = results_spreadsheet_name;
        close(fig);
        scoreFigure(file_table,settings);
    else %alert if there are errors
        uialert(fig,['Error with: '; errors; {[newline 'Please delete the table, fix the spreadsheet, and reupload.']}],"Error")

    end

end

function results_spreadsheet_name = score_createResultsSpreadsheet(file_table,settings)
    %create table
    today_date = string(datetime("today"));
    num_trials = height(file_table);
    date = repelem(today_date,num_trials)';
    scorer_name = repelem(string(settings.scorer_name),num_trials)';
    %extract video names
    pattern = asManyOfPattern(wildcardPattern + filesep);
    video_names = extractAfter(file_table.video_filepath,pattern);
    data_table = table(date,scorer_name,video_names);
    data_table.immobility_full = zeros(num_trials,1);
    data_table.immobility_after_2_min = zeros(num_trials,1);
    data_table.video_filepath = file_table.video_filepath;
    data_table.score_filepath = repmat("not scored",num_trials,1);

    %create excelsheet and file paths
    if strcmp(settings.results_filepath,"Select Filepath")
        results_filepath = fileparts(file_table.video_filepath{1}); %folder of first video in list
    else
        results_filepath = settings.results_filepath;
    end

    results_spreadsheet_name = append(results_filepath,filesep,'Results_score_',settings.scorer_name,'.xlsx');
    if exist(results_spreadsheet_name,"file")
        results_spreadsheet_name = append(results_filepath,filesep,'Results_score_',settings.scorer_name,'_',string(datetime("now","Format","uuuu-MM-dd_HHmmss")),'.xlsx');
    end
    writetable(data_table,results_spreadsheet_name,'WriteMode','append','AutoFitWidth',false);
end

%% scoreFigure functions

function [GUI_fig, videoPanel, play_button, next_button, button_group, clip_counter, start_text] = scoreFigure(file_table,settings)
    %create new fig
    GUI_fig_pos = [400 678 800 500];
    GUI_fig = uifigure('Name', 'TST Rescore', 'position', GUI_fig_pos, 'MenuBar', 'none','Tag','video_scoring_figure','Resize','off');
    movegui(GUI_fig,'center');
    GUI_fig.UserData = struct("video_file_path",file_table.video_filepath{1},"mark_time",0);
    
    %create video and button panels
    videoPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.3 0.5 0.5], 'BorderWidth',2,'BorderColor','k','Tag','video_display_panel');
    textPanel = uipanel('Parent',GUI_fig,'Units','Normalized','Position',[0.55 0.25 0.4 0.6],'BorderWidth',0);
    buttonPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.05 0.5 0.2], 'BorderWidth', 0);
    
    %create axis
    video_axis = axes('position', [0 0 1 1], 'Parent', videoPanel,'Tag','video_display_axis');
    video_axis.XTick = [];
    video_axis.YTick = [];
    video_axis.XColor = [1 1 1];
    video_axis.YColor = [1 1 1];
    
    %create title
    title_position = [0.3 0.87 0.4 0.1];
    uicontrol('style', 'text', 'String', 'Mobility Analysis', 'FontSize', 30, 'Units', 'Normalized', 'Parent', GUI_fig, 'Position', title_position, 'BackgroundColor', GUI_fig.Color);
    
    %start text
    start_text_string = 'Press the start button.';
    start_text_pos = [0.25 0.25 0.5 0.5];
    start_text = uicontrol('style', 'text', 'String', start_text_string, 'FontSize', 20, 'Units', 'Normalized', 'Parent', videoPanel, ...
        'Position', start_text_pos,'BackgroundColor',videoPanel.BackgroundColor,'Tag','start_instructions_text'); %'BackgroundColor', video_axis.XColor,
    
    %mobility definition text
    mobility_definition = settings.mobility_definition;
    immobility_definition = settings.immobility_definition;
    %format text
    for i = 1:height(mobility_definition)
        mobility_definition(i) = append('-',mobility_definition(i));
    end
    for i = 1:height(immobility_definition)
        immobility_definition(i) = append('-',immobility_definition(i));
    end
    uicontrol('style', 'text', 'String', "Mobility:", 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.9 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
    uicontrol('style', 'text', 'String', mobility_definition, 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.5 0.9 0.4], 'HorizontalAlignment', 'left');
    uicontrol('style', 'text', 'String', "Immobility:", 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.4 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
    uicontrol('style', 'text', 'String', immobility_definition, 'FontSize', 15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.0 0.9 0.4], 'HorizontalAlignment', 'left');

    %keeping track of which videos are scored
    file_table.scored = zeros(height(file_table),1);
    video = file_table.video_filepath{1}; %start with first video

    %clip counter/video name
    number_of_videos = height(file_table);
    clip_counter_text = append("Video 1/",string(number_of_videos));
    if settings.show_video_name_checkbox
        [~, video_name] = fileparts(video);
        clip_counter_text = append(clip_counter_text,", ",video_name);
    end
    clip_counter_pos = [0.05 0.805 0.5 0.05];
    clip_counter = uicontrol('style', 'text', 'String', clip_counter_text, 'FontSize', 16, ...
        'Units', 'Normalized', 'Parent', GUI_fig, 'Position', clip_counter_pos, 'BackgroundColor', GUI_fig.Color,'HorizontalAlignment','left');

    %play button
    play_button = uicontrol(GUI_fig, 'unit', 'Normalized', 'style', 'pushbutton', 'string', 'Start', 'FontSize', 18, 'position', [0.6 0.1 0.15 0.1], 'tag', ...
    'playbutton');
    if settings.exclude_first_2_min_checkbox
        start_time = 120000;
    else
        start_time = 0;
    end
    play_button.Callback = {@playVideo,video,start_time,0,0,settings};

    %mobility and immobility switch
    mobility_switch_position = [175 70 50 25];
    mobility_switch = uiswitch(buttonPanel,'slider','Items',{'Mobile','Immobile'},'FontSize',20,'Orientation','horizontal','Position',mobility_switch_position,'ValueChangedFcn',{@mobilityMark,GUI_fig,NaN});
    
    %next button
    next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontSize',18, ...
        'position', [0.8 0.1 0.15 0.1], 'tag', 'next_button');
    next_button.Callback = {@nextButton,file_table,play_button,clip_counter,mobility_switch,settings};

    %set results filepath if not specified
    if strcmp(settings.results_filepath,"Select Filepath")
        [video_filepath,~] = fileparts(video);
        settings.results_filepath = video_filepath;
    end
end

function mobilityMark(mobility_switch,~,GUI_fig,scoring_table)
    mark_time = guidata(GUI_fig);
    mark_time = datetime(0,0,0,0,0,mark_time,"Format","mm:ss.SS");
    if ~istable(scoring_table)
        %create scoring table
        scoring_table = table('Size',[0,2],'VariableTypes',{'datetime','datetime'},'VariableNames',{'Interval','Time'});
    end
    scoring_table = [scoring_table;{NaT,mark_time}];
    mobility_switch.ValueChangedFcn{3} = scoring_table;
end

function nextButton(next_button,~,file_table,play_button,clip_counter,mobility_switch,settings)
    %check for folder
    current_video = play_button.Callback{2};
    [current_video_filepath,current_video_name] = fileparts(current_video);
    scoring_folder = append(current_video_filepath,filesep,current_video_name);
    if exist(scoring_folder,"dir")
        %folder already exists
    else 
        %make folder
        mkdir(scoring_folder)
    end
    
    %get scoring table with marks
    try
        scoring_table = mobility_switch.ValueChangedFcn{3};
        final_mark = guidata(next_button.Parent); 
        final_mark = datetime(0,0,0,0,0,final_mark,"Format","mm:ss.SS");
        scoring_table = [scoring_table;{NaT,final_mark}];
        scoring_table.Time = datetime(scoring_table.Time,"Format","mm:ss.SS");
        scoring_table.Total_sec = (minute(scoring_table.Time)*60) + second(scoring_table.Time);
        first_interval = scoring_table.Time(1) - datetime(0,0,0,"Format","mm:ss.SS");
        interval = [first_interval; diff(scoring_table.Time)];
        interval = interval + datetime(0,0,0,"Format","mm:ss.SS"); %changes from duration to datetime
        scoring_table.Interval = interval;
    catch %If table is empty, trying to convert to datetime will throw an error. This happens if the user presses next without marking any marks.
        scoring_table = table(NaT,0,0,'VariableNames',["Time","Total_sec","Interval"]);
    end

    %Write scoring table to spreadsheet (always a new one)
    spreadsheet_name = append(current_video_name,"_score_",settings.scorer_name,'.xlsx');
    if exist(append(scoring_folder,filesep,spreadsheet_name),"file")
        spreadsheet_name = append(current_video_name,"_score_",settings.scorer_name,string(datetime("now","Format","uuuuMMdd'_'HHmmss")),'.xlsx');
    end
    scoring_table_file = append(scoring_folder,filesep,spreadsheet_name);
    writetable(scoring_table,scoring_table_file);
    [full_im_time1,partial_im_time1] = calculateImmobility(scoring_table);
    
    %Write immobility score to results table
    immobility_results_table = readtable(settings.results_spreadsheet);
    just_scored_video = find(file_table.scored == 0,1);
    row = just_scored_video;

    immobility_results_table.immobility_full(row) = full_im_time1;
    immobility_results_table.immobility_after_2_min(row) = partial_im_time1;
    immobility_results_table.score_filepath(row) = {scoring_table_file(1)};
    
    writetable(immobility_results_table,settings.results_spreadsheet,"WriteMode","overwrite"); 

    %Generate timeline and save as png
    marks1 = scoring_table.Total_sec.';
    marks1 = marks1(:,1:length(marks1) - 1);
    scores.full_im_time1 = full_im_time1;
    scores.partial_im_time1 = partial_im_time1;

    try %if the user doesn't make any marks generating a scoreing timeline will throw an error
        scoring_timeline_fig = generateScoringTimeline(0,current_video_name,marks1,NaN,NaN,scores);
        figure_name = append(scoring_folder,filesep,current_video_name,'.png');
        saveas(scoring_timeline_fig,figure_name)
    catch
        msgbox('Error generating score timeline.','Error');
    end

    %find first row of file_table where scored variable is zero
    not_scored = find(file_table.scored == 0);
    file_table.scored(not_scored(1)) = 1;
    %next button call back new file_table
    next_button.Callback = {@nextButton,file_table,play_button,clip_counter,mobility_switch,settings};
    try
        %get the next unscored video and set it to play_button callback
        video = file_table.video_filepath{not_scored(2)};
        if settings.exclude_first_2_min_checkbox
            start_time = 120000;
        else
            start_time = 0;
        end
        play_button.Callback = {@playVideo,video,start_time,0,play_button,settings};
        %need to also change the video that is actually playing
        play_button.String = 'Start';
        %change mobility switch to mobile
        mobility_switch.Value = "Mobile";
        %update video count text
        clip_counter_text = append("Video ",string(not_scored(2)),"/",string(height(file_table)));
        if settings.show_video_name_checkbox
            [~, video_name] = fileparts(video);
            clip_counter_text = append(clip_counter_text,", ",video_name);
        end
        clip_counter.String = clip_counter_text;
        mobility_switch.ValueChangedFcn{3} = NaN;
    catch
        %scored all videos, alert that the user is done and where to find the results and close the
        %program
        uialert(next_button.Parent,['Finished scoring all videos. Results saved at ' settings.results_filepath '.'],'Scoring Complete','Icon','success')
    end
end
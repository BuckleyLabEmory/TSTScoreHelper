clear

% Constants
mobility_definition_text = ["Tail climbing attempts";"Running movement with all four feet";"Jolting and twitching movments"];
immobility_definition_text = ["Hanging without moving";"Paddling with only two feet";"Pendulum swinging from mouse's momentum"];
settings = struct('results_filepath',"Select Filepath",...
    'show_video_time_checkbox',1,...
    'show_video_name_checkbox',0,...
    'exclude_first_2_min_checkbox',0,...
    'disagreement_length_minimum',0.5,...
    'primary_scorer',"Scorer 1",...
    'starting_mobility_status',1,...
    'mobility_definition',mobility_definition_text,...
    'immobility_definition',immobility_definition_text);
% Initiate GUI
createStartingGUI(settings)

%% Functions
function createStartingGUI(settings)
    try
        GUI_fig_pos = [0.5 0.5 0.5 0.5];
        %create new fig
        GUI_fig = uifigure('Name','TSTScoreHelper','Position',GUI_fig_pos,'Units','Normalized','MenuBar','none','tag','start_screen_fig','Resize','off','NumberTitle','off','AutoResizeChildren','off');
        GUI_fig.Position = GUI_fig_pos;
        movegui(GUI_fig,'center');
    
        %create title
        titlePosition = [0.15 0.6 0.7 0.3];
        title_uicontrol = uicontrol('style','text','String','What would you like to do?','FontUnits','Normalized','FontSize',0.25,'Parent',GUI_fig,'Units','Normalized','Position',titlePosition,'BackgroundColor',GUI_fig.Color);
        
        %functionality radio buttons
        functionality_button_group = uibuttongroup(GUI_fig,'Units','Normalized','Position', [0.34 0.47 0.32 0.2]);
        info_symbol = char(9432);
        score_button = uicontrol(functionality_button_group, 'Units', 'Normalized', 'style', 'radiobutton', 'string', ['Score entire videos  ' info_symbol], 'FontUnits', 'Normalized', 'FontSize', 0.6, 'position', ...
            [0.05 0.56 0.9 0.3], 'BackgroundColor', GUI_fig.Color);
        score_button.Tooltip = sprintf('Watch the full TST video and mark\nwhen the subject is mobile and immobile');
        rescore_button = uicontrol(functionality_button_group, 'unit', 'normalized', 'style', 'radiobutton', 'string', ['Rescore videos  ' info_symbol], 'FontUnits', 'Normalized', 'FontSize', 0.6, 'position', ...
            [0.05 0.13 0.9 0.3], 'BackgroundColor', GUI_fig.Color);
        rescore_button.Tooltip = sprintf('Rescore segments that previous scorers disagreed on');
        score_button.Value = 0;
        
        %scorer name textbox and label
        name_textbox = uicontrol(GUI_fig,'unit','normalized','style','edit','position',[0.3 0.25 0.4 0.1],'FontUnits','Normalized','FontSize',0.5);
        name_textbox_label = uicontrol('style', 'text', 'String', 'Scorer Name: ', 'FontUnits', 'Normalized', 'FontSize', 0.4, 'Parent', GUI_fig, ...
            'Units', 'Normalized', 'Position', [0.1 0.23 0.2 0.1], 'BackgroundColor', GUI_fig.Color);
    
        %settings button
        settings_button = uicontrol(GUI_fig,'Style','togglebutton','String','Settings','Units','Normalized','Position',[0.86 0.89 0.115 0.075],'FontUnits','Normalized','FontSize',0.5);
        settings_button.Callback = {@openSettings,settings_button};
        settings_button.UserData = settings;
        
        %start screen next button
        start_screen_next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontUnits','Normalized','FontSize',0.5, ...
            'position', [0.8 0.1 0.15 0.1], 'tag', 'start_screen_next_button', 'KeyReleaseFcn', 'a');
        start_screen_next_button.Callback = {@starting_screen_completed, score_button, rescore_button, name_textbox,settings_button};
    catch exception
        errordlg(["Error initiating GUI. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],'Error');
    end
end

function starting_screen_completed(~, ~, score_button, rescore_button, name_textbox, settings_button)
    try
        settings = settings_button.UserData;
        score_value = score_button.Value;
        rescore_value = rescore_button.Value;
        scorer_name = name_textbox.String;
        settings.scorer_name = scorer_name;
        if (score_value == 0) && (rescore_value == 0) && strcmp(scorer_name,"")
            %need to enter what scoring and name
            score_and_name_error = msgbox('Error: Please select a scoring option and enter your name.','Error');
        elseif (score_value == 0) && (rescore_value == 0)
            score_error = msgbox('Error: Please select a scoring option.','Error');
        elseif strcmp(scorer_name,"")
            name_error = msgbox('Error: Please enter your name.','Error');
        else
            close(findall(0,'Type','figure','tag', 'start_screen_fig'));
            if score_value == 1
                scoreTable(settings);
            else
                rescoreTable(settings);
            end
        end
    catch exception
        errordlg(["Error saving input."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function openSettings(~,~,settings_button)
    try
        settings = settings_button.UserData;
        length = 0.5;
        height = 0.5;
        %open settings fig
        settings_fig = uifigure('Name','TSTScoreHelper','Units','normalized','MenuBar','none','tag','settings_fig','Resize','off','NumberTitle','off','AutoResizeChildren','off');
        settings_fig.Position = [0.5,0.5,length,height];
        movegui(settings_fig,'center');
    
        %settings section labels
        program_settings_label = uicontrol(settings_fig,"Style","Text","String","Program Settings","FontUnits","normalized","FontSize",0.6,"Units","normalized","Position",[0.05 0.85 0.4 0.1],'HorizontalAlignment','left');
        display_settings_label = uicontrol(settings_fig,"Style","Text","String","Display Settings","FontUnits","normalized","FontSize",0.6,"Units","normalized","Position",[0.55 0.85 0.4 0.1],'HorizontalAlignment','left');
    
        %save location
        save_location_title = uicontrol("Parent",settings_fig,"Style","Text","String","Results Save Filepath","Units","normalized","Position",[0.075 0.8 0.35 0.05],"FontUnits","normalized","FontSize",0.6,"HorizontalAlignment","left"); 
        save_results_filepath_button = uicontrol("Parent",settings_fig,"Style","pushbutton","String",settings.results_filepath,"Units","normalized","Position",[0.1 0.75 0.2 0.05],"FontUnits","normalized","FontSize",0.6,"HorizontalAlignment","right");
        save_results_filepath_button.Callback = {@select_filepath,settings_fig};
        %tooltip
        save_results_filepath_button.Tooltip = "File path where the results spreadsheet will be saved.";
    
        %disagreement length minumum
        disagreement_length_minimum_text = uicontrol("Parent",settings_fig,"Style","text","String","Minimum Disagreement Length","FontUnits","normalized","FontSize",0.6,"Units","normalized","Position",[0.075 0.7 0.375 0.05],"HorizontalAlignment","left");
        monitor_size_pixels = get(groot,"ScreenSize");
        disagreement_length_minimum_spinner = uispinner("Parent",settings_fig,"Value",settings.disagreement_length_minimum,"Limits",[0,Inf],"Step",0.1,"ValueDisplayFormat","%.01f s","Position",[(0.1*monitor_size_pixels(3)*length) (0.655*monitor_size_pixels(4)*height) (0.1*monitor_size_pixels(3)*length) (0.045*monitor_size_pixels(4)*height)],"FontSize",12);
        disagreement_length_minimum_spinner.Tooltip = "Set the minimum time length that disagreements must be to scored. Only applies to rescore function.";
    
        %primary scorer
        primary_scorer = settings.primary_scorer;
        primary_scorer_text = uicontrol("Parent",settings_fig,"Style","text","String","Primary Scorer","FontUnits","normalized","FontSize",0.6,"Units","normalized","Position",[0.075 0.6 0.3 0.05],"HorizontalAlignment","left");
        primary_scorer_ui_button_group = uibuttongroup("Parent",settings_fig,"Units","normalized","Position",[0.1 0.45 0.2 0.15]);
        scorer1_radiobutton = uicontrol(primary_scorer_ui_button_group,"Style","radiobutton","String","Scorer 1","FontUnits","normalized","FontSize",0.7,"Units","normalized","Position",[0.05 0.56 0.9 0.3],"HorizontalAlignment","left");
        scorer2_radiobutton = uicontrol(primary_scorer_ui_button_group,"Style","radiobutton","String","Scorer 2","FontUnits","normalized","FontSize",0.7,"Units","normalized","Position",[0.05 0.13 0.9 0.3],"HorizontalAlignment","left");
        if strcmp(primary_scorer,"Scorer 1")
            scorer1_radiobutton.Value = 1;
        else
            scorer2_radiobutton.Value = 1;
        end
        %tooltip
        primary_scorer_ui_button_group.Tooltip = "Select which scorer's data will be used to fill in portions that are not rescored. Only applies to Rescore function";
    
        %starting mobility status
        starting_mobility_status = settings.starting_mobility_status;
        starting_mobility_status_text = uicontrol("Parent",settings_fig,"Style","text","String","Starting Mobility Status","FontUnits","normalized","FontSize",0.6,"Units","normalized","Position",[0.075 0.4 0.3 0.05],"HorizontalAlignment","left");
        starting_mobility_status_ui_button_group = uibuttongroup("Parent",settings_fig,"Units","normalized","Position",[0.1 0.25 0.2 0.15]);
        immobile_radiobutton = uicontrol(starting_mobility_status_ui_button_group,"Style","radiobutton","String","Immobile","FontUnits","normalized","FontSize",0.7,"Units","normalized","Position",[0.05 0.56 0.9 0.3],"HorizontalAlignment","left");
        mobile_radiobutton = uicontrol(starting_mobility_status_ui_button_group,"Style","radiobutton","String","Mobile","FontUnits","normalized","FontSize",0.7,"Units","normalized","Position",[0.05 0.13 0.9 0.3],"HorizontalAlignment","left");
        if starting_mobility_status == 0
            immobile_radiobutton.Value = 1;
        else 
            mobile_radiobutton.Value = 1;
        end
        starting_mobility_status_ui_button_group.Tooltip = "Set the starting mobility state of the subject. Note that switching the starting mobility state between scoring and rescoring will result in swapped mobility and immobility.";
    
        %show video time (checkbox)
        show_video_time_checkbox = uicontrol("Parent",settings_fig,"Style","checkbox","String","Display Video Time","Units","normalized","Position",[0.575 0.8 0.35 0.05],"FontUnits","normalized","FontSize",0.6,"Value",settings.show_video_time_checkbox);
        %tooltip
        show_video_time_checkbox.Tooltip = "";
    
        %show video name (checkbox)
        show_video_name_checkbox = uicontrol("Parent",settings_fig,"Style","checkbox","String","Display Video Name","Units","normalized","Position",[0.575 0.75 0.35 0.05],"FontUnits","normalized","FontSize",0.6,"Value",settings.show_video_name_checkbox);
        %tooltip
    
        %score only after 2 minutes (checkbox)
        exclude_first_2_min_checkbox = uicontrol("Parent",settings_fig,"Style","checkbox","String","Exclude First 2 Minutes","Units","normalized","Position",[0.575 0.7 0.35 0.05],"FontUnits","normalized","FontSize",0.6,"Value",settings.exclude_first_2_min_checkbox);
        %tooltip
    
        %mobility definition
        mobility_def_title = uicontrol("Parent",settings_fig,"Style","text","String","Mobility Definition:","Units","normalized","Position",[0.575 0.65 0.375 0.05],"FontUnits","normalized","FontSize",0.6,"HorizontalAlignment","left");
        mobility_def_textbox = uitextarea("Parent",settings_fig,"Value",settings.mobility_definition,"WordWrap","on","Position",[(0.6*monitor_size_pixels(3)*length) (0.45*monitor_size_pixels(4)*height) (0.35*monitor_size_pixels(3)*length) (0.2*monitor_size_pixels(4)*height)],"FontSize",14);
        %tooltip
        
        %immobility defition
        immobility_def_title = uicontrol("Parent",settings_fig,"Style","text","String","Immobility Definition:","Units","normalized","Position",[0.575 0.39 0.375 0.05],"FontUnits","normalized","FontSize",0.6,"HorizontalAlignment","left");
        immobility_def_textbox = uitextarea("Parent",settings_fig,"Value",settings.immobility_definition,"WordWrap","on","Position",[(0.6*monitor_size_pixels(3)*length) (0.19*monitor_size_pixels(4)*height) (0.35*monitor_size_pixels(3)*length) (0.2*monitor_size_pixels(4)*height)],"FontSize",14);
        %tooltip
    
        save_settings_button = uicontrol(settings_fig,"Style","pushbutton","String","Save","Units","normalized","Position",[.35 0.02 0.3 0.08],"FontUnits","normalized","FontSize",0.6);
        save_settings_button.Callback = {@saveSettings,save_results_filepath_button,show_video_time_checkbox,show_video_name_checkbox,exclude_first_2_min_checkbox,disagreement_length_minimum_spinner,primary_scorer_ui_button_group,starting_mobility_status_ui_button_group,mobility_def_textbox,immobility_def_textbox,settings,settings_button};
    catch exception
        errordlg(["Error opening settings window."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function saveSettings(~,~,save_results_filepath_button,show_video_time_checkbox,show_video_name_checkbox,exclude_first_2_min_checkbox,disagreement_length_minimum_spinner,primary_scorer_button,starting_mobility_status_button,mobility_def_textbox,immobility_def_textbox,settings,settings_button)
    try
        %save settings as settings array
        settings.results_filepath = save_results_filepath_button.String;
        settings.show_video_time_checkbox = show_video_time_checkbox.Value;
        settings.show_video_name_checkbox = show_video_name_checkbox.Value;
        settings.exclude_first_2_min_checkbox = exclude_first_2_min_checkbox.Value;
        settings.disagreement_length_minimum = disagreement_length_minimum_spinner.Value;
        for i = 1:length(primary_scorer_button.Children)
            if primary_scorer_button.Children(i).Value
                settings.primary_scorer = primary_scorer_button.Children(i).String;
            end
        end
        for i = 1:length(starting_mobility_status_button.Children)
            if starting_mobility_status_button.Children(i).Value
                if strcmp(starting_mobility_status_button.Children(i).String,'Mobile')
                    settings.starting_mobility_status = 1;
                else
                    settings.starting_mobility_status = 0;
                end
            end
        end
        settings.mobility_definition = mobility_def_textbox.Value;
        settings.immobility_definition = immobility_def_textbox.Value;
        settings_button.UserData = settings;
    
        settings_button.Callback{2} = settings_button;
        close(save_results_filepath_button.Parent);
        focus(settings_button.Parent);
    catch exception
        errordlg(["Error saving settings."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function select_filepath(save_results_filepath_button,~,settings_fig)
    try
        save_filepath = uigetdir();
        figure(settings_fig)
        movegui(save_results_filepath_button.Parent,"center");
        if save_filepath == 0 %user closed file select without selecting
            save_filepath = "Select Filepath";
        end
        save_results_filepath_button.String = save_filepath;
        save_results_filepath_button.Tooltip = save_filepath;
    catch exception
        errordlg(["Error saving filepath selection."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function [full_im_time,partial_im_time] = calculateImmobility(score_table,frame_rate)
    try
        full_im_time = sum(score_table.Interval_sec(score_table.Mobility_state == 0));
        %calculate partial_im_time
        rows_post_2_min = find(score_table.Mark_sec >= 120);
        first_row_post_2_min = rows_post_2_min(1);
        score_table_after_2_min = score_table((first_row_post_2_min):end,:);
        score_table_after_2_min_new_row_1 = table(NaN,round(120*frame_rate,0,"decimals"),round(120*frame_rate,0,"decimals"),120,120,'VariableNames',["Mobility_state","Mark_frames","Interval_frames","Mark_sec","Interval_sec"]);
        score_table_after_2_min = [score_table_after_2_min_new_row_1; score_table_after_2_min];
        score_table_after_2_min.Interval_frames(2) = score_table_after_2_min.Mark_frames(2) - score_table_after_2_min.Mark_frames(1);
        score_table_after_2_min.Interval_sec(2) = score_table_after_2_min.Mark_sec(2) - score_table_after_2_min.Mark_sec(1);
        partial_im_time = sum(score_table_after_2_min.Interval_sec(score_table_after_2_min.Mobility_state == 0));
    catch exception
        errordlg(["Error calculating immobility time. Setting immobility time to 0."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        partial_im_time = 0;
        full_im_time = 0;
    end
end

function [differences,marks1,marks2] = findScoreDifferences(scorer_1_file_path,scorer_2_file_path,video_file_path,settings)
    try
        v = VideoReader(video_file_path);
        %retrieve data
        stats1 = readtable(scorer_1_file_path{1}, 'VariableNamingRule', 'preserve');
        stats2 = readtable(scorer_2_file_path{1}, 'VariableNamingRule', 'preserve');
        
        marks1 = transpose(stats1.Mark_frames);
        marks2 = transpose(stats2.Mark_frames);
    
        %generate frame-index vector of mobility status; mobility = 1, immobility = 0
        mobility1 = [];
        for i = 1:height(stats1)
            if stats1.Mobility_state(i)
                new_mobility_vector = ones(stats1.Interval_frames(i),1);
            else
                new_mobility_vector = zeros(stats1.Interval_frames(i),1);
            end
            mobility1 = [mobility1; new_mobility_vector];
        end
    
        %generate frame-index vector of mobility status; mobility = 1, immobility = 0
        mobility2 = [];
        for i = 1:height(stats2)
            if stats2.Mobility_state(i)
                new_mobility_vector = ones(stats2.Interval_frames(i),1);
            else
                new_mobility_vector = zeros(stats2.Interval_frames(i),1);
            end
            mobility2 = [mobility2; new_mobility_vector];
        end
    
        try
            mobility1_original = mobility1;
            mobility2_original = mobility2;
            %xcorr to calculate lag
            [c,lag] = xcorr(mobility1, mobility2);
            [~,I] = max(abs(c));
            delay = lag(I);
        
            if delay > 0
                mobility2_adjusted = mobility2((delay+1):end);
                padding = repmat(mobility2(1),delay,1);
                mobility2 = [padding; mobility2_adjusted];
                marks2 = marks2 + delay;
            else
                mobility1_adjusted = mobility1(1:(end+delay));
                padding = repmat(mobility1(1),abs(delay),1);
                mobility1 = [padding; mobility1_adjusted];
                marks1 = marks2 - delay;
            end
        catch
            mobility1 = mobility1_original;
            mobility2 = mobility2_original;
        end
    
        %Finding and correcting differences
        combined_mob = mobility1 + mobility2;
    
        disagreements = find(combined_mob == 1);
        changes = find([diff(disagreements); inf] > 1); %finds where there are runs of consecutive same numbers, returns an array of
        %the indexes of the disagreements array where the runs ends
        starts = [disagreements(1); disagreements(changes(1:end-1)+1)];
        ends = disagreements(changes);
        differences = table(starts, ends, ends-starts, zeros(length(starts),1), zeros(length(starts),1));
        differences.Properties.VariableNames = ["Starts", "Ends", "Length_in_Frames", "Score", "Scored"];
        %take out clips before 2 minutes if setting is selected
        if settings.exclude_first_2_min_checkbox
            frame_2min = v.FrameRate*60*2;
            clips_before_2_min = find(differences.Ends(:) <= frame_2min);
            differences(clips_before_2_min,:) = [];
            if differences.Starts(1) <= frame_2min
                differences.Starts(1) = frame_2min;
                differences.Length_in_Frames(1) = differences.Ends(1) - differences.Starts(1);
            end
        end
        %mark clips that are too short to be scored
        clips_too_short = find(differences.Length_in_Frames(:) <= (settings.disagreement_length_minimum*v.FrameRate));
        differences.Scored(clips_too_short) = -1;
    catch exception
        errordlg(["Error analyzing scores. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function scoring_timeline_figure = generateScoringTimeline(rescoring,video_name,scoring_table1,scoring_table2,rescoring_table,scores,settings)
    try
        scoring_timeline_figure = figure('Visible','off','Units','centimeters','Position',[0 0 17.6 8.5]);
        hold on
        immobile_color = "black";
        mobile_color = "#D0D0D0";
    
        if ~rescoring
            %only plotting the one scorer
            ylim([0 1])
            xlim([0 max(scoring_table1.Mark_sec)])
            title(video_name,"FontUnits","normalized","FontSize",0.125)
            xlabel('Video Time (seconds)','FontUnits','normalized','FontSize',0.1)
            yticks(0.5)
            yticklabels("Score 1")
            
            for i = 1:height(scoring_table1)
                if scoring_table1.Mobility_state(i) == 1
                    color = mobile_color;
                else
                    color = immobile_color;
                end
                plot([(scoring_table1.Mark_sec(i)-scoring_table1.Interval_sec(i)); scoring_table1.Mark_sec(i)], [0.5; 0.5], 'Color', color, 'LineWidth', 20)
            end
            
            %add padding around graph
            axes_row = isgraphics(scoring_timeline_figure.Children,'axes');
            timeline_axis = scoring_timeline_figure.Children(axes_row);
            pos = get(timeline_axis,'Position');
            timeline_axis.Position(2) = 1.75*pos(2);
            timeline_axis.Position(3) = 0.675;
            timeline_axis.Position(4) = 0.8*pos(4);
    
            %add immobility value labels with score
            %score.full_im_time1,partial_im_time1
            score1_text = strcat('T_f','=',num2str(round(scores.full_im_time1,0)),', T_p','=',num2str(round(scores.partial_im_time1,0)));
            annotation('textbox',[.806 .5 .1 .1],'String',score1_text,'EdgeColor','none','FontUnits','normalized','FontSize',0.05)
    
            %legend
            h(1) = patch(NaN,NaN,'k');
            h(1).FaceColor = immobile_color;
            h(1).EdgeColor = immobile_color;
            h(2) = patch(NaN,NaN,'k');
            h(2).FaceColor = mobile_color;
            h(2).EdgeColor = mobile_color;
            fig_legend = legend(h,{'Immobile',"Mobile"},'Location','none','Orientation','horizontal','Color','none','Box','off','FontSize',12);
            fig_legend.Position = [0.05 0.05 0.275 0.1];
    
        else
            %plotting both scorers and rescore
            ylim([0 2])
            xlim([0 max([scoring_table1.Mark_sec(end),scoring_table2.Mark_sec(end),rescoring_table.Mark_sec(end)])])
            title(video_name,"FontUnits","normalized","FontSize",0.125)
            xlabel('Time (Seconds)','FontUnits','normalized','FontSize',0.1)
            yticks([0.5 1 1.5])
            yticklabels({'Rescore','Score 1','Score 2'})
    
            %plot score 1
            for i = 1:height(scoring_table1)
                if scoring_table1.Mobility_state(i) == 1
                    color = mobile_color;
                else
                    color = immobile_color;
                end
                plot([(scoring_table1.Mark_sec(i)-scoring_table1.Interval_sec(i)); scoring_table1.Mark_sec(i)], [1; 1], 'Color', color, 'LineWidth', 20)
            end
    
            %plot score 2
            for i = 1:height(scoring_table2)
                if scoring_table2.Mobility_state(i) == 1
                    color = mobile_color; 
                else
                    color = immobile_color; 
                end
                plot([(scoring_table2.Mark_sec(i)-scoring_table2.Interval_sec(i)); scoring_table2.Mark_sec(i)], [1.5; 1.5], 'Color', color, 'LineWidth', 20)
            end
    
            %plot rescore
            for i = 1:height(rescoring_table)
                if rescoring_table.Mobility_state(i) == 1
                    color = mobile_color;
                else
                    color = immobile_color;
                end
                plot([(rescoring_table.Mark_sec(i)-rescoring_table.Interval_sec(i)); rescoring_table.Mark_sec(i)], [.5; .5], 'Color', color, 'LineWidth', 20)
            end
    
            
            %add padding around graph
            timeline_axis = scoring_timeline_figure.Children(1);
            pos = get(timeline_axis,'Position');
            timeline_axis.Position(2) = 1.75*pos(2);
            timeline_axis.Position(3) = 0.675;
            timeline_axis.Position(4) = 0.8*pos(4);
    
            %add immobility value labels with score
            %score.full_im_time1,partial_im_time1,full_im_time2,partial_im_time2,full_im_time_rescore,partial_im_time_rescore
            score1_text = strcat('T_f','=',num2str(round(scores.full_im_time1,0)),', T_p','=',num2str(round(scores.partial_im_time1,0)));
            score2_text = strcat('T_f','=',num2str(round(scores.full_im_time2,0)),', T_p','=',num2str(round(scores.partial_im_time2,0)));
            rescore_text = strcat('T_f','=',num2str(round(scores.full_im_time_rescore,0)),', T_p','=',num2str(round(scores.partial_im_time_rescore,0)));
            annotation('textbox',[.806 .64 .1 .1],'String',score1_text,'EdgeColor','none','FontUnits','normalized','FontSize',0.05)
            annotation('textbox',[.806 .5 .1 .1],'String',score2_text,'EdgeColor','none','FontUnits','normalized','FontSize',0.05)
            annotation('textbox',[.806 .36 .1 .1],'String',rescore_text,'EdgeColor','none','FontUnits','normalized','FontSize',0.05)
    
            %legend
            h(1) = patch(NaN,NaN,'k');
            h(1).FaceColor = immobile_color;
            h(1).EdgeColor = immobile_color;
            h(2) = patch(NaN,NaN,'k');
            h(2).FaceColor = mobile_color;
            h(2).EdgeColor = mobile_color;
            fig_legend = legend(h,{'Immobile',"Mobile"},'Location','none','Orientation','horizontal','Color','none','Box','off','FontSize',12);
            fig_legend.Position = [0.05 0.05 0.275 0.1];
        end
    catch exception
        errordlg(["Error generating timeline figure."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

%% playVideo functions

function playVideo(play_button,~, video, start_frame, end_frame, pause_frame, settings)
%This function plays the input video in the designated panel
    try
        %Determine what action is supposed to happen when button is pressed
        video_started_first_time = strcmp(play_button.String,'Start');
        video_paused = strcmp(play_button.String,'Pause');
        video_continue = strcmp(play_button.String,'Continue');
    
        video_fig = findall(0,'Type','figure','Tag','video_scoring_figure');
    
        v = VideoReader(video);
        if end_frame == 0
            end_frame = v.NumFrames;
        end

        if video_paused
            play_button.String = 'Continue';
            play_button.Callback{5} = guidata(video_fig);
            current_frame = guidata(video_fig);
        elseif video_continue
            play_button.String = 'Pause';
            current_frame = pause_frame;
        else
            %video_replay or video_started_first_time
            play_button.String = 'Pause';
            if (start_frame == 0) && (settings.exclude_first_2_min_checkbox)
                start_frame = round(v.FrameRate*120,0,"decimals"); %frame at 2 min = frame rate * 120 seconds
            end
            current_frame = start_frame;
            if video_started_first_time
                start_text = findall(0,'Type','uicontrol','Tag','start_instructions_text');
                set(start_text,'Visible','off')
        
                %get size of video
                video_width = v.Width;
                video_height = v.Height;
            
                video_panel_position = [0.05 0.3 0.5 0.5];
                GUI_fig_pos = video_fig.Position;
                monitor_size_pixels = get(groot,"ScreenSize");
    
                max_width = monitor_size_pixels(3)*GUI_fig_pos(3)*video_panel_position(3);
                max_height = monitor_size_pixels(4)*GUI_fig_pos(4)*video_panel_position(4);
    
                %assume width is the limiting dimension
                video_height_pixels = max_width*(video_height/video_width);
                if video_height_pixels > max_height
                    %height is the limiting dimension
                    video_width_pixels = max_height*(video_width/video_height);
                    video_height_pixels = max_height;
                else
                    %height isn't larger than max, dimensions are valid
                    video_width_pixels = max_width;
                end
                video_panel_width = video_width_pixels/(monitor_size_pixels(3)*GUI_fig_pos(3));
                video_panel_height = video_height_pixels/(monitor_size_pixels(4)*GUI_fig_pos(4));
                video_panel_left = ((0.5-video_panel_width)/2)+0.05;
                video_panel_bottom = ((0.5-video_panel_height)/2)+0.3;
                
                video_panel = findall(0,'Type','uipanel','Tag','video_display_panel');
                video_panel = video_panel(1);
                video_panel.Position = [video_panel_left video_panel_bottom video_panel_width video_panel_height];
        
                %create video timer
                if settings.show_video_time_checkbox
                    video_timer = findall(0,'Type','uicontrol','Tag','video_timer');
                    delete(video_timer)
    
                    end_time = end_frame/v.FrameRate;
                    start_time = start_frame/v.FrameRate;
                    video_length = round((end_time - start_time)/1000,1);
                    timer_text = append("0/",string(round(video_length))," s");
                    video_time_position = [0.075 0.225 0.2 0.05];
                    video_timer = uicontrol('Style','Text','String',timer_text,'FontUnits','normalized','FontSize',0.9,'Parent',video_fig,'Units','normalized','Position',video_time_position, ...
                        'BackgroundColor',video_fig(1).Color,'HorizontalAlignment','left','Tag','video_timer');
                end
    
            end
        end
    
        video_axis = findall(0,'Type','axes','Tag','video_display_axis');
        video_axis.Position = [0 0 1 1];
        video_axis.Interactions = [];
        loop_start_time = tic;
        loop_marks = [];
    
        while hasFrame(v) && (current_frame >= start_frame) && (current_frame <= end_frame) && strcmp(play_button.String,'Pause')
            video_axis.Position = [0 0 1 1];
            frame = read(v,current_frame);
            showFrame(video_axis, frame);
            video_axis.Toolbar.Visible = 'off';
            current_frame = current_frame + 1;
            %set current frame number to fig gui data so that it can be accessed by
            %the change in mobility mark function
            guidata(video_fig,current_frame);
            
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
            
            if settings.show_video_time_checkbox && strcmp(play_button.String,'Pause')
                if settings.exclude_first_2_min_checkbox
                    start_frame = round(v.FrameRate*120,0,"decimals");
                end
                %video/clip prograss bar
                video_timer = findall(0,'Type','uicontrol','Tag','video_timer');
                %delete all extra instances of video timer
                video_timer = video_timer(1);
                video_length = (end_frame - start_frame)/v.FrameRate;
                video_progress = (current_frame - start_frame)/v.FrameRate;
                if video_progress > video_length
                    video_progress = video_length;
                end
                timer_text = append(num2str(video_progress,"%.1f"),"/",num2str(video_length,"%.1f")," s");
                video_timer.String = timer_text;
            end
        end
        
        if current_frame >= end_frame
            %when video is over, button text changes to replay
            play_button.String = 'Replay';
        end

    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function showFrame(video_axis, frame) 
    try
        %based on function showFrameOnAxis function in 'Video in a Custom User Interface'
        checkFrame(frame);
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
            checkFrameSize(current_image, size(frame))
            try
                set(current_image,'cdata',frame); drawnow;
            catch
                %figure closed
                return
            end
        end
    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function checkFrame(frame) %from 'Video in a Custom User Interface'
    try
        % Validate input image
        validateattributes(frame, ...
        {'uint8', 'uint16', 'int16', 'double', 'single','logical'}, ...
        {'real','nonsparse'}, 'insertShape', 'I', 1)
    
        % Input image must be grayscale or truecolor RGB.
        errCond=(ndims(frame) >3) || ((size(frame,3) ~= 1) && (size(frame,3) ~=3));
        if (errCond)
            error('Input image must be grayscale or truecolor RGB');
        end
    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function frame = convertToUint8RGB(frame) %from 'Video in a Custom User Interface'
    try
        %Convert input data type to uint8
        if ~isa(class(frame), 'uint8')
            frame = im2uint8(frame);
        end
    
        %If the input is grayscale, turn it into an RGB image 'Video in a Custom User Interface'
        if (size(frame,3) ~= 3) %must be 2d
            frame = cat(3,frame, frame, frame);
        end
    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function checkFrameSize(current_image, frame_size)
    try
        % Check frame size
        prev_size = size(get(current_image, 'cdata'));
        if ~isequal(prev_size, frame_size)
            error('Frame size must remain the same');
        end
    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function displayImage(video_axis, frame)
    try
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
    catch exception
        errordlg(["Error playing video."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

%% Rescore functions

function [GUI_fig, videoPanel, play_button, next_button, clip_counter, start_text] = rescoreFigure(file_table,settings)
    try
        %create new fig
        GUI_fig_pos = [0.5 0.5 0.5 0.5];
        GUI_fig = uifigure('Name','TSTScoreHelper','Units','normalized','position',GUI_fig_pos,'MenuBar','none','Tag','video_scoring_figure','Resize','off','AutoResizeChildren','off');
        movegui(GUI_fig,'center');
        
        %create video and button panels
        videoPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.3 0.5 0.5], 'BorderWidth',2,'BorderColor','k','Tag','video_display_panel');
        textPanel = uipanel('Parent',GUI_fig,'Units','Normalized','Position',[0.55 0.25 0.4 0.6],'BorderWidth',0,'Tag','mob_def_text_panel');
        buttonPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.05 0.5 0.2], 'BorderWidth', 0,'Tag','scoring_buttons_panel');
        %[0.05 0.05 0.9 0.2]
        %create axis
        video_axis = axes('position', [0 0 0.99 0.99], 'Parent', videoPanel,'Tag','video_display_axis');
        video_axis.Toolbar.Visible = 'off';
        video_axis.XTick = [];
        video_axis.YTick = [];
        video_axis.XColor = [1 1 1];
        video_axis.YColor = [1 1 1];
        video_axis.Interactions = [];
        
        %create title
        title_position = [0.3 0.87 0.4 0.1];
        uicontrol('style', 'text', 'String', 'Mobility Analysis', 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', GUI_fig, 'Position', title_position, 'BackgroundColor', GUI_fig.Color);
        
        %start text
        start_text_string = 'Press the start button.';
        start_text_pos = [0.3 0.35 0.4 0.3];
        start_text = uicontrol('style', 'text', 'String', start_text_string, 'FontUnits', 'normalized', 'FontSize', 0.4, 'Units', 'Normalized', 'Parent', videoPanel, ...
            'Position',start_text_pos,'BackgroundColor',video_axis.XColor,'Tag','start_instructions_text');
        
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
        uicontrol('style', 'text', 'String', "Mobility:", 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.9 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
        uicontrol('style', 'text', 'String', mobility_definition, 'FontUnits', 'normalized', 'FontSize', 0.15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.5 0.9 0.4], 'HorizontalAlignment', 'left');
        uicontrol('style', 'text', 'String', "Immobility:", 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.4 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
        uicontrol('style', 'text', 'String', immobility_definition, 'FontUnits', 'normalized', 'FontSize', 0.15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.0 0.9 0.4], 'HorizontalAlignment', 'left');
    
        %keeping track of videos and clips that have been scored
        file_table.scored = zeros(height(file_table),1);
        video = file_table.video_filepath{1}; 
        [differences,marks1,marks2] = findScoreDifferences(file_table.score_1_filepath(1),file_table.score_2_filepath(1),video,settings);
        scorable_clips = find(differences.Scored ~= -1);
        first_clip = scorable_clips(1); %can't assume that first clip in differences is longer than disagreement_length_minimum so have to find rows that aren't excluded
    
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
        clip_counter = uicontrol('style', 'text', 'String', clip_counter_text, 'FontUnits', 'normalized', 'FontSize', 0.9, ...
            'Units', 'Normalized', 'Parent', GUI_fig, 'Position', clip_counter_pos, 'BackgroundColor', GUI_fig.Color,'HorizontalAlignment','left');
            
        %play button
        play_button = uicontrol(GUI_fig, 'unit', 'Normalized', 'style', 'pushbutton', 'string', 'Start', 'FontUnits', 'normalized', 'FontSize', 0.5, 'position', [0.6 0.1 0.15 0.1], 'Tag', ...
        'video_play_button');
        play_button.Callback = {@playVideo, video, differences.Starts(first_clip), differences.Ends(first_clip), 0, settings};
        play_button.UserData = file_table;
    
        %mobility and immobility switch
        monitor_size_pixels = get(groot,"ScreenSize");
        button_panel_position = buttonPanel.Position;
        mobility_switch_position = [(0.4*monitor_size_pixels(3)*button_panel_position(3)*GUI_fig_pos(3)) (0.35*monitor_size_pixels(4)*button_panel_position(4)*GUI_fig_pos(4)) (0.3*monitor_size_pixels(3)*button_panel_position(3)*GUI_fig_pos(3)) (0.2*monitor_size_pixels(4)*button_panel_position(4)*GUI_fig_pos(4))];
        mobility_switch = uiswitch(buttonPanel,'slider','Items',{'Mobile','Immobile'},'FontSize',20,'Orientation','horizontal','Position',mobility_switch_position);
        if settings.starting_mobility_status
            mobility_switch.Value = 'Mobile';
        else
            mobility_switch.Value = 'Immobile';
        end
    
        %next button
        next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontUnits','normalized','FontSize',0.5, ...
            'position', [0.8 0.1 0.15 0.1], 'tag', 'next_button');
        next_button.Callback = {@rescoreNext,mobility_switch,play_button,clip_counter,settings};
        scoring_data = struct("differences",differences,"marks1",marks1,"marks2",marks2);
        next_button.UserData = scoring_data;
    catch exception
        errordlg(["Error generating rescore window. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function next_button = rescoreNext(next_button,~,mobility_switch,play_button,clip_counter,settings)
    try
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
                [differences,marks1,marks2] = findScoreDifferences(file_table.score_1_filepath(next_video),file_table.score_2_filepath(next_video),video,settings);
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
                if settings.show_video_time_checkbox %this is only accessed every time the video changes, which is already updated
                    video_timer = findall(0,'Type','uicontrol','Tag','video_timer');
                    delete(video_timer)
                    %end_time = end_frame/v.FrameRate;
                    %start_time = start_frame/v.FrameRate;
                    %video_length = round((end_time - start_time)/1000,1);
                    %timer_text = append("0/",string(round(video_length))," s");
                    %video_time_position = [0.075 0.225 0.2 0.05];
                    %video_timer = uicontrol('Style','Text','String',timer_text,'FontUnits','normalized','FontSize',0.9,'Parent',video_fig,'Units','normalized','Position',video_time_position, ...
                        %'BackgroundColor',video_fig(1).Color,'HorizontalAlignment','left','Tag','video_timer');
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
    
            %update video timer text
            if settings.show_video_time_checkbox
                video_timer = findall(0,'Type','uicontrol','Tag','video_timer');
                if length(video_timer) >= 1
                    video_timer = video_timer(1);
                else
                    video_time_position = [0.075 0.225 0.2 0.05];
                    fig = next_button.Parent;
                    video_timer = uicontrol('Style','Text','String','','FontUnits','normalized','FontSize',0.9,'Parent',fig,'Units','normalized','Position',video_time_position, ...
                        'BackgroundColor',fig.Color,'HorizontalAlignment','left','Tag','video_timer');
                end
                v = VideoReader(play_button.Callback{2});
                video_length = (differences.Ends(next_clip) - differences.Starts(next_clip))/v.FrameRate;
                timer_text = append("0.0/",num2str(video_length,"%.1f")," s");
                video_timer.String = timer_text;
            end
        end
    catch exception
        errordlg(["Error continuing."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function saveResults(play_button,scoring_data,settings)
    try
        %check for folder
        differences = scoring_data.differences;
        marks1 = scoring_data.marks1;
        marks2 = scoring_data.marks2;
    
        %Check for/create folder
        current_video = play_button.Callback{2};
        [video_filepath,video_name] = fileparts(current_video);
        scoring_folder = append(video_filepath,filesep,video_name);
        if ~exist(scoring_folder,"dir")
            mkdir(scoring_folder)
        end
    
        v = VideoReader(current_video);
        frame_rate = v.FrameRate;
    
        %make scoring_table
        file_table = play_button.UserData;
        just_scored_video = find(file_table.scored == 0,1);
        
        score1_spreadsheet = readtable(file_table.score_1_filepath{just_scored_video(1)}, 'VariableNamingRule', 'preserve');
        score2_spreadsheet = readtable(file_table.score_2_filepath{just_scored_video(1)}, 'VariableNamingRule', 'preserve');
    
        if strcmp(settings.primary_scorer,"Scorer 1")
            primary_spreadsheet = score1_spreadsheet;
        else
            primary_spreadsheet = score2_spreadsheet;
        end
    
        %generate frame-index vector of mobility status; mobility = 1, immobility = 0
        mobility_vector = [];
        for i = 1:height(primary_spreadsheet)
            if primary_spreadsheet.Mobility_state(i)
                new_mobility_vector = ones(primary_spreadsheet.Interval_frames(i),1);
            else
                new_mobility_vector = zeros(primary_spreadsheet.Interval_frames(i),1);
            end
            mobility_vector = [mobility_vector; new_mobility_vector];
        end
    
        %edit differences decisions
        for i = 1:height(differences)
            if differences.Scored(i)
                mobility_vector(differences.Starts(i):differences.Ends(i)) = differences.Score(i);
            end
        end
    
        %create rescore spreadsheet
        marks_frames = find([diff(mobility_vector); inf] ~= 0);
        interval_frames = [marks_frames(1); diff(marks_frames)];
        marks_sec = marks_frames/frame_rate;
        interval_sec = [marks_sec(1); diff(marks_sec)];
        mobility_state = [];
        for i = 1:height(marks_frames)
            mobility_state = [mobility_state; mobility_vector(marks_frames(i)-1)];
        end
        rescore_spreadsheet = table(mobility_state,marks_frames,interval_frames,round(marks_sec,2,"decimals"),round(interval_sec,2,"decimals"),'VariableNames',["Mobility_state","Mark_frames","Interval_frames","Mark_sec","Interval_sec"]);
    
        %Write to spreadsheet
        file_name = append(video_name,"_rescore_",settings.scorer_name);
        if exist(append(scoring_folder,filesep,file_name,'.csv'),"file")
            time_now = datetime("now","Format",'yyyy-MM-dd_HHmmss');
            file_name = append(file_name,'_',string(time_now));
        end
        rescore_filepath = append(scoring_folder,filesep,file_name,'.csv');
        writetable(rescore_spreadsheet,rescore_filepath);
    
        %Write immobility time to results spreadsheet
        [full_im_time1,partial_im_time1] = calculateImmobility(score1_spreadsheet,frame_rate);
        [full_im_time2,partial_im_time2] = calculateImmobility(score2_spreadsheet,frame_rate);
        [full_im_time_rescore,partial_im_time_rescore] = calculateImmobility(rescore_spreadsheet,frame_rate);
    
        immobility_results_table = readtable(settings.results_spreadsheet);
        row = just_scored_video(1);
    
        immobility_results_table.Score_1_immobility_full(row) = round(full_im_time1,2,"decimals");
        immobility_results_table.Score_1_immobility_after_2_min(row) = round(partial_im_time1,2,"decimals");
        immobility_results_table.Score_2_immobility_full(row) = round(full_im_time2,2,"decimals");
        immobility_results_table.Score_2_immobility_after_2_min(row) = round(partial_im_time2,2,"decimals");
        immobility_results_table.Rescore_immobility_full(row) = round(full_im_time_rescore,2,"decimals");
        immobility_results_table.Rescore_immobility_after_2_min(row) = round(partial_im_time_rescore,2,"decimals");
        immobility_results_table.Rescore_filepath(row) = {char(rescore_filepath)};
        
        writetable(immobility_results_table,settings.results_spreadsheet,"WriteMode","overwrite");
        scores = struct('full_im_time1',full_im_time1,'partial_im_time1',partial_im_time1,'full_im_time2',full_im_time2,'partial_im_time2',partial_im_time2,'full_im_time_rescore',full_im_time_rescore,'partial_im_time_rescore',partial_im_time_rescore);
        scoring_timeline_fig = generateScoringTimeline(1,video_name,score1_spreadsheet,score2_spreadsheet,rescore_spreadsheet,scores,settings);
        figure_name = append(scoring_folder,filesep,file_name,'.png');
        saveas(scoring_timeline_fig,figure_name)
    catch exception
        errordlg(["Error saving results."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function rescoreTable(settings)
    try
        GUI_fig_pos = [0.5 0.5 0.5 0.5];
        fig = uifigure('Name','TSTScoreHelper','Units','normalized','position',GUI_fig_pos,'MenuBar','none','Resize','off','AutoResizeChildren','off');
        movegui(fig,'center');
    
        %create title
        title_position = [0 0.85 1 0.1];
        rescore_file_select_title = uicontrol('Parent',fig,'Style','text','String','ReScore File Select','FontUnits','normalized','FontSize',0.75,'Units','Normalized','Position',title_position);
        
        %delete button
        delete_button = uicontrol('Parent',fig,'Units','normalized','style','pushbutton','string','Delete table','position',[0.8 0.25 0.15 0.1],'FontUnits','normalized','FontSize',0.4,'Visible','off');
        
        %table panel
        table_panel = uipanel('Parent',fig,'Units','Normalized','Position',[0.05 0.05 0.7 0.75],'BackgroundColor','white','BorderType','line','BorderWidth',2,'BorderColor','k');
        
        %table note
        table_note = uicontrol('Parent',fig,'Style','text','String',"Hover over table to see full text",'Units','normalized','Position',[0.05 0 0.7 0.048],'FontUnits','normalized','FontSize',0.7,'Visible','off','HorizontalAlignment','left');
    
        %instructions to add spredsheet
        table_instruction_text = uicontrol('Parent',table_panel,'Style','text','String','Add a spreadsheet of the trials to score.','FontUnits','normalized','FontSize',0.3,'Units','Normalized','Position',[0.1 0.45 0.8 0.25],'BackgroundColor','white');
        
        %next button
        next_button = uicontrol(fig,'unit','normalized','style','pushbutton','string','Next','position',[0.8 0.1 0.15 0.1],'FontUnits','normalized','FontSize',0.5);
        %next_button.Callback = {@rescore_nextScreen, file_data_table, fig, settings};
        %add KeyPressFcn to have enter call next button
    
        %upload button
        upload_table_button = uicontrol('Parent',table_panel,'Units','Normalized','style','pushbutton','string','Upload file','position',[0.375 0.33 0.25 0.13],'FontUnits','normalized','FontSize',0.5);
        upload_table_button.Callback = {@rescore_addTable,fig,table_panel,table_note,delete_button,next_button,settings};
    catch exception
        errordlg(["Error generating rescore file select window. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function rescore_addTable(~,~,fig,table_panel,table_note,delete_button,next_button,settings)
    try
        [score_files_table_file_name, score_files_table_path] = uigetfile({'*.*','All Files'},'Select the spreadsheet of files to score', 'MultiSelect', 'off');
        if any([score_files_table_file_name == 0, score_files_table_path == 0])
            %the file name and/or path is empty
            uialert(fig,"Error: No file selected.","Error")
        elseif ~strcmp(score_files_table_file_name(length(score_files_table_file_name)-3:length(score_files_table_file_name)),'.csv')
            %the file selected isn't a csv
            uialert(fig,"Error: File selected is not a csv.","Error")
        else
            %make text and button invisible, essentially replaced by table.
            %invisible instead of deleted so that it can be reactivated if
            %table is deleted
            for i = 1:length(table_panel.Children)
                table_panel.Children(i).Visible = 'off';
            end
            try
                file_data_table = readtable([score_files_table_path filesep score_files_table_file_name],"Delimiter",",");
                ui_file_table = uitable(table_panel,'Data',file_data_table,'ColumnEditable',false,'ColumnWidth',{'1x','1x','1x'},'Units','normalized','Position',[0 0 1 1],'FontUnits','normalized','FontSize',0.05,'Tag','rescore_file_select_table');
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
    catch exception
        errordlg(["Error loading rescore filepath spreadsheet."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function deleteTable(~,~,table_panel,ui_file_table,delete_button)
    try
        %delete ui_file_table
        delete(ui_file_table)
    
        %make text and button visible again
        for i = 1:length(table_panel.Children)
            table_panel.Children(i).Visible = 'on';
        end
    
        %make delete button and edit button invisible again
        delete_button.Visible = 'off';
    catch exception
        errordlg(["Error deleting the table."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function rescore_nextScreen(~,~,fig,settings)
    try
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
    catch exception
        errordlg(["Error adding filepath table. Please restart the GUI"; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function results_spreadsheet_name = rescore_createResultsSpreadsheet(file_table,settings)
    try
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
        data_table.Rescore_filepath = repmat("not scored",[num_trials,1]);
    
        %create excelsheet and file paths
        if strcmp(settings.results_filepath,"Select Filepath")
            results_filepath = fileparts(file_table.video_filepath{1}); %folder of first video in list
        else
            results_filepath = settings.results_filepath;
        end
    
        results_spreadsheet_name = append(results_filepath,filesep,'Results_rescore_',settings.scorer_name,'.csv');
        if exist(results_spreadsheet_name,"file")
            results_spreadsheet_name = append(results_filepath,filesep,'Results_rescore_',settings.scorer_name,'_',string(datetime("now","Format","uuuu-MM-dd_HHmmss")),'.csv');
        end
        writetable(data_table,results_spreadsheet_name,'WriteMode','append');
    catch exception
        errordlg(["Error preparing results spreadsheet. Please restart the GUI"; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

%% Score functions

function scoreTable(settings)
    try
        GUI_fig_pos = [0.5 0.5 0.5 0.5];
        fig = uifigure('Name','TSTScoreHelper','Units','normalized','position',GUI_fig_pos,'MenuBar','none','Resize','off','AutoResizeChildren','off');
        movegui(fig,'center');
    
        %create title
        title_position = [0 0.86 1 0.1];
        rescore_file_select_title = uicontrol('Parent',fig,'Style','text','String','Score File Select','FontUnits','normalized','FontSize',0.75,'Units','Normalized','Position',title_position);
        
        %delete button
        delete_button = uicontrol('Parent',fig,'Units','normalized','style','pushbutton','string','Delete table','position',[0.8 0.25 0.15 0.1],'FontUnits','normalized','FontSize',0.4,'Visible','off');
    
        %table panel
        table_panel = uipanel('Parent',fig,'Units','Normalized','Position',[0.05 0.05 0.7 0.75],'BackgroundColor','white','BorderType','line','BorderWidth',2,'BorderColor','k');
        
        %table note
        table_note = uicontrol('Parent',fig,'Style','text','String',"Hover over table to see full text",'Units','normalized','Position',[0.05 0 0.7 0.048],'FontUnits','normalized','FontSize',0.7,'Visible','off','HorizontalAlignment','left');
    
        %instructions to add spredsheet
        table_instruction_text = uicontrol('Parent',table_panel,'Style','text','String','Add a spreadsheet of the trials to score.','BackgroundColor','white','FontUnits','normalized','FontSize',0.3,'Units','Normalized','Position',[0.1 0.45 0.8 0.25]);
        
        %next button
        next_button = uicontrol('Parent',fig,'Units','normalized','style','pushbutton','string','Next','position',[0.8 0.1 0.15 0.1],'FontUnits','normalized','FontSize',0.5);    
    
        %upload button
        upload_table_button = uicontrol('Parent',table_panel,'Units','Normalized','style','pushbutton','string','Upload file','position',[0.375 0.33 0.25 0.13],'FontUnits','normalized','FontSize',0.5);
        upload_table_button.Callback = {@score_addTable,fig,table_panel,table_note,delete_button,next_button,settings};
    catch exception
        errordlg(["Error generating score file select window. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function score_addTable(~,~,fig,table_panel,table_note,delete_button,next_button,settings)
    try
        [score_files_table_file_name, score_files_table_path] = uigetfile({'*.*','All Files'},'Select the spreadsheet of files to score', 'MultiSelect', 'off');
        if any([score_files_table_file_name == 0, score_files_table_path == 0])
            %the file name and/or path is empty
            uialert(fig,"Error: No file selected.","Error")
        elseif ~strcmp(score_files_table_file_name(length(score_files_table_file_name)-3:length(score_files_table_file_name)),'.csv')
            %the file selected isn't a csv
            uialert(fig,"Error: File selected is not a csv.","Error")
        else
            %make text and button invisible, essentially replaced by table.
            %invisible instead of deleted so that it can be reactivated if
            %table is deleted
            for i = 1:length(table_panel.Children)
                table_panel.Children(i).Visible = 'off';
            end
            try
                file_data_table = readtable([score_files_table_path filesep score_files_table_file_name],"Delimiter",",");
                ui_file_table = uitable(table_panel,'Data',table(file_data_table.video_filepath),'ColumnEditable',false,'Units','normalized','Position',[0 0 1 1],'FontUnits','normalized','FontSize',0.05,'Tag','score_file_select_table');
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
                %make text and button visible again
                for i = 1:length(table_panel.Children)
                    table_panel.Children(i).Visible = 'on';
                end
            end
        end
    catch exception
        errordlg(["Error loading score filepath spreadsheet."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function score_nextScreen(~,~,fig,settings)
    try
        file_uitable = findall(0,'Type','uitable','Tag','score_file_select_table');
        file_table = file_uitable.Data;
        file_table.Properties.VariableNames{1} = 'video_filepath';
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
    catch exception
        errordlg(["Error continuing."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function results_spreadsheet_name = score_createResultsSpreadsheet(file_table,settings)
    try
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
    
        results_spreadsheet_name = append(results_filepath,filesep,'Results_score_',settings.scorer_name,'.csv');
        if exist(results_spreadsheet_name,"file")
            results_spreadsheet_name = append(results_filepath,filesep,'Results_score_',settings.scorer_name,'_',string(datetime("now","Format","uuuu-MM-dd_HHmmss")),'.csv');
        end
        writetable(data_table,results_spreadsheet_name,'WriteMode','append');%,'AutoFitWidth',false);
    catch exception
        errordlg(["Error preparing results spreadsheet. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function [GUI_fig, videoPanel, play_button, next_button, button_group, clip_counter, start_text] = scoreFigure(file_table,settings)
    try
        %create new fig
        GUI_fig_pos = [0.5 0.5 0.5 0.5];
        GUI_fig = uifigure('Name','TSTScoreHelper','Units','normalized','position',GUI_fig_pos,'MenuBar','none','Tag','video_scoring_figure','Resize','off','AutoResizeChildren','off');
        movegui(GUI_fig,'center');
        GUI_fig.UserData = struct("video_file_path",file_table.video_filepath{1},"mark_frame",0);
        
        %create video and button panels
        videoPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.3 0.5 0.5], 'BorderWidth',2,'BorderColor','k','Tag','video_display_panel');
        textPanel = uipanel('Parent',GUI_fig,'Units','Normalized','Position',[0.55 0.25 0.4 0.6],'BorderWidth',0);
        buttonPanel = uipanel('Parent', GUI_fig, 'Units', 'Normalized', 'Position', [0.05 0.05 0.5 0.2], 'BorderWidth', 0);
    
        %create axis
        video_axis = axes('position', [0 0 1 1], 'Parent', videoPanel,'Tag','video_display_axis');
        video_axis.Toolbar.Visible = 'off';
        video_axis.XTick = [];
        video_axis.YTick = [];
        video_axis.XColor = [1 1 1];
        video_axis.YColor = [1 1 1];
        video_axis.Interactions = [];
        
        %create title
        title_position = [0.3 0.87 0.4 0.1];
        uicontrol('style', 'text', 'String', 'Mobility Analysis', 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', GUI_fig, 'Position', title_position, 'BackgroundColor', GUI_fig.Color);
        
        %start text
        start_text_string = 'Press the start button.';
        start_text_pos = [0.25 0.35 0.5 0.3];
        start_text = uicontrol('style', 'text', 'String', start_text_string, 'FontUnits', 'normalized', 'FontSize', 0.4, 'Units', 'Normalized', 'Parent', videoPanel, ...
            'Position', start_text_pos,'BackgroundColor',video_axis.XColor,'Tag','start_instructions_text','HorizontalAlignment','center');
        
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
        uicontrol('style', 'text', 'String', "Mobility:", 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.9 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
        uicontrol('style', 'text', 'String', mobility_definition, 'FontUnits', 'normalized', 'FontSize', 0.15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.5 0.9 0.4], 'HorizontalAlignment', 'left');
        uicontrol('style', 'text', 'String', "Immobility:", 'FontUnits', 'normalized', 'FontSize', 0.7, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.05 0.4 0.9 0.1], 'HorizontalAlignment', 'left', 'FontWeight','bold');
        uicontrol('style', 'text', 'String', immobility_definition, 'FontUnits', 'normalized', 'FontSize', 0.15, 'Units', 'Normalized', 'Parent', textPanel, 'Position', [0.1 0.0 0.9 0.4], 'HorizontalAlignment', 'left');
    
        %keeping track of which videos are scored
        file_table.scored = zeros(height(file_table),1);
        video = file_table.video_filepath{1}; %start with first video
    
        %set results filepath if not specified
        if strcmp(settings.results_filepath,"Select Filepath")
            [video_filepath,~] = fileparts(video);
            settings.results_filepath = video_filepath;
        end
    
        %clip counter/video name
        number_of_videos = height(file_table);
        clip_counter_text = append("Video 1/",string(number_of_videos));
        if settings.show_video_name_checkbox
            [~, video_name] = fileparts(video);
            clip_counter_text = append(clip_counter_text,", ",video_name);
        end
        clip_counter_pos = [0.05 0.805 0.5 0.05];
        clip_counter = uicontrol('style', 'text', 'String', clip_counter_text, 'FontUnits', 'normalized', 'FontSize', 0.9, ...
            'Units', 'Normalized', 'Parent', GUI_fig, 'Position', clip_counter_pos, 'BackgroundColor', GUI_fig.Color,'HorizontalAlignment','left');
    
        %play button
        play_button = uicontrol(GUI_fig, 'unit', 'Normalized', 'style', 'pushbutton', 'string', 'Start', 'FontUnits', 'normalized', 'FontSize', 0.5, 'position', [0.6 0.1 0.15 0.1], 'tag', ...
        'playbutton');
        if settings.exclude_first_2_min_checkbox
            start_frame = 0; %edit to frame at two min when frame rate is known
        else
            start_frame = 1;
        end
        play_button.Callback = {@playVideo,video,start_frame,0,0,settings};
    
        %mobility and immobility switch
        monitor_size_pixels = get(groot,"ScreenSize");
        button_panel_position = buttonPanel.Position;
        mobility_switch_position = [(0.4*monitor_size_pixels(3)*button_panel_position(3)*GUI_fig_pos(3)) (0.35*monitor_size_pixels(4)*button_panel_position(4)*GUI_fig_pos(4)) (0.3*monitor_size_pixels(3)*button_panel_position(3)*GUI_fig_pos(3)) (0.2*monitor_size_pixels(4)*button_panel_position(4)*GUI_fig_pos(4))];
        mobility_switch = uiswitch(buttonPanel,'slider','Items',{'Mobile','Immobile'},'FontSize',20,'Orientation','horizontal','Position',mobility_switch_position,'ValueChangedFcn',{@mobilityMark,GUI_fig,NaN});
        if settings.starting_mobility_status
            mobility_switch.Value = 'Mobile';
        else
            mobility_switch.Value = 'Immobile';
        end
        
        %next button
        next_button = uicontrol(GUI_fig,'unit','Normalized','style','pushbutton','string','Next','FontUnits','normalized','FontSize',0.5, ...
            'position', [0.8 0.1 0.15 0.1], 'tag', 'next_button');
        next_button.Callback = {@nextButton,file_table,play_button,clip_counter,mobility_switch,settings};
    catch exception
        errordlg(["Error generating score window. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end

function mobilityMark(mobility_switch,~,GUI_fig,mobility_marks_vector)
    try
        mark_frame = guidata(GUI_fig);
        if isnan(mobility_marks_vector)
            mobility_marks_vector = [];
        end
        mobility_marks_vector = [mobility_marks_vector;mark_frame];
        mobility_switch.ValueChangedFcn{3} = mobility_marks_vector;
    catch exception
        errordlg(["Error recording mobility state change. Please restart the GUI."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
        play_button = findall(0,'Type','uicontrol','Tag','playbutton');
        play_button.String = 'Continue';
    end
end

function nextButton(next_button,~,file_table,play_button,clip_counter,mobility_switch,settings)
    try
        v = VideoReader(play_button.Callback{2});
        GUI_fig = next_button.Parent;
        if (guidata(GUI_fig) ~= (v.NumFrame+1))
            msg = "Are you sure you want to continue without finishing scoring this trial? Results for this trial will not be saved if you continue.";
            warning_selection = uiconfirm(GUI_fig,msg,"Warning","Icon","warning","Options",["Continue","Cancel"]);
        else
            warning_selection = "Continue";
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
        
            %get frame rate
            frame_rate = v.FrameRate;
            
            %get scoring table with marks
            try
                mobility_marks_vector = mobility_switch.ValueChangedFcn{3};
                if isnan(mobility_marks_vector) %if no mobility marks made
                    mobility_marks_vector = [];
                end
                final_mark = guidata(GUI_fig);
                mobility_marks_vector = [mobility_marks_vector; final_mark];
                interval_frames_vector = [mobility_marks_vector(1); diff(mobility_marks_vector)];
                mobility_marks_sec_vector = mobility_marks_vector/frame_rate;
                interval_sec_vector = [mobility_marks_sec_vector(1); diff(mobility_marks_sec_vector)];
                mobility_state_vector = ones(height(mobility_marks_vector),1);
                if settings.starting_mobility_status %if starting mobile
                    mobility_state_vector(2:2:end) = 0;
                else
                    mobility_state_vector(1:2:end) = 0;
                end
                scoring_table = table(mobility_state_vector,mobility_marks_vector,interval_frames_vector,round(mobility_marks_sec_vector,2,"decimals"),round(interval_sec_vector,2,"decimals"),'VariableNames',["Mobility_state","Mark_frames","Interval_frames","Mark_sec","Interval_sec"]);
            catch %If table is empty, trying to convert to datetime will throw an error. This happens if the user presses next without marking any marks.
                scoring_table = table(settings.starting_mobility_status,0,0,0,0,'VariableNames',["Mobility_state","Mark_frames","Interval_frames","Mark_sec","Interval_sec"]);
            end
        
            %Write scoring table to spreadsheet (always a new one)
            spreadsheet_name = append(current_video_name,"_score_",settings.scorer_name,'.csv');
            if exist(append(scoring_folder,filesep,spreadsheet_name),"file")
                spreadsheet_name = append(current_video_name,"_score_",settings.scorer_name,string(datetime("now","Format","uuuuMMdd'_'HHmmss")),'.csv');
            end
            scoring_table_file = append(scoring_folder,filesep,spreadsheet_name);
            writetable(scoring_table,scoring_table_file);
            [full_im_time1,partial_im_time1] = calculateImmobility(scoring_table,frame_rate);
            
            %Write immobility score to results table
            immobility_results_table = readtable(settings.results_spreadsheet);
            just_scored_video = find(file_table.scored == 0,1);
            row = just_scored_video;
        
            immobility_results_table.immobility_full(row) = round(full_im_time1,2,"decimals");
            immobility_results_table.immobility_after_2_min(row) = round(partial_im_time1,2,"decimals");
            immobility_results_table.score_filepath(row) = {scoring_table_file(1)};
            
            writetable(immobility_results_table,settings.results_spreadsheet,"WriteMode","overwrite"); 
        
            %Generate timeline and save as png
            % marks1 = scoring_table.Mark_sec.';
            % marks1 = marks1(:,1:length(marks1) - 1);
            scores.full_im_time1 = full_im_time1;
            scores.partial_im_time1 = partial_im_time1; 
        
            try %if the user doesn't make any marks generating a scoreing timeline will throw an error
                scoring_timeline_fig = generateScoringTimeline(0,current_video_name,scoring_table,NaN,NaN,scores,settings);
                figure_name = append(scoring_folder,filesep,current_video_name,'.png');
                saveas(scoring_timeline_fig,figure_name)
            catch
                msgbox('Error generating score timeline.','Error');
            end
        end
    
        if strcmp(warning_selection,"Continue")
            %find first row of file_table where scored variable is zero
            not_scored = find(file_table.scored == 0);
            file_table.scored(not_scored(1)) = 1;
            %next button call back new file_table
            next_button.Callback = {@nextButton,file_table,play_button,clip_counter,mobility_switch,settings};
            try
                %get the next unscored video and set it to play_button callback
                video = file_table.video_filepath{not_scored(2)};
                if settings.exclude_first_2_min_checkbox
                    start_frame = 0;
                else
                    start_frame = 1;
                end
                play_button.Callback = {@playVideo,video,start_frame,0,play_button,settings};
                %update video that is playing
                play_button.String = 'Start';
                %update mobility switch to start status
                if settings.starting_mobility_status
                    mobility_switch.Value = "Mobile";
                else
                    mobility_switch.Value = "Immobile";
                end
                %update video count text
                clip_counter_text = append("Video ",string(not_scored(2)),"/",string(height(file_table)));
                if settings.show_video_name_checkbox
                    [~, video_name] = fileparts(video);
                    clip_counter_text = append(clip_counter_text,", ",video_name);
                end
                clip_counter.String = clip_counter_text;
                mobility_switch.ValueChangedFcn{3} = NaN;
    
                %update video timer text
                if settings.show_video_time_checkbox
                    video_timer = findall(0,'Type','uicontrol','Tag','video_timer');
                    delete(video_timer)
                    timer_text = append("0.0/",num2str(v.Duration,"%.1f")," s");
                    video_time_position = [0.075 0.225 0.2 0.05];
                    uicontrol('Style','Text','String',timer_text,'FontUnits','normalized','FontSize',0.9,'Parent',GUI_fig,'Units','normalized','Position',video_time_position, ...
                        'BackgroundColor',GUI_fig(1).Color,'HorizontalAlignment','left','Tag','video_timer');
                end    
            catch
                %scored all videos, alert that the user is done and where to find the results and close the
                %program
                uialert(GUI_fig,['Finished scoring all videos. Results saved at ' settings.results_filepath '.'],'Scoring Complete','Icon','success')
                return
            end
        end
    catch exception
        errordlg(["Error continuing."; "Full error:"; exception.message; exception.identifier; exception.cause; "line:"; exception.stack(1).line; exception.Correction],"Error")
    end
end
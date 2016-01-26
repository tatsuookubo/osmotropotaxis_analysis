function display_two_behavioral_condition_traces( condition_trials_str, btraces_per_condition, ctraces_in_roi_per_condition, bdata_vel_time, VPS, filename_prefix )

ac = get_analysis_constants;
settings = sensor_settings;
order = ac.order;

SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

IMAGE_ROWS = 4;
IMAGE_COLS = 4;
PLANES = IMAGE_ROWS * IMAGE_COLS;

prestim = settings.pre_stim;
stim    = settings.stim;
poststim    = settings.post_stim;

base_begin = 1;
base_end = floor(prestim*VPS);

total_time = prestim + stim + poststim;

first_stim_t = prestim;
last_stim_t = stim + prestim;

t = [1:nframes]./VPS;

for trial_type = 1:size( btraces_per_condition, 2 )
        
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    
    for cond_ord = 1:size( btraces_per_condition, 1 )
        
        if(cond_ord == 1)
            cur_cond_symbol = '-';
        else
            cur_cond_symbol = '--';
        end
        
        for p=1:PLANES
            subaxis( IMAGE_ROWS+1, IMAGE_COLS, p, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN );
            
            colorindex = 0;
            
            for roi_id = 1:size(ctraces_in_roi_per_condition, 4)
                hold on;
                currcolor = order(1+mod(colorindex,size(order,1)),:);
                avg_trace = mean(squeeze(ctraces_in_roi_per_condition(cond_ord, trial_type, :, roi_id, :)));
                
                plot( t, avg_trace, 'color', currcolor, 'LineSpec', cur_cond_symbol );
                colorindex = colorindex + 1;
            end
            
            yy = ylim;
            y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
            hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
            set(gca,'children',circshift(get(gca,'children'),-1));
            set(hh, 'EdgeColor', 'None');
            
            xlim([0, total_time]);
            if(mod((p-1),4) == 0 )
                ylabel('dF/F');
            else
                set(gca, 'YTickLabel', '');
            end
            
            set(gca, 'XTickLabel', '');
            
            if( p == 2 )
                tt = title(filename_prefix);
                set(tt, 'Interpreter', 'none')
            end
            drawnow;
        end
    
        for c = 1:IMAGE_COLS
            
            % Axis for behavioral data
            subaxis(IMAGE_ROWS+1, IMAGE_COLS, PLANES + c, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
            
            hold on;
            avg_trace_fwd = mean(squeeze(btraces_per_condition( cond_ord, trial_type, :, ac.VEL_FWD, : )));
            avg_trace_yaw = mean(squeeze(btraces_per_condition( cond_ord, trial_type, :, ac.VEL_YAW, : )));
            
            phdl(cond_ord, 1) = plot( bdata_vel_time, avg_trace_fwd, 'color', rgb('FireBrick'), 'LineSpec', cur_cond_symbol );
            phdl(cond_ord, 2) = plot( bdata_vel_time, avg_trace_yaw, 'color', rgb('SeaGreen'), 'LineSpec', cur_cond_symbol );
            
            if( ( c == 1 ) & ( cond_ord == 2 ))
                legend( [ phdl(1,1), phdl(2,1), phdl(1,2), phdl(2,2) ], ... 
                        ['Vel fwd - ' condition_trials_str(1)], ['Vel yaw - ' condition_trials_str(1)], ...
                        ['Vel fwd - ' condition_trials_str(2)], ['Vel yaw - ' condition_trials_str(2)] );
            end
            
            yy = ylim;
            y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
            hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
            set(gca,'children',circshift(get(gca,'children'),-1));
            set(hh, 'EdgeColor', 'None');
            
            xlim([0, total_time]);
            xlabel('Time (s)');
            if( c == 1 )
                ylabel('Velocity (au/s)');
            else
                set(gca, 'YTickLabel', '');
            end
            
            drawnow;
        end
    end
        
    saveas(f, [ filename_prefix '.fig']);
    saveas(f, [ filename_prefix '.png']);
    % close(f);
end

end


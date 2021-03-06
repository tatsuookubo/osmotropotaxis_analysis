function display_two_condition_difference_image_tmp( ref_img, PLANE_OF_INTEREST, TRIAL_TYPE_OF_INTEREST, condition_trials_str, btraces_per_condition, avg_df_f_per_condition_per_plane, bdata_vel_time, frame_start_offsets, VPS, filename_prefix )

ac = get_analysis_constants;
settings = sensor_settings;

SPACING = 0.01;
PADDING = 0;
MARGIN = 0.05;

IMAGE_ROWS = 4;
IMAGE_COLS = 4;
PLANES = IMAGE_ROWS * IMAGE_COLS;

prestim = settings.pre_stim;
stim    = settings.stim;
poststim    = settings.post_stim;

total_time = prestim + stim + poststim;

first_stim_t = prestim;
last_stim_t = stim + prestim;

x_size = size(avg_df_f_per_condition_per_plane, 4);
y_size = size(avg_df_f_per_condition_per_plane, 5);
nframes = size(avg_df_f_per_condition_per_plane, 6);

t = zeros(PLANES,nframes,'double');
for p=1:PLANES
    t(p,:) = (([0:nframes-1]))./VPS + frame_start_offsets(p);
end

npts = 1;
colorindex = 0;

order    = [ rgb('Blue'); rgb('Green'); rgb('Red'); rgb('Black'); rgb('Purple'); rgb('Brown'); rgb('Indigo'); rgb('DarkRed') ];
nroi = 1;
intens = [];
[x, y] = meshgrid(1:y_size, 1:x_size);
baseline_start = 0;
baseline_end = 2.8;

%for trial_type = 1:size( btraces_per_condition, 2 )
for trial_type = TRIAL_TYPE_OF_INTEREST
        
%    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
%    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
    f1 = figure();
    f2 = figure();
       
    % for p=1:PLANES
    for p = PLANE_OF_INTEREST
        %subaxis( IMAGE_ROWS+1, IMAGE_COLS, p, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN );
        %subplot(1,3,1); 
               
        cur_plane_avg_df_f_cond_1 = squeeze(avg_df_f_per_condition_per_plane(trial_type,1,p,:,:,:));
        cur_plane_avg_df_f_cond_1(~isfinite(cur_plane_avg_df_f_cond_1)) = 0.0;
        %cur_plane_avg_df_f_cond_1_filt_r = smoothts(reshape(cur_plane_avg_df_f_cond_1,[x_size*y_size, nframes]));
        %cur_plane_avg_df_f_cond_1_filt = reshape(cur_plane_avg_df_f_cond_1_filt_r, [x_size, y_size, nframes]);

        cur_plane_avg_df_f_cond_2 = squeeze(avg_df_f_per_condition_per_plane(trial_type,2,p,:,:,:));
        cur_plane_avg_df_f_cond_2(~isfinite(cur_plane_avg_df_f_cond_2)) = 0.0;
        %cur_plane_avg_df_f_cond_2_filt_r = smoothts(reshape(cur_plane_avg_df_f_cond_2,[x_size*y_size, nframes]));
        %cur_plane_avg_df_f_cond_2_filt = reshape(cur_plane_avg_df_f_cond_2_filt_r, [x_size, y_size, nframes]);
        
        cur_t = squeeze(t(p,:));

        % Extract frames during stim only for now.
        cur_frames = find((cur_t >= prestim) & (cur_t<=(prestim+stim)));

        avg_df_f_img_cond_1 = squeeze(mean(cur_plane_avg_df_f_cond_1(:,:,cur_frames),3));
        avg_df_f_img_cond_2 = squeeze(mean(cur_plane_avg_df_f_cond_2(:,:,cur_frames),3));

        figure(f1);

        ax1 = subplot(2,2,1); 
        ref_img_mask = get_dead_pixel_mask(ref_img);
        save('/tmp/ref_img.mat', 'ref_img');

        
        [xsize, ysize] = size(ref_img);
        %imagesc(imresize(ref_img, [xsize 2*ysize]));
        imagesc( ref_img.*ref_img_mask );
        colormap(ax1, 'gray');
        axis image;
        caxis([0 3000]);
        title([ac.task_str{trial_type}]);

        ax2 = subplot(2,2,2); 
        imagesc(avg_df_f_img_cond_1.*ref_img_mask);
        axis image;
        colormap(ax2, 'jet');
        caxis([-0 0.5]);
        tt = title(['Condition 1: ' condition_trials_str{1}]);
        set(tt, 'Interpreter', 'none');

        ax3 = subplot(2,2,4); 
        imagesc(avg_df_f_img_cond_2.*ref_img_mask);
        axis image;
        colormap(ax3, jet);
        caxis([-0 0.5]);       
        tt = title(['Condition 2: ' condition_trials_str{2}]);
        set(tt, 'Interpreter', 'none');

        ax4 = subplot(2,2,3);
       
        dx = 16;
        dy = 16;        
        
        %cur_plane_avg_df_f_cond_1_down = squeeze(mean(mean(reshape(cur_plane_avg_df_f_cond_1, [dx, xsize/dx, dy, ysize/dy, nframes ]),3),1));        
        %cur_plane_avg_df_f_cond_2_down = squeeze(mean(mean(reshape(cur_plane_avg_df_f_cond_2, [dx, xsize/dx, dy, ysize/dy, nframes ]),3),1));        
        
        cur_plane_avg_df_f_cond_1_down = downsample_with_mask(cur_plane_avg_df_f_cond_1, ref_img_mask, dx, dy);
        cur_plane_avg_df_f_cond_2_down = downsample_with_mask(cur_plane_avg_df_f_cond_2, ref_img_mask, dx, dy);
            
        
        frames_of_interest_cond_1 = cur_plane_avg_df_f_cond_1_down(:,:,cur_frames);
        frames_of_interest_cond_2 = cur_plane_avg_df_f_cond_2_down(:,:,cur_frames);
        
        diff_img_down = trapz(frames_of_interest_cond_1,3) - trapz(frames_of_interest_cond_2,3);
        
        if 0
            avg_df_f_img_cond_1_down = squeeze(mean(cur_plane_avg_df_f_cond_1_down(:,:,cur_frames),3));
            avg_df_f_img_cond_2_down = squeeze(mean(cur_plane_avg_df_f_cond_2_down(:,:,cur_frames),3));

            %diff_img_down = avg_df_f_img_cond_1_down ./ avg_df_f_img_cond_2_down;
            diff_img_down = avg_df_f_img_cond_1_down - avg_df_f_img_cond_2_down;
        end
        
        imagesc( [1:ysize], [1:xsize], diff_img_down );
        xlim([1 ysize]);
        ylim([1 xsize]);
        axis image;
        colormap(ax4, 'jet');
        %caxis(ax4,[0.0 0.1]);       
        title('Diff img');
        
        a_data_1 = cur_plane_avg_df_f_cond_1;
        a_data_2 = cur_plane_avg_df_f_cond_2;

        plt_cond_1 = [];
        plt_cond_2 = [];
        
        figure;
        diff_img_down_scaled = expand_img(diff_img_down, dx, dy);
        ref_img_filt = ref_img.*ref_img_mask;
        save('/tmp/overlay.mat', 'ref_img_filt', 'diff_img_down_scaled');
        
        C = imfuse(ref_img_filt, diff_img_down_scaled, 'blend', 'Scaling', 'joint');
        imshow(C);
        
        if( 0 ) colormap jet;
            
            h = imagesc( ref_img.*ref_img_mask );
            colormap(ax1, 'gray');
            axis image;
            caxis([0 4000]);
            title([ac.task_str{trial_type}]);
            set(h, 'AlphaData', diff_img_down_scaled);
            
            figure;
            cur_t = squeeze(t(p,:));
            hold on;
            plot(cur_t, squeeze(cur_plane_avg_df_f_cond_1_down(6,11,:)), 'color', 'r');
            plot(cur_t, squeeze(cur_plane_avg_df_f_cond_2_down(6,11,:)), 'color', 'r', 'LineStyle', '--');
            plot(cur_t, squeeze(cur_plane_avg_df_f_cond_1_down(6,7,:)), 'color', 'b');
            plot(cur_t, squeeze(cur_plane_avg_df_f_cond_2_down(6,7,:)), 'color', 'b', 'LineStyle', '--');
        end
        
        clicky_plane = 1;
        while(npts > 0)
            
            figure(f1)
            subplot(2,2,clicky_plane);
            % subplot(1,3,1)
            [xv, yv] = (getline(gca, 'closed'));
            if size(xv,1) < 3  % exit loop if only a line is drawn
                break
            end
            inpoly = inpolygon(x,y,xv,yv);
            
            [ idx_r, idx_c ]  = find(inpoly == 1);
                        
            if 0                

                total_cnt = length(idx_r);

            figure;
            for ii = 1:total_cnt
                subplot(1,2,1)
                hold on;
                plot(squeeze(a_data_1(idx_r(ii),idx_c(ii),cur_frames)));
                ylim([-0.5 1.5]);
            
                subplot(1,2,2)
                hold on;
                plot(squeeze(a_data_2(idx_r(ii),idx_c(ii),cur_frames)));
                ylim([-0.5 1.5]);
                
                waitforbuttonpress
            end
    
                pixel_by_pixel_img_1 = zeros(total_cnt, length(cur_frames));
                pixel_by_pixel_img_2 = zeros(total_cnt, length(cur_frames));
                
                for ii = 1:total_cnt
                    pixel_by_pixel_img_1(ii,:) = squeeze(a_data_1(idx_r(ii),idx_c(ii),cur_frames));
                    pixel_by_pixel_img_2(ii,:) = squeeze(a_data_2(idx_r(ii),idx_c(ii),cur_frames));
                end
            end
                   
            figure(f1)
            subplot(2,2,clicky_plane);
            %draw the bounding polygons and label them
            currcolor    = order(1+mod(colorindex,size(order,1)),:);
            hold on;
            plot(xv, yv, 'Linewidth', 1,'Color',currcolor);
            text(mean(xv),mean(yv),num2str(colorindex+1),'Color',currcolor,'FontSize',12);
            
            %bline_s = floor(baseline_start*VPS);
            bline_s = 1;
            bline_e = floor(baseline_end*VPS);
            
            itrace_1 = squeeze(sum(sum(double(a_data_1).*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
            itrace_2 = squeeze(sum(sum(double(a_data_2).*repmat(inpoly, [1, 1, nframes]))))/sum(inpoly(:));
            
            figure(f2);
            %ax1 = subplot(1,3,2:3); % plot the trace
            subplot(1,1,1)
            hold on;
            cur_t = squeeze(t(p,:));
            plt_cond_1(end+1) = plot( cur_t, itrace_1, 'Color', currcolor, 'LineWidth', 2);
            plt_cond_2(end+1) = plot( cur_t, itrace_2, 'Color', currcolor, 'LineWidth', 2, 'LineStyle', '--');
            
            xlim([0 max(cur_t)]);
            %ylim([-0.2 0.75]);
            xlabel('Time (s)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('dF/F');
            set(gca, 'FontSize', 14 );
            set(gca, 'FontWeight', 'bold');
            
            colorindex = colorindex+1;
          
            roi_points{nroi} = [xv, yv];
            nroi = nroi + 1;
        end                
        
        figure( f2 );
        %ax1 = subplot(1,3,2:3); % plot the trace
        subplot(1,1,1)

        yy = ylim;
        y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
        hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
        set(gca,'children',circshift(get(gca,'children'),-1));
        set(hh, 'EdgeColor', 'None');

        cond_1_num_trials = size( btraces_per_condition{ 1, trial_type }( :, ac.VEL_YAW, : ), 1 );
        cond_2_num_trials = size( btraces_per_condition{ 2, trial_type }( :, ac.VEL_YAW, : ), 1 );
        
        ll = legend( [ plt_cond_1(1), plt_cond_2(1) ], ...
                     [ condition_trials_str{ 1 } '(' num2str( cond_1_num_trials ) ')'], ...
                     [ condition_trials_str{ 2 } '(' num2str( cond_2_num_trials ) ')'], 'Location', 'southeast');
        set(ll, 'Interpreter', 'none');
        
        drawnow;
    end
    
if 0
    for c = 1:IMAGE_COLS
        
        % Axis for behavioral data
        subaxis(IMAGE_ROWS+1, IMAGE_COLS, PLANES + c, 'Spacing', SPACING, 'Padding', PADDING, 'Margin', MARGIN);
        
        hold on;

        avg_trace_yaw_cond_1 = mean(squeeze(btraces_per_condition{ 1, trial_type }( :, ac.VEL_YAW, : )));
        avg_trace_yaw_cond_2 = mean(squeeze(btraces_per_condition{ 2, trial_type }( :, ac.VEL_YAW, : )));
        
        %phdl(cond_ord, 1) = plot( bdata_vel_time, avg_trace_fwd, 'color', rgb('FireBrick'), 'LineStyle', cur_cond_symbol );
        phdl(1) = plot( bdata_vel_time, avg_trace_yaw_cond_1, 'color', rgb('SeaGreen'), 'LineStyle', '-' );
        phdl(2) = plot( bdata_vel_time, avg_trace_yaw_cond_2, 'color', rgb('SeaGreen'), 'LineStyle', '--' );
        
        cond_num_trials( 1 ) = size( btraces_per_condition{ 1, trial_type }( :, ac.VEL_YAW, : ), 1 );
        cond_num_trials( 2 ) = size( btraces_per_condition{ 2, trial_type }( :, ac.VEL_YAW, : ), 1 );
        
        if( c == 1 )
            ll = legend( [ phdl(1), phdl(2) ], ...
                [ condition_trials_str{ 1 } '(' num2str( cond_num_trials( 1 ) ) ')'], ...
                [ condition_trials_str{ 2 } '(' num2str( cond_num_trials( 2 ) ) ')'] );
            set(ll, 'Interpreter', 'none');
        end
        
        yy = ylim;
        y_min = yy(1)-yy(1)*0.01; y_max = yy(2);
        hh = fill([ first_stim_t first_stim_t last_stim_t last_stim_t ],[y_min y_max y_max y_min ], rgb('Wheat'));
        set(gca,'children',circshift(get(gca,'children'),-1));
        set(hh, 'EdgeColor', 'None');
        
        xlim([0, total_time]);
        xlabel('Time (s)');
        if( c == 1 )
            ylabel('Yaw velocity (au/s)');
        else
            set(gca, 'YTickLabel', '');
        end
        
        drawnow;
    end
end

    saveas(f1, [ filename_prefix '_' ac.task_str{trial_type} '_rois.fig']);
    saveas(f1, [ filename_prefix '_' ac.task_str{trial_type} '_rois.png']);
    saveas(f2, [ filename_prefix '_' ac.task_str{trial_type} '_tc.fig']);
    saveas(f2, [ filename_prefix '_' ac.task_str{trial_type} '_tc.png']);
    % close(f);
end

end


function [ output_args ] = display_avg_velocity_exclude_zero_vel_one_side_only( sid, bdata_raw, bdata_vel, bdata_vel_time, analysis_path, with_single_trials )

ac = get_analysis_constants;
settings = sensor_settings;

one_trial_bdata = squeeze(bdata_raw{ ac.LEFT}(1,:,:));
left_odor_stim  = squeeze(one_trial_bdata(:,5));
first_stim = find((left_odor_stim > 0.6), 1, 'first') ./ settings.sampRate;
last_stim = find((left_odor_stim > 0.6), 1, 'last') ./ settings.sampRate;

kept_trials = {[], [], []};
FWD_VEL_THRESH = 0.001;

for trial_type = 1:length(bdata_vel)
    current_trials = bdata_vel{ trial_type }(:,:,:);
    for tid = 1:size(current_trials,1)
        cur_fwd_vel = mean(squeeze(current_trials(tid, ac.VEL_FWD,:)));

        if(abs(cur_fwd_vel) > FWD_VEL_THRESH)
            kept_trials{trial_type}(end+1,:,:) = squeeze(current_trials(tid,:,:));
        end
    end
end

f = figure('units','normalized','outerposition',[0 0 1 1]);

subplot(3,1,1);
hold on;

kept_left = size(kept_trials{ac.LEFT},1);

total_trial_cnt = kept_left;
mean_left_vel_fwd = squeeze(mean(kept_trials{ac.LEFT}(:,ac.VEL_FWD,:)));

SHOW_SEM = 1;
if( SHOW_SEM )
    sem_left_vel_fwd = squeeze(std(kept_trials{ac.LEFT}(:,ac.VEL_FWD,:),1)) ./ sqrt(size(kept_trials{ ac.LEFT }(:,ac.VEL_FWD,:),1));
else
    sem_left_vel_fwd = squeeze(std(kept_trials{ac.LEFT}(:,ac.VEL_FWD,:),1));
end

fh = fill( [bdata_vel_time, fliplr(bdata_vel_time)], ... 
        [(mean_left_vel_fwd+sem_left_vel_fwd)' fliplr((mean_left_vel_fwd-sem_left_vel_fwd)')], ...
        rgb('Salmon'));
set(fh, 'EdgeColor', 'None');

p1 = plot(bdata_vel_time, mean_left_vel_fwd, 'color', ac.LEFT_CLR);
%ylim([-0.01 0.05]);

legend([p1], 'Left Odor w/ SEM');

yy = ylim;
y_min = yy(1); y_max = yy(2);
hh = fill([ first_stim first_stim last_stim last_stim ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

xlim([0, bdata_vel_time(end)]);
xlabel('Time (s)');
ylabel('Velocity (au/s)');
title(['Forward velocity. Trial count: ' num2str(total_trial_cnt)]);

subplot(3,1,2);
hold on;

mean_left_vel_side = squeeze(mean(kept_trials{ac.LEFT}(:,ac.VEL_SIDE,:)));

sem_left_vel_side = squeeze(std(kept_trials{ac.LEFT}(:,ac.VEL_SIDE,:),1)) ./ sqrt(size(kept_trials{ ac.LEFT }(:,ac.VEL_SIDE,:),1));

fh = fill( [bdata_vel_time, fliplr(bdata_vel_time)], ... 
        [(mean_left_vel_side+sem_left_vel_side)' fliplr((mean_left_vel_side-sem_left_vel_side)')], ...
        rgb('Salmon'));
set(fh, 'EdgeColor', 'None');


p1 = plot(bdata_vel_time, mean_left_vel_side, 'color', ac.LEFT_CLR);
%ylim([-0.02 0.02]);

yy = ylim;
y_min = yy(1); y_max = yy(2);
hh = fill([ first_stim first_stim last_stim last_stim ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

xlim([0, bdata_vel_time(end)]);
xlabel('Time (s)');
ylabel('Velocity (au/s)');
title('Side velocity');

subplot(3,1,3);
hold on;

mean_left_vel_yaw = squeeze(mean(kept_trials{ac.LEFT}(:,ac.VEL_YAW,:)));

sem_left_vel_yaw = squeeze(std(kept_trials{ac.LEFT}(:,ac.VEL_YAW,:),1)) ./ sqrt(size(kept_trials{ ac.LEFT }(:,ac.VEL_YAW,:),1));

fh = fill( [bdata_vel_time, fliplr(bdata_vel_time)], ... 
        [(mean_left_vel_yaw+sem_left_vel_yaw)' fliplr((mean_left_vel_yaw-sem_left_vel_yaw)')], ...
        rgb('Salmon'));
set(fh, 'EdgeColor', 'None');

p1 = plot(bdata_vel_time, mean_left_vel_yaw, 'color', ac.LEFT_CLR);
%ylim([-0.1 0.1]);

xlim([0, bdata_vel_time(end)]);
xlabel('Time (s)');
ylabel('Velocity (au/s)');
title('Yaw velocity');

yy = ylim;
y_min = yy(1); y_max = yy(2);
hh = fill([ first_stim first_stim last_stim last_stim ],[y_min y_max y_max y_min ], rgb('Wheat'));
set(gca,'children',circshift(get(gca,'children'),-1));
set(hh, 'EdgeColor', 'None');

saveas(f, [analysis_path '/avg_velocity_exclude_zero_vel_one_side_only_sid_' num2str( sid ) '.fig']);
saveas(f, [analysis_path '/avg_velocity_exclude_zero_vel_one_side_only_sid_' num2str( sid ) '.png']);

end


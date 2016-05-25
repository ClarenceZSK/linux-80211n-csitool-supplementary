close all;
clear;
clc;

%csi_cells = read_bf_file('D:/dataset/wifi/20151028/log3.txt');
csi_cells = read_bf_file('~/rosbag/csi_data/csi_outdoor.txt');
K = length(csi_cells)
subCarrierId = 5;
csiSample = zeros(3, K);


rssi_a = zeros(1, K);
rssi_b = zeros(1, K);
rssi_c = zeros(1, K);
rssi = zeros(1, K);
%% M: Ntx, N: Nrx, S: sub-carriers
% for i = 1 : length(csi_cells)
	% csi = csi_cells{i}.csi;
	% scaled_csi = get_scaled_csi(csi_cells{i});
	% [M, N, S] = size(csi);	
	% i 
	% time =  csi_cells{i}.timestamp_low
	% bfee_counts(i) =  csi_cells{i}.bfee_count
	% snr = get_eff_SNRs(csi);
	% %snr_sm = get_eff_SNRs_sm(csi);
	% rssi_a(i) = csi_cells{i}.rssi_a;
	% rssi_b(i) = csi_cells{i}.rssi_b;
	% rssi_c(i) = csi_cells{i}.rssi_c;
	% rssi(i) = get_total_rss(csi_cells{i});
	% %csiSample(:, i) = reshape(csi(1, :, subCarrierId), N, 1);
% end


cmap = hsv(3); 
fig = figure;

%show csi phase 
for i = 2000 : length(csi_cells)
	csi = csi_cells{i}.csi;
	scaled_csi = get_scaled_csi(csi_cells{i});
	[Ntx, Nrx, N] = size(csi);
	if Nrx ~= 3
		continue;
	end
	
	
	
	hold on;
	ax1 = subplot(2, 2, 1);
	cla(ax1, 'reset');
	hold on;
	for j = 1 : Nrx
		csi_mimo = reshape(csi(1, j, :), 1, N);
		plot(abs(csi_mimo), 'Color', cmap(j, :));
	end
	title('amplitute')
	legend('1', '2', '3');
	hold off;
	
	ax2 = subplot(2, 2, 2);
	cla(ax2, 'reset');
	hold on
	for j = 1 : Nrx
		csi_mimo = reshape(csi(1, j, :), 1, N);
		csi_mimo = TOF_sanitization(csi_mimo);
		plot(angle(csi_mimo), 'Color', cmap(j, :));
	end
	title('phase');
	legend('1', '2', '3');
	hold off;
	
	
	csi_mimo1 = reshape(csi(1, 1, :), 1, N);
	csi_mimo2 = reshape(csi(1, 2, :), 1, N);
	csi_mimo3 = reshape(csi(1, 3, :), 1, N);
	
	csi_mimo1 = TOF_sanitization(csi_mimo1);
	csi_mimo2 = TOF_sanitization(csi_mimo2);
	csi_mimo3 = TOF_sanitization(csi_mimo3);
	
	%relative_csi_12 = csi_mimo2.*conj(csi_mimo1);
	%relative_csi_23 = csi_mimo3.*conj(csi_mimo2);
	relative_csi_12 = csi_mimo3.*conj(csi_mimo1);
	relative_csi_23 = csi_mimo2.*conj(csi_mimo3);
	
	ax3 = subplot(2, 2, 3);
	cla(ax3, 'reset');
	hold on
	plot(abs(relative_csi_12), 'Color', cmap(1, :));
	plot(abs(relative_csi_23), 'Color', cmap(2, :));
	legend('relative 1&2', 'relative 2 & 3')
	title('relative amplitute');
	hold off;
	
	ax4 = subplot(2, 2, 4);
	cla(ax4, 'reset');
	hold on
	plot(angle(relative_csi_12), 'Color', cmap(1, :));
	plot(angle(relative_csi_23), 'Color', cmap(2, :));
	axis([0 30 -pi pi ])
	legend('relative 1&2', 'relative 2 & 3')
	title('relative phase');
	hold off;
	
	filename = sprintf('./plots/relative_phasecsi_outdoor_%d.png', i);
	print('-dpng', filename);
	%pause(0.5);
end



figure(1); hold on;
title('rssi');
plot(rssi_a, 'r');
plot(rssi_b, 'g');
plot(rssi_c, 'b');
plot(rssi, 'k')
legend('rssi a', 'rssi b', 'rssi c', 'rssi');
hold off;


cmap = hsv(N);
figure(2); hold on;
title('csi amplitute')
for i = 1 : N
	plot(abs(csiSample(i, :)), 'Color', cmap(i, :));
end
hold off;

cmap = hsv(N);
figure(3); hold on;
title('csi phase')
for i = 1 : N
	plot(angle(csiSample(i, :)), 'Color', cmap(i, :));
end
hold off;

h = figure(4);
for i = 1 : K
	csi = csi_cells{i}.csi;
	[M, N, S] = size(csi);
	csi = reshape(csi(1, :, :), N, S);
	subplot(2, 1, 1); hold on;
	for j = 1 : N
		plot(abs(csi(j, :)), 'Color', cmap(j, :));
	end
	hold off;
	
	subplot(2, 1, 2); hold on;
	for j = 1 : N
		plot(angle(csi(j, :)), 'Color', cmap(j, :));
	end
	hold off;
	pause(2.0);
end





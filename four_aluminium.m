clear; clc; close all;

% -------------------------------
% Table 2 Data (Side Drilled Holes)
% -------------------------------
defect_num = 1:16;
diameter = [0.7, 0.7, 0.7, 0.7, 0.8, 0.7, 0.8, 1.0, 1.2, 1.0, 0.8, 0.7, 0.6, 0.8, 1.0, 1.2];
depth = [15, 13, 10.5, 8.5, 6.5, 4.5, 6.5, 8.2, 10.5, 10.4, 10.5, 10.4, 10.4, 8.6, 6.5, 5];

% -------------------------------
% Simulated image data (TDTE vs SAFT)
% -------------------------------
[x, y] = meshgrid(0:0.5:100, 0:0.5:50);

% Defect positions (for simulation)
defect_pos = [30, 25; 70, 25]; % For aluminum
defect_pos_comp = [20,15; 40,25; 60,35; 80,20]; % For composite

% TDTE image (clean)
Z_tdte_al = exp(-((x-30).^2 + (y-25).^2)/200) + exp(-((x-70).^2 + (y-25).^2)/200);
Z_tdte_2MHz = zeros(size(x));
for i=1:size(defect_pos_comp,1)
    Z_tdte_2MHz = Z_tdte_2MHz + exp(-((x-defect_pos_comp(i,1)).^2 + (y-defect_pos_comp(i,2)).^2)/150);
end

% SAFT image (noisier)
Z_saft_2MHz = Z_tdte_2MHz * 0.7 + 0.1*randn(size(Z_tdte_2MHz));
Z_saft_2MHz(Z_saft_2MHz<0) = 0;

% 5MHz images (higher resolution)
[x5, y5] = meshgrid(0:0.2:100, 0:0.2:50);
Z_tdte_5MHz = zeros(size(x5));
for i=1:size(defect_pos_comp,1)
    Z_tdte_5MHz = Z_tdte_5MHz + exp(-((x5-defect_pos_comp(i,1)).^2 + (y5-defect_pos_comp(i,2)).^2)/100);
end
Z_saft_5MHz = Z_tdte_5MHz * 0.65 + 0.05*randn(size(Z_tdte_5MHz));
Z_saft_5MHz(Z_saft_5MHz<0) = 0;

% Echodynamic curves (depth profile)
depth_axis = 0:0.5:50;
tdte_curve = sum(Z_tdte_2MHz, 2);
saft_curve = sum(Z_saft_2MHz, 2);
tdte_curve_5MHz = sum(Z_tdte_5MHz, 2);
saft_curve_5MHz = sum(Z_saft_5MHz, 2);

% B-scan simulation
bscan = 0.05*randn(200,100);
bscan(50:60, 30:70) = 0.8;
bscan(120:130, 20:80) = 0.6;


figure('Name', 'Fig 1: Aluminum imaging', 'NumberTitle', 'off', 'Position', [100 100 900 400]);

% (a) Schematic
subplot(1,2,1);
rectangle('Position', [0,0,100,50], 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k');
hold on;
plot([0 100], [40 40], 'k--', 'LineWidth', 1.5); % Array position
scatter([30,70], [25,25], 200, 'k', 'filled');
text(30, 22, 'Hole 1', 'FontSize', 11, 'HorizontalAlignment', 'center');
text(70, 22, 'Hole 2', 'FontSize', 11, 'HorizontalAlignment', 'center');
text(50, 42, 'Array position', 'FontSize', 10, 'HorizontalAlignment', 'center');
axis equal; xlim([0 100]); ylim([0 50]);
xlabel('Width (mm)'); ylabel('Depth (mm)');
title('(a) Position of the holes');

% (b) Topological energy image
subplot(1,2,2);
imagesc([0 100], [0 50], Z_tdte_al);
colormap hot; colorbar; hold on;
plot([0 100], [40 40], 'w--', 'LineWidth', 1.5);
text(50, 42, 'Array position', 'Color', 'white', 'FontSize', 10, 'HorizontalAlignment', 'center');
xlabel('Width (mm)'); ylabel('Depth (mm)');
title('(b) Topological energy image');


figure('Name', 'Fig 2: Composite (2 MHz)', 'NumberTitle', 'off', 'Position', [100 100 1200 700]);

% (a) Material section
subplot(2,3,1);
imagesc(0:100, 0:50, rand(101,201)*0.3);
colormap gray; title('(a) Section of tested composite material');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (b) TDTE image
subplot(2,3,2);
imagesc(0:100, 0:50, Z_tdte_2MHz);
colormap hot; colorbar; title('(b) TDTE (2 MHz)');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (c) SAFT image
subplot(2,3,3);
imagesc(0:100, 0:50, Z_saft_2MHz);
colormap hot; colorbar; title('(c) SAFT (2 MHz)');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (d) Echodynamic curves
subplot(2,3,4:6);
plot(depth_axis, tdte_curve/max(tdte_curve), 'b-', 'LineWidth', 2); hold on;
plot(depth_axis, saft_curve/max(saft_curve), 'r--', 'LineWidth', 2);
xlabel('Depth (mm)'); ylabel('Normalized amplitude');
title('(d) Echodynamic curves: TDTE (top/blue) vs SAFT (bottom/red)');
legend('TDTE', 'SAFT', 'Location', 'northeast');
grid on;

figure('Name', 'Fig 3: B-scan & TDTE', 'NumberTitle', 'off', 'Position', [100 100 900 400]);

% (a) B-scan
subplot(1,2,1);
imagesc(1:100, 1:200, bscan);
colormap gray; title('(a) B-scan (front echo removed)');
xlabel('Sensor element'); ylabel('Time sample');

% (b) TDTE image
subplot(1,2,2);
imagesc(0:100, 0:50, Z_tdte_2MHz);
colormap hot; colorbar; title('(b) TDTE image of inspected zone');
xlabel('Width (mm)'); ylabel('Depth (mm)');

figure('Name', 'Fig 4: Composite (5 MHz)', 'NumberTitle', 'off', 'Position', [100 100 1200 700]);

% (a) Material section
subplot(2,3,1);
imagesc(0:100, 0:50, rand(101,501)*0.3);
colormap gray; title('(a) Section of tested composite material');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (b) TDTE image (5 MHz)
subplot(2,3,2);
imagesc(0:100, 0:50, Z_tdte_5MHz);
colormap hot; colorbar; title('(b) TDTE (5 MHz)');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (c) SAFT image (5 MHz)
subplot(2,3,3);
imagesc(0:100, 0:50, Z_saft_5MHz);
colormap hot; colorbar; title('(c) SAFT (5 MHz)');
xlabel('Width (mm)'); ylabel('Depth (mm)');

% (d) Echodynamic curves
subplot(2,3,4:6);
depth_axis_5 = linspace(0,50,size(Z_tdte_5MHz,1));
plot(depth_axis_5, tdte_curve_5MHz/max(tdte_curve_5MHz), 'b-', 'LineWidth', 2); hold on;
plot(depth_axis_5, saft_curve_5MHz/max(saft_curve_5MHz), 'r--', 'LineWidth', 2);
xlabel('Depth (mm)'); ylabel('Normalized amplitude');
title('(d) Echodynamic curves: TDTE (blue) vs SAFT (red)');
legend('TDTE', 'SAFT', 'Location', 'northeast');
grid on;



figure('Name', 'Table 2: Defects', 'NumberTitle', 'off');
scatter(depth, diameter, 200, 'b', 'filled');
text(depth, diameter+0.05, string(defect_num), 'FontSize', 9);
xlabel('Depth (mm)'); ylabel('Diameter (mm)');
title('Table 2: Side drilled holes in composite');
grid on;


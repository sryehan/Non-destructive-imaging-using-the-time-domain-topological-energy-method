% MATLAB script to recreate realistic TDTE imaging
% Author: Shahariar Ryehan (Using data from Dominguez et al. 2010) 

%% 1. Parameters & Grid Setup
width_total = 90;   % mm
depth_total = 18;   % mm
dx = 0.1;           % Resolution
[X, Y] = meshgrid(0:dx:width_total, 0:dx:depth_total);
Energy = zeros(size(X));

%% 2. Data from Table 2
% Column 1: Width(x), Column 2: Depth(y), Column 3: Diameter(d), Column 4: Quality Factor
% Quality Factor (0.1 to 1.0) is used to show the weakness of holes 3 and 11
hole_data = [
    10, 15.0, 0.7, 0.4;   % Defect 1
    13, 13.0, 0.7, 0.5;   % Defect 2
    16, 10.5, 0.7, 0.2;   % Defect 3 (Badly imaged in paper) 
    23,  8.5, 0.7, 0.6;   % Defect 4
    28,  6.5, 0.7, 0.7;   % Defect 5
    33,  4.5, 0.7, 0.8;   % Defect 6
    38,  6.5, 0.8, 0.9;   % Defect 7
    43,  8.2, 1.0, 0.7;   % Defect 8
    48, 10.5, 1.2, 1.0;   % Defect 9 (Strong)
    53, 10.4, 1.0, 0.9;   % Defect 10
    58, 10.5, 0.8, 0.3;   % Defect 11 (Badly imaged) 
    63, 10.4, 0.7, 0.5;   % Defect 12
    68, 10.4, 0.6, 0.4;   % Defect 13 (Broken drill) 
    74,  8.6, 0.8, 0.8;   % Defect 14
    79,  6.5, 1.0, 0.9;   % Defect 15
    85,  5.0, 1.2, 1.0    % Defect 16
];

%% 3. Generating Base Energy with Realistic Smearing
for i = 1:size(hole_data, 1)
    x0 = hole_data(i,1); y0 = hole_data(i,2); 
    d = hole_data(i,3); q = hole_data(i,4);
    
    % Anisotropy effect: Horizontal smearing (sigma_x > sigma_y)
    sigma_x = d * 1.5; 
    sigma_y = d * 0.8;
    
    spot = q * exp(-((X-x0).^2/(2*sigma_x^2) + (Y-y0).^2/(2*sigma_y^2)));
    Energy = Energy + spot;
end

%% 4. Adding Structural & Measurement Noise 
% Structural noise (Random stains)
stains = 0.15 * rand(size(X)) .* (sin(X/2) .* cos(Y/2)); 
% White measurement noise
white_noise = 0.05 * rand(size(X));

Energy = Energy + stains + white_noise;
Energy = Energy / max(Energy(:)); % Normalization

%% 5. Plotting Results
figure('Name', 'Realistic TDTE Simulation', 'Color', 'w', 'Position', [100 100 800 600]);

% TDTE Image (Like Fig 2b/4b) 
subplot(2,1,1);
imagesc([0 width_total], [0 depth_total], Energy);
colormap(flipud(gray)); 
colorbar;
title('Simulated TDTE Image with Structural Noise');
ylabel('depth (mm)');
set(gca, 'YDir', 'reverse');
axis tight;

% Echodynamic Curve (Like Fig 2d/4d) 
subplot(2,1,2);
echodynamic = max(Energy, [], 1); 
plot(0:dx:width_total, echodynamic, 'b', 'LineWidth', 1.1);
title('Echodynamic Curve (Realistic Version)');
xlabel('width (mm)');
ylabel('Normalized Energy');
grid on;

axis([0 90 0 1.1]);

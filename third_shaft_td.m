%% =========================================================
%  FULL TDTE PIPELINE (Synthetic)
%  B-scan -> SAFT -> TDTE
%  Inspired by Dominguez & Gibiat (Ultrasonics, 2010)
% =========================================================

clc; clear; close all;

%% ---------------------------------------------------------
% 1. Defect data (Table-2 inspired)
% ---------------------------------------------------------
nDef = 16;

diameter = [0.7 0.7 0.7 0.7 0.7 0.7 0.8 1.0 ...
            1.2 1.0 0.8 0.7 0.6 0.8 1.0 1.2];

depth = [15 13 10.5 8.5 6.5 4.5 6.5 8.2 ...
         10.5 10.4 10.5 10.4 10.4 8.6 6.5 5];

x_def = linspace(8,60,nDef);     % lateral defect positions (mm)

%% ---------------------------------------------------------
% 2. B-scan generation (Numéro de traducteur)
% ---------------------------------------------------------
nTrans = 64;                     % array elements
z = linspace(0,18,600).';        % depth / time axis (COLUMN)

Bscan = zeros(length(z), nTrans);

for tr = 1:nTrans
    for i = 1:nDef
        delay = depth(i) + 0.04*abs(tr - x_def(i));
        echo  = diameter(i) * exp(-(z-delay).^2/0.3);
        Bscan(:,tr) = Bscan(:,tr) + echo;
    end
end

% Front surface echo (realistic)
Bscan = Bscan + 3*exp(-(z-1).^2/0.05);

%% ---- Plot B-scan (Fig-3a style)
figure
imagesc(1:nTrans, z, log(abs(Bscan)+1))
set(gca,'YDir','reverse')
xlabel('Numéro de traducteur')
ylabel('Temps (\mus) / Profondeur (mm)')
title('B-scan ultrasonic image')
colorbar
colormap(jet)

%% ---------------------------------------------------------
% 3. SAFT reconstruction (delay-and-sum)
% ---------------------------------------------------------
x_img = linspace(0,70,200);
z_img = linspace(0,18,200);
[X,Z] = meshgrid(x_img,z_img);

SAFT = zeros(size(X));

for ix = 1:length(x_img)
    for iz = 1:length(z_img)
        for tr = 1:nTrans
            travel = Z(iz,ix) + 0.04*abs(tr - X(iz,ix));
            [~,idz] = min(abs(z - travel));
            SAFT(iz,ix) = SAFT(iz,ix) + Bscan(idz,tr);
        end
    end
end

SAFT = SAFT / max(SAFT(:));

%% ---- Plot SAFT image (Fig-3c / Fig-4c)
figure
imagesc(x_img, z_img, SAFT)
set(gca,'YDir','reverse')
xlabel('Width (mm)')
ylabel('Depth (mm)')
title('SAFT reconstruction')
colorbar
colormap(jet)

%% ---------------------------------------------------------
% 4. TDTE image (topological energy – synthetic)
%    g0(x) = ∫ |u0|^2 |v0|^2 dt (conceptual)
% ---------------------------------------------------------
TDTE = zeros(size(X));

for i = 1:nDef
    TDTE = TDTE + diameter(i)^2 .* ...
        exp(-((X-x_def(i)).^2 + (Z-depth(i)).^2)/1.2);
end

TDTE = TDTE / max(TDTE(:));

%% ---- Plot TDTE image (Fig-3b / Fig-4b)
figure
imagesc(x_img, z_img, TDTE)
set(gca,'YDir','reverse')
xlabel('Width (mm)')
ylabel('Depth (mm)')
title('TDTE energy image')
colorbar
colormap(jet)

%% ---------------------------------------------------------
% 5. Echodynamic curves (TDTE vs SAFT)
% ---------------------------------------------------------
figure

subplot(2,1,1)
plot(z_img, sum(TDTE,2),'LineWidth',1.5)
set(gca,'YDir','reverse')
xlabel('Depth (mm)')
ylabel('Energy')
title('TDTE echodynamic curve')
grid on

subplot(2,1,2)
plot(z_img, sum(SAFT,2),'LineWidth',1.5)
set(gca,'YDir','reverse')
xlabel('Depth (mm)')
ylabel('Amplitude')
title('SAFT echodynamic curve')
grid on

%% ---------------------------------------------------------
disp('FULL B-scan → SAFT → TDTE pipeline completed successfully.');

%% clear environment
clear
clf('reset')
clc


%% figure configuration
% create figure
fig = figure(1);
view(3);
grid on;
hold on;

% axis
axis([0 1 300 400 0 5]);
xticks(0:0.1:1);

% labels
xlabel('Composition, x-y [-]');
ylabel('Temperature, T [K]');
zlabel('Pressure, P [bar]');


%% parameters / givens 
% define range
n = 11;
T_range = linspace(300, 400, n);

% mesh grids for x, T, P
[x, T_mesh] = meshgrid(linspace(0, 1, n), T_range);
[x, P_mesh] = meshgrid(linspace(0, 1, n), linspace(0, 5, n));

% ethanol vapor pressure
p_e = @(T) 10 .^ (4.92531 - 1432.526 ./ (T - 61.819));

% water vapor pressure
p_w = @(T) 10 .^ (3.55959 - 643.748 ./ (T - 198.043));


%% boiling curves for pure components
% pure water (@x=0)
boiling_w = p_w(T_range);
plot3(zeros(1, n), T_range, boiling_w);

% pure ethanol
boiling_e = p_e(T_range);
plot3(ones(1, n), T_range, boiling_e);


%% isothermal diagram
for i=1:n

    % temperature
    T_iso = T_mesh(i, 1);

    % iso-therm
    if i == n-1
        iso_therm = mesh(x(1, :), T_iso*ones(n), P_mesh, 'FaceAlpha', 0.75, 'LineStyle', 'none');
    end
    
    % liquidus line
    P = p_w(T_iso) + x(1, :) .* (p_e(T_iso) - p_w(T_iso));
    plot3(x(1, :), T_iso*ones(1, n), P, 'b');

    % vaporous curve
    y = x(1, :) .* p_e(T_iso) ./ P;
    plot3(y, T_iso*ones(1, n), P, 'r');

end

%% isobaric diagram
% pressure
P_iso = 1;

%iso-bar
iso_bar = mesh(x(1, :), T_mesh, P_iso*ones(n));
iso_bar.FaceAlpha = 0.75;
iso_bar.LineStyle = 'none';

% calculate the bubble points for all composition range
for i=1:n
   
    x_bp(i) = x(1, i);
    T_bp(i) = fsolve( @(T) ( P_iso - p_e(T).*x_bp(i) - p_w(T).*(1-x_bp(i)) ), 360);
    y_bp(i) = x_bp(i) .* p_e(T_bp(i)) ./ P_iso;
    
end

% liquidus curve
plot3(x_bp, T_bp, P_iso*ones(1, n), 'b--');

% vaporous curve
plot3(y_bp, T_bp, P_iso*ones(1, n), 'r--');


%% surfaces / 3D diagram
% liquidus surface
P = p_w(T_mesh) + x .* (p_e(T_mesh) - p_w(T_mesh));
liq_surf = surf(x, T_mesh, P);
liq_surf.FaceAlpha = 0.5;
liq_surf.LineStyle = 'none';
liq_surf.FaceColor = 'b';

% vaporous surface
y = x .* p_e(T_mesh) ./ P;
vap_surf = surf(y, T_mesh, P);
vap_surf.FaceAlpha = 0.5;
vap_surf.LineStyle = 'none';
vap_surf.FaceColor = 'r';






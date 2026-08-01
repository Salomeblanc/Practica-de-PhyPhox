% =========================================================================
% PROCESAMIENTO DIGITAL DE SEÑALES - ESTIMACIÓN DE ACELERACIÓN CENTRÍPETA
% UNIVERSIDAD MILITAR NUEVA GRANADA - COMUNICACIONES DIGITALES
% =========================================================================
clear; clc; close all;

% 1. Definición del archivo de datos
archivo = 'Data.csv';

% Verificar si el archivo existe en la carpeta actual de trabajo
if ~exist(archivo, 'file')
    error(['No se encontró el archivo "%s". Asegúrate de que Matlab ' ...
           'esté apuntando a la carpeta correcta y que el archivo esté allí.'], archivo);
end

% 2. Opciones de importación automatizada
% Usamos 'preserve' para evitar problemas con los caracteres especiales de los encabezados
opts = detectImportOptions(archivo, 'FileType', 'text');
opts.VariableNamingRule = 'preserve'; 
data = readtable(archivo, opts);

% 3. Extracción de vectores de muestreo por índice de columna
% Columna 1: Tiempo (s) | Columna 2: Velocidad Angular (rad/s) | Columna 3: Aceleración (m/s^2)
time = data{:, 1};     
omega = data{:, 2};    
ac = data{:, 3};       

% 4. Procesamiento Digital: Linealización de la variable angular (x = w^2)
omega_sq = omega.^2;

% 5. Estimación de Parámetros mediante Mínimos Cuadrados Ordinarios (MCO)
% Ajuste polinomial de primer grado (y = p1*x + p2)
coeficientes = polyfit(omega_sq, ac, 1);
r_exp = coeficientes(1);       % La pendiente representa el radio estimado
intercepto = coeficientes(2);   % El intercepto representa el offset del sistema

% 6. Despliegue de Resultados de Telemetría en la Consola
fprintf('\n========================================================\n');
fprintf('     RESULTADOS DEL PROCESAMIENTO DE SEÑALES (MCO)      \n');
fprintf('========================================================\n');
fprintf('Radio de giro estimado (Pendiente): %.4f metros (%.2f cm)\n', r_exp, r_exp*100);
fprintf('Offset de continua (Intercepto):   %.4f m/s^2\n', intercepto);
fprintf('Total de muestras discretas procesadas: %d muestras\n', length(time));
fprintf('========================================================\n\n');

% 7. Generación y Configuración Estética de la Gráfica para Formato IEEE
figure('Color', [1 1 1], 'Units', 'inches', 'Position', [2, 2, 6.5, 4.8]);

% Graficar la dispersión de los datos discretos reales con ruido mecánico
plot(omega_sq, ac, 'o', ...
     'MarkerEdgeColor', [0, 0.4470, 0.7410], ...
     'MarkerFaceColor', [0, 0.4470, 0.7410], ...
     'MarkerSize', 4);
hold on;

% Graficar la recta ajustada por mínimos cuadrados
y_ajustada = polyval(coeficientes, omega_sq);
plot(omega_sq, y_ajustada, 'r-', 'LineWidth', 2);

% Propiedades del gráfico
title('Aceleración Centrípeta vs. Velocidad Angular al Cuadrado', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('\omega^2 (rad^2/s^2)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('a_c (m/s^2)', 'FontSize', 10, 'FontWeight', 'bold');
grid on;
set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.5);

% Leyenda científica
leyenda_texto = { 'Datos discretos reales (Phyphox)', ...
                  sprintf('Ajuste lineal por MCO (r_{exp} = %.3f m)', r_exp) };
legend(leyenda_texto, 'Location', 'northwest', 'FontSize', 9);

% 8. Exportar la imagen en formato PNG de alta resolución (300 DPI) para el informe
exportgraphics(gcf, 'grafica_resultados_matlab.png', 'Resolution', 300);
fprintf('Gráfica exportada exitosamente como "grafica_resultados_matlab.png".\n\n');
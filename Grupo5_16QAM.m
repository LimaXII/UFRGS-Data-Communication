% Trabalho Final - Grupo 5
%
% Especifica��es:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema completo de comunica��o de dados, contendo, no m�nimo, 
%  os seguintes componentes: (1) Fonte de informa��o, 
%  (2) Codificador de canal, (3) Modula��o, (4) Ru�do,
%  (5) Demodula��o, (6) Decodificador de canal, (7) Receptor de informa��o
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e 
%  frame error rate (FER) variando par�metros do sistema
%  2) Avalia��o para um intervalo de Eb/N0
%  3) Analisar a efici�ncia de c�digos e modula��es
%  utilizadas no padr�o IEEE 802.11
%
% Luccas da Silva Lima - 00324683 
% Matheus Almeida Silva - 00316326
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------


clear;
close;
num_b = 1000000; % Número de bits a serem simulados
bits = randi([0 1], 1, num_b); % Geração de bits aleatórios
Eb_N0_dB = 0:1:9; % Faixa de Eb/N0 em dB
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); % Faixa de Eb/N0 linearizada
ber = zeros(size(Eb_N0_lin)); % Pré-alocação do vetor de BER
fer = zeros(size(Eb_N0_lin)); % Pré-alocação do vetor de FER
Eb = 1; % Energia por bit para a modulação utilizada
num_bits_frame = 2300 * 8; % Tamanho do quadro em bits (2300 bytes)

% Modulação (16-QAM)
mod_order = 16; % Ordem da modulação

% Agrupando bits para formar símbolos
symbols_per_bit = log2(mod_order); % Número de bits por símbolo
num_symbols = num_b / symbols_per_bit; % Número de símbolos
tx_bits = reshape(bits, symbols_per_bit, num_symbols).'; % Reshape para vetor de símbolos
decimal_symbols = bi2de(tx_bits, 'left-msb'); % Conversão de bits para decimal
mod_symbols = qammod(decimal_symbols, mod_order); % Modulação 16-QAM (sem argumentos adicionais)

% Normalização da potência média do símbolo
mod_symbols = mod_symbols / sqrt(mean(abs(mod_symbols).^2)); % Normalizar para potência unitária

for i = 1:length(Eb_N0_lin)
    NP = Eb / Eb_N0_lin(i); 
    NA = sqrt(NP / 2);

    % Adição de ruído ao sinal transmitido
    noise = NA * (randn(size(mod_symbols)) + 1j * randn(size(mod_symbols)));
    rx_symbols = mod_symbols + noise; % Sinal recebido

    % Demodulação
    rx_decimal_symbols = qamdemod(rx_symbols, mod_order); % Demodulação 16-QAM
    rx_bits = de2bi(rx_decimal_symbols, symbols_per_bit, 'left-msb').'; % Conversão de volta para bits
    rx_bits = rx_bits(:).'; % Vetorizar os bits recebidos

    % Cálculo de BER
    bit_errors = sum(bits ~= rx_bits);
    ber(i) = bit_errors / num_b;

    % Cálculo de FER
    fer(i) = 1 - (1 - ber(i))^num_bits_frame;
end

% Plotagem dos resultados
figure;
semilogy(Eb_N0_dB, ber, 'b-o', 'LineWidth', 1.5); hold on;
semilogy(Eb_N0_dB, fer, 'r-s', 'LineWidth', 1.5);
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Taxa de erro');
title('Desempenho do sistema 16-QAM');
legend('BER', 'FER');

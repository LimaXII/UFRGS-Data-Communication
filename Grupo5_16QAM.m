% Trabalho Final - Grupo 5
%
% Especificações:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema completo de comunicação de dados, contendo, no mï¿½nimo, 
%  os seguintes componentes: (1) Fonte de informação, 
%  (2) Codificador de canal, (3) Modulação, (4) Ruído,
%  (5) Demodulação, (6) Decodificador de canal, (7) Receptor de informação
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e 
%  frame error rate (FER) variando parámetros do sistema
%  2) Avaliação para um intervalo de Eb/N0
%  3) Analisar a eficiência de códigos e modulações
%  utilizadas no padrão IEEE 802.11
%
% Luccas da Silva Lima - 00324683 
% Matheus Almeida Silva - 00316326
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------


clear;
close;
num_b = 1000000; % Número de bits a serem simulados (garanta que seja múltiplo de 4 para 16-QAM)
frame_bits = 18400; % Número de bits por quadro (2300 bytes) para FER
Eb_N0_dB = 0:1:9; % Faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB / 10); % Eb/N0 linearizado
ber = zeros(3, length(Eb_N0_lin)); % BER para as 3 versões
fer = zeros(3, length(Eb_N0_lin)); % FER para as 3 versões
Eb = 0.25; % Energia por bit para 16QAM
NP = Eb ./ Eb_N0_lin; % Potência do ruído
NA = sqrt(NP); % Amplitudes do ruído

%Configurações LDPC
N = 1944;  % Tamanho do código
R = 1/2;   % Taxa do código
info_length = N * R;

% Criar o objeto LDPC
aux_ldpc = LDPCCode(N, info_length);

% Carregar o código LDPC correspondente ao H_1944_1_2
aux_ldpc.load_wifi_ldpc(N, R);

% Exibir a matriz H gerada
H = sparse(logical(aux_ldpc.H));

% Inicialização do ldpc
ldpcEncoder = comm.LDPCEncoder(H);
ldpcDecoderHard = comm.LDPCDecoder(H, 'DecisionMethod', 'Hard decision');
ldpcDecoderSoft = comm.LDPCDecoder(H, 'DecisionMethod', 'Soft decision');

% Modulação (16-QAM)
mod_order = 16; % Ordem da modulação
symbols_per_bit = log2(mod_order); % Número de bits por símbolo

% 1. Fonte de informação
data = randi([0 1], num_b, 1); % Gera bits aleatórios
blocks = ceil(length(data) / info_length); % Número de blocos (iteração por info_length bits)
data = [data; zeros(blocks * info_length - length(data), 1)];% Ajusta o tamanho de 'data' para múltiplo de 'info_length' se necessário
data_reshaped = reshape(data, info_length, blocks);% Reshape 'data' para que cada coluna tenha 'info_length' bits

for i = 1:length(Eb_N0_lin)
    num_bit_errors = zeros(3, 1);
    for j = 1:blocks
        % 1. Seleciona o bloco atual de bits
        bits = logical(data_reshaped(:, j)); % Pega o bloco de info_length bits

        % 2. Codificação de canal LDPC
        codedBits = step(ldpcEncoder, bits);

        % 3. Modulação (BPSK com símbolos complexos)
        % Agrupando bits para formar símbolos - Sem Codificação
        num_symbols = length(bits) / symbols_per_bit; % Número de símbolos
        tx_bits = reshape(bits, symbols_per_bit, num_symbols).'; % Reshape para vetor de símbolos
        decimal_symbols = bi2de(tx_bits, 'left-msb'); % Conversão de bits para decimal
        mod_symbols_uncode = qammod(decimal_symbols, mod_order); % Modulação 16-QAM (sem argumentos adicionais)

        % Agrupando bits para formar símbolos - LDPC
        num_symbols_ldpc = length(codedBits) / symbols_per_bit; % Número de símbolos
        tx_bits_ldpc = reshape(codedBits, symbols_per_bit, num_symbols_ldpc).'; % Reshape para vetor de símbolos
        decimal_symbols_ldpc = bi2de(tx_bits_ldpc, 'left-msb'); % Conversão de bits para decimal
        mod_symbols_ldpc = qammod(decimal_symbols_ldpc, mod_order); % Modulação 16-QAM (sem argumentos adicionais)

        % 4. Ruído AWGN (complexo)
        % Ruído AWGN (complexo) - Sem Código
        noise = NA(i) * (randn(size(mod_symbols_uncode)) + 1j * randn(size(mod_symbols_uncode)));
        rx_symbols_uncode = mod_symbols_uncode + noise; % Sinal recebido sem ldpc
        
        % Ruído AWGN (complexo) - LDPC
        noise = NA(i) * (randn(size(mod_symbols_ldpc)) + 1j * randn(size(mod_symbols_ldpc)));
        rx_symbols_ldpc = mod_symbols_ldpc + noise; % Sinal recebido sem ldpc

        % 5. Demodulação
        % Demodulação Sem Código
        rx_decimal_symbols_uncode = qamdemod(rx_symbols_uncode, mod_order); % Demodulação 16-QAM
        rx_bits_uncode = de2bi(rx_decimal_symbols_uncode, symbols_per_bit, 'left-msb').'; % Conversão de volta para bits
        rx_bits_uncode = rx_bits_uncode(:); % Vetorizar os bits recebidos 
        
        % Demodulação LDPC
        rx_decimal_symbols_ldpc = qamdemod(rx_symbols_ldpc, mod_order); % Demodulação 16-QAM
        rx_bits_ldpc = de2bi(rx_decimal_symbols_ldpc, symbols_per_bit, 'left-msb').'; % Conversão de volta para bits
        rx_bits_ldpc = 1 - (rx_bits_ldpc(:))*2; % Vetorizar os bits recebidos 
        
        % 6. Decodificação de canal
        decodedBitsHard = step(ldpcDecoderHard, rx_bits_ldpc);
        decodedBitsSoftllr = step(ldpcDecoderSoft, rx_bits_ldpc);
        decodedBitsSoft = decodedBitsSoftllr < -0.9;

        % 7. Cálculo de erros para as 3 versões
        num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= rx_bits_uncode); % Sem LDPC
        num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= decodedBitsHard); % LDPC Hard
        num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= decodedBitsSoft); % LDPC Soft
    end

    display(num_bit_errors);
    % 8. Calcula BER e FER
    ber(:, i) = num_bit_errors / (blocks * info_length);
    fer(:, i) = 1 - (1 - ber(:, i)).^frame_bits; % Calculando o FER a partir do BER
end

% 9. Plots de desempenho
figure;
semilogy(Eb_N0_dB, ber(1, :), 'x-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'Sem LDPC');
hold on;
semilogy(Eb_N0_dB, ber(2, :), 'o-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Hard');
semilogy(Eb_N0_dB, ber(3, :), 's-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Soft');
xlabel('Eb/N0 (dB)');
ylabel('BER');
legend('Location', 'southwest');
grid on;
title('Desempenho do sistema BPSK com LDPC');

figure;
semilogy(Eb_N0_dB, fer(1, :), 'x-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'Sem LDPC');
hold on;
semilogy(Eb_N0_dB, fer(2, :), 'o-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Hard');
semilogy(Eb_N0_dB, fer(3, :), 's-', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Soft');
xlabel('Eb/N0 (dB)');
ylabel('FER');
legend('Location', 'southwest');
grid on;
title('Desempenho do sistema BPSK com LDPC (FER)');


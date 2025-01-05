% -------------------------------------------------------------------------
% Informações relevantes.
% -------------------------------------------------------------------------
% Trabalho Final - Grupo 5
%
% Especificações:
%   5 BPSK, 16-QAM LDPC N = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema completo de comunicação de dados, contendo, no mínimo,
%  os seguintes componentes: (1) Fonte de informação,
%  (2) Codificador de canal, (3) Modulação, (4) Ruído,
%  (5) Demodulação, (6) Decodificador de canal, (7) Receptor de informação
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e
%  frame error rate (FER) variando parâmetros do sistema
%  2) Avaliação para um intervalo de Eb/N0
%  3) Analisar a eficiência de códigos e modulações
%  utilizadas no padrão IEEE 802.11
%
% Luccas da Silva Lima - 00324683 
% Matheus Almeida Silva - 00316326
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Configurações e variáveis.
% -------------------------------------------------------------------------
clear;
close;
num_b = 1000000;        % Número de bits a serem simulados.
frame_bits = 18400;     % Número de bits por quadro (2300 bytes) para FER.
Eb_N0_dB = 0:1:9;       % Faixa de Eb/N0.
Eb_N0_lin = 10 .^ (Eb_N0_dB / 10); % Eb/N0 linearizado.
ber = zeros(3, length(Eb_N0_lin)); % BER para as 3 versões.
fer = zeros(3, length(Eb_N0_lin)); % FER para as 3 versões.
Eb = 1;                 % Energia por bit para BPSK.
NP = Eb ./ Eb_N0_lin;   % Potência do ruído.
NA = sqrt(NP);          % Amplitudes do ruído.

% -------------------------------------------------------------------------
% Configurações do código LDPC
% -------------------------------------------------------------------------
N = 1944;               % Tamanho do código LDPC.
R = 1/2;                % Taxa do código LDPC (1/2 significa que metade dos bits são redundantes).
info_length = N * R;    % Comprimento dos bits de informação.

% -------------------------------------------------------------------------
% Criação e carregamento do LDPC.
% -------------------------------------------------------------------------
aux_ldpc = LDPCCode(N, info_length); % Cria objeto de código LDPC
aux_ldpc.load_wifi_ldpc(N, R);       % Carrega parâmetros LDPC padrão (ex.: Wi-Fi)
H = sparse(logical(aux_ldpc.H));     % Matriz H gerada.

% Inicialização do LDPC.
ldpcEncoder = comm.LDPCEncoder(H);   % Codificador LDPC
% Decodificadores com decisão soft e hard.
ldpcDecoderHard = comm.LDPCDecoder(H, 'DecisionMethod', 'Hard decision');
ldpcDecoderSoft = comm.LDPCDecoder(H, 'DecisionMethod', 'Soft decision');
%Inicialização do BPSK mod e demod.
pskDemodHard = comm.PSKDemodulator(2, 'BitOutput', true, 'DecisionMethod', 'Hard decision');

% -------------------------------------------------------------------------
% Fonte de informação.
% -------------------------------------------------------------------------
data = randi([0 1], num_b, 1);                                  % Gera bits aleatórios.
blocks = ceil(length(data) / info_length);                      % Divide os bits em blocos de tamanho 'info_length'.
data = [data; zeros(blocks * info_length - length(data), 1)];   % Ajusta comprimento para múltiplo de 'info_length'.
data_reshaped = reshape(data, info_length, blocks);             % Reshape 'data' para que cada coluna tenha 'info_length' bits.

% -------------------------------------------------------------------------
% Simulação.
% -------------------------------------------------------------------------
% Loop para diferentes valores de Eb/N0.
for i = 1:length(Eb_N0_lin)                  
    num_bit_errors = zeros(3, 1);
    for j = 1:blocks
        % 1. Seleciona o bloco atual de bits.
        bits = logical(data_reshaped(:, j)); % Pega o bloco de info_length bits.
        
        % 2. Codificação de canal (LDPC).
        codedBits = step(ldpcEncoder, bits);

        % 3. Modulação (BPSK com símbolos complexos).
        modulated_no_code = complex(2 * bits - 1, 0);   % Sem LDPC.
        modulated_ldpc = complex(2 * codedBits - 1, 0); % Com LDPC.

        % 4. Ruído AWGN (complexo).
        noise_no_code = NA(i) * complex(randn(size(modulated_no_code)), randn(size(modulated_no_code))) * sqrt(0.5);
        noise_ldpc = NA(i) * complex(randn(size(modulated_ldpc)), randn(size(modulated_ldpc))) * sqrt(0.5);

        received_no_code = modulated_no_code + noise_no_code;
        received_ldpc = modulated_ldpc + noise_ldpc;

        % 5. Demodulação.
        demod_no_code = (sign(real(received_no_code)) + 1) / 2;
        demod_ldpc = 1 - ((sign(real(received_ldpc)) + 1) / 2) * 2; 
        
        % 6. Decodificação de canal.
        decodedBitsHard = step(ldpcDecoderHard, demod_ldpc);
        decodedBitsSoftllr = step(ldpcDecoderSoft,  demod_ldpc);
        decodedBitsSoft = decodedBitsSoftllr < -0.9;

        % 7. Cálculo de erros para as 3 versões.
        num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= demod_no_code);   % Sem codificação.
        num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= decodedBitsHard); % LDPC Hard.
        num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= decodedBitsSoft); % LDPC Soft.
    end

    % 8. Calcula BER e FER
    ber(:, i) = num_bit_errors / (j * info_length);
    fer(:, i) = 1 - (1 - ber(:, i)).^frame_bits;    % Calculando o FER a partir do BER
end

% -------------------------------------------------------------------------
% Plots de desempenho.
% -------------------------------------------------------------------------

% Gráfico BER.
figure;
semilogy(Eb_N0_dB, ber(1, :), 'r-x', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'Sem LDPC'); % Linha Vermelha.
hold on;
semilogy(Eb_N0_dB, ber(2, :), 'g-o', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Hard'); % Linha Verde.
semilogy(Eb_N0_dB, ber(3, :), 'b-s', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Soft'); % Linha Azul.
xlabel('Eb/N0 (dB)');
ylabel('BER');
legend('Location', 'southwest');
grid on;
title('Desempenho do sistema BPSK com LDPC (BER)');

% Gráfico FER.
figure;
semilogy(Eb_N0_dB, fer(1, :), 'r-x', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'Sem LDPC'); % Linha Vermelha.
hold on;
semilogy(Eb_N0_dB, fer(2, :), 'g-o', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Hard'); % Linha Verde.
semilogy(Eb_N0_dB, fer(3, :), 'b-s', 'LineWidth', 2, 'MarkerSize', 10, 'DisplayName', 'LDPC Soft'); % Linha Azul.
xlabel('Eb/N0 (dB)');
ylabel('FER');
legend('Location', 'southwest');
grid on;
title('Desempenho do sistema BPSK com LDPC (FER)');

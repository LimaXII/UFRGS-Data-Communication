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

% Configura��es
num_b = 18400; % N�mero de bits por quadro (2300 bytes)
frames = 1; % N�mero de quadros simulados
Eb_N0_dB = 0:1:9; % Faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB / 10); % Eb/N0 linearizado
ber = zeros(3, length(Eb_N0_lin)); % BER para as 3 vers�es
fer = zeros(3, length(Eb_N0_lin)); % FER para as 3 vers�es
Eb = 1; % Energia por bit para BPSK
NP = Eb ./ Eb_N0_lin; % Pot�ncia do ru�do
NA = sqrt(NP); % Amplitudes do ru�do

obj = struct(); % Usando um objeto struct para armazenar dados
n = 1944;  % Tamanho do c�digo
R = 1/2;   % Taxa do c�digo
block_length = n;
info_length = block_length * R;

% Criar o objeto LDPC
ldpc = LDPCCode(block_length, info_length);

% Carregar o c�digo LDPC correspondente ao H_1944_1_2
ldpc.load_wifi_ldpc(block_length, R);

% Exibir a matriz H gerada
H = ldpc.H;
disp(size(H));

%Inicializa��o do ldpc
ldpcEncoder = comm.LDPCEncoder(H);
ldpcDecoderHard = comm.LDPCDecoder(H, 'DecisionMethod', 'Hard decision');
ldpcDecoderSoft = comm.LDPCDecoder(H, 'DecisionMethod', 'Soft decision');

% Determinar os tamanhos K e N
K = size(H, 2) - size(H, 1); % N�mero de bits de entrada
N = size(H, 2); % N�mero de bits codificados

% Simula��o
for i = 1:length(Eb_N0_lin)
    num_bit_errors = zeros(3, 1);
    num_frame_errors = zeros(3, 1);

    for frame = 1:frames
        disp(frame);
        % 1. Fonte de informa��o
        bits = randi([0 1], K, 1); % Gera bits aleat�rios

        % 2. Codifica��o de canal (LDPC)
        codedBits = step(ldpcEncoder, bits);

        % 3. Modula��o (BPSK com s�mbolos complexos)
        modulated_no_code = complex(1 - 2 * bits, 0); % Sem LDPC
        modulated_ldpc = complex(1 - 2 * codedBits, 0); % Com LDPC

        % 4. Ru�do AWGN (complexo)
        noise_no_code = NA(i) * complex(randn(size(modulated_no_code)), randn(size(modulated_no_code))) * sqrt(0.5);
        noise_ldpc = NA(i) * complex(randn(size(modulated_ldpc)), randn(size(modulated_ldpc))) * sqrt(0.5);

        received_no_code = modulated_no_code + noise_no_code;
        received_ldpc = modulated_ldpc + noise_ldpc;

        % 5. Demodula��o
        demod_no_code = real(received_no_code);
        demod_ldpc = real(received_ldpc);

        % 6. Decodifica��o de canal
        decodedBitsHard = step(ldpcDecoderHard, demod_ldpc);
        decodedBitsSoft = step(ldpcDecoderSoft, demod_ldpc);

        % 7. C�lculo de erros para as 3 vers�es
        num_bit_errors(1) = num_bit_errors(1) + sum(bits ~= (demod_no_code < 0)); % Sem LDPC
        num_bit_errors(2) = num_bit_errors(2) + sum(bits ~= decodedBitsHard); % LDPC Hard
        num_bit_errors(3) = num_bit_errors(3) + sum(bits ~= decodedBitsSoft); % LDPC Soft

        num_frame_errors(1) = num_frame_errors(1) + any(bits ~= (demod_no_code < 0)); % Sem LDPC
        num_frame_errors(2) = num_frame_errors(2) + any(bits ~= decodedBitsHard); % LDPC Hard
        num_frame_errors(3) = num_frame_errors(3) + any(bits ~= decodedBitsSoft); % LDPC Soft
        
    end

    % 8. Calcula BER e FER
    ber(:, i) = num_bit_errors / (frames * K);
    fer(:, i) = num_frame_errors / frames;
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


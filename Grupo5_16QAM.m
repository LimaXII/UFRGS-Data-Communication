% Trabalho Final - Grupo 5
%
% Especificaï¿½ï¿½es:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema ï¿½completoï¿½ de comunicaï¿½ï¿½o de dados, contendo, no mï¿½nimo, 
%  os seguintes componentes: (1) Fonte de informaï¿½ï¿½o, 
%  (2) Codificador de canal, (3) Modulaï¿½ï¿½o, (4) Ruï¿½do,
%  (5) Demodulaï¿½ï¿½o, (6) Decodificador de canal, (7) Receptor de informaï¿½ï¿½o  
%
% Objetivo:
%  1) Avaliar um sistema completo em termos de bit error rate (BER) e 
%  frame error rate (FER) variando parï¿½metros do sistema
%  2) Avaliaï¿½ï¿½o para um intervalo de Eb/N0
%  3) Analisar a eficiï¿½ncia de cï¿½digos e modulaï¿½ï¿½es
%  utilizadas no padrï¿½o IEEE 802.11
%
% Luccas da Silva Lima - 00324683 
% Matheus Almeida Silva - 00316326
% Thiago Leonel Rancan Bischoff - 00324856
% -------------------------------------------------------------------------

clear;
close;
num_b = 1000000; %número de bits a serem simulados
bits = complex(2*randi(2, 1, num_b)-3, 0); %bits aleatórios modulados em BPSK (parte real em 1 e -1)
Eb_N0_dB = 0:1:9; %faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); %faixa de Eb/N0 linearizada
ber = zeros(size(Eb_N0_lin)); %pré-alocação do vetor de BER
Eb = 1; % energia por bit para a modulação BPSK utilizada

NP = Eb ./ (Eb_N0_lin); %vetor de potências do ruído
NA = sqrt(NP); %vetor de amplitudes do ruído
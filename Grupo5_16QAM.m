% Trabalho Final - Grupo 5
%
% Especifica��es:
%   5 BPSK, 16-QAM LDPC n = 1944, R = {1/2}
%
% Proposta:
%  Modelar sistema �completo� de comunica��o de dados, contendo, no m�nimo, 
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
num_b = 1000000; %n�mero de bits a serem simulados
bits = complex(2*randi(2, 1, num_b)-3, 0); %bits aleat�rios modulados em BPSK (parte real em 1 e -1)
Eb_N0_dB = 0:1:9; %faixa de Eb/N0
Eb_N0_lin = 10 .^ (Eb_N0_dB/10); %faixa de Eb/N0 linearizada
ber = zeros(size(Eb_N0_lin)); %pr�-aloca��o do vetor de BER
Eb = 1; % energia por bit para a modula��o BPSK utilizada

NP = Eb ./ (Eb_N0_lin); %vetor de pot�ncias do ru�do
NA = sqrt(NP); %vetor de amplitudes do ru�do
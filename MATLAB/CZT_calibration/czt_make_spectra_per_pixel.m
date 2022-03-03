% function make spectra for each pixel from data stream
function [channel_spectra, keV_spectra, pixel_energy] = czt_make_spectra_per_pixel(address, channel, pulse_height)
% prepare vars and structs for spectra
% input: asic address, asic channel (pixel address), pulse heigh
% output: 16384x1024 arrays with pixel level spectra
    load('calm.mat','calm2019');
calm = calm2019;
n_pixels = 128*128;
n_EnergyBins = 1024;
n_keVBins = 1000;
index = uint32(0);
AOC = true;
% make spectra for each individual pixel
% spectra can be used for more detail noise spectral analysis if needed
channel_spectra = zeros(n_pixels, n_EnergyBins);
keV_spectra = zeros(n_pixels, n_keVBins);
    for i  =  1:numel(address)
            % Calculate pixel number (between 1 and 16384)
            index = uint16(address(i)) * 128 + uint16(channel(i)) + 1;
            % correct if pixel has >128 adress within asic
%             if czt_data(i,4) > 128, PixChannel = PixChannel - 128; end
            % Sort the data per channel, per energy bin
            if index > 0 && index <= n_pixels && pulse_height(i) >= 0 && pulse_height(i) <= n_EnergyBins
                % accumulate channel spectrum
                channel_spectra(index, pulse_height(i) + 1) = ...
                channel_spectra(index, pulse_height(i) + 1) + 1;
            
        % calibrate
        if AOC
           pixel_pre_en(i) = pulse_height(i);
        else
           pixel_pre_en(i) = calm(index,1) + pulse_height(i);
        end
        % pre-calibration
            pixel_pre_en(i) = calm(index,2) * pixel_pre_en(i)^2 + calm(index,3) * pixel_pre_en(i) + calm(index,4);
        % final calibration   
            pixel_energy(i) = calm(index,5) * exp(calm(index,6) * pixel_pre_en(i)) + ...
                            calm(index,7) * exp(calm(index,8) * pixel_pre_en(i)) + calm(index,9);
                        
                % accumulate keV spectrum
                if round(pixel_energy(i)) > 0 && pixel_energy(i) <= n_keVBins
                    keV_spectra(index, round(pixel_energy(i))) = keV_spectra(index, round(pixel_energy(i))) + 1;
                else
                    disp('Pixel outside energy range')
                end
                
            else
                disp(['Ignored: pixel #',num2str(index),', pulse height: ',num2str(pulse_height(i))] );
            end
    end
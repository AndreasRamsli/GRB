T0_ASIM = 2020-12-27 15:14:06.853667
T0_KW = 2020-12-27 15:14:06.705

ToF = 0.7142 s. (Assuming the radiation reaches KW first if value is positive)


Cross Correlation
-----------------
ASIM LC shifted by -0.4 s before cross correlation with KW LC with 2 ms bins.

The Cross Correlation software (Stingray, Huppenkothen et al., 2019. Astrophysical Journal, 881, 39) estimates a time lagg of -0.131 s which should be applied to ASIM LC to produce the highest correlation. Resulting in a total time lagg of -0.531 s which should be applied to ASIM LC.
  
	General notes on the CC:
		1) Using KW G3 counts for building LC. Assuming energy interval = 360-1360 keV
		2) Filtering ASIM LC to be in the same energy range.
		3) Background estimation for LC's provided in the folder:
			-For original LC bkg is estimated on the interval (-0.42,0.4),
			 Bkg = ~2.51 counts per 2ms bin 
			
			-For LC shifted by tlaggApprox=-0.4 s bkg estimated on interval (-0.82,0)
			Bkg = ~2.51 counts per 2ms bin
			
			-Using ~2.51 as background for the asimLC_tshift_-0.531s LC

Notes on the attached LC's
--------------------------
ALL LC's are in the energy range specified above

[1] asimLC_original.txt is the LC built from the original unshifted photon arrival list
[2] asimLC_original_bkg_removed.txt is the same LC but with background subtracted
[3] asimLC_tshiftApprox_-0.4s.txt is the same LC as [1], but shifted -0.4 s
[4] asimLC_tshiftApprox_-0.4s_bkg_removed.txt is the same as [3], but with bkg removed
[5] asimLC_tshift_-0.531s.txt is the same LC as [1], but shifted -0.531 s
[6] asimLC asimLC_tshift_-0.531s_bkg_removed.txt is the same as [5], but with bkg removed


START & STOP TIMES
------------------
For the fits files i provided earlier in a email, the ASIM pha file is generated on the interval (0.00 s, 0.064 s) and the bak file is generated on the interval (-0.9 s,-0.3 s)




Notes regaring data extracted from FERMI GBM for GRB210619B 

>>Location
grb_ra, grb_dec = 319.7125, 33.8667 


TODO: Do a Cross correlation of Fermi/ASIM to find the proper tshift



>>Trigtime GBM
T0_GBM = 2021-06-19 23:59:25.604186

>>Trig time ASIM
T0_ASIM = 2021-06-19T23:59:25.915550

>> ToF (seconds)

ToF_Fermi_ASIM = 0.0227
ToF_KW_ASIM = -2.6183 


>>calculated tlagg from Cross Correlation: ~ 0.646 s
See attached plots



>> Angular separation from the GRB position

Detector Degrees 
n8      25.951
n4      50.99
n7      68.489
nb      71.936
b1      75.565
n3      83.873
n6      90.944
b0      104.435
n5      107.66
n9      124.021
n0      126.454
na      128.196
n1      144.321
n2      155.105


>> Energy range for data extraction
NaI: 8-1000 keV
BGO: 150 keV - 40MeV

>>Background estimated from T0-130 to T0-5 s for all detectors

>>Spectra retrived from 6 different time intervals (seconds):
Interval1 = (0, 1)
Interval2 = (1, 1.7)
Interval3 = (1.7, 2.18)
Interval4 = (2.18, 2.79)
Interval5 = (2.79, 3.6)
Interval6 = (3.6, 4.5)

>>Grouping in xspec
used grppha to group the channels by grou min 20




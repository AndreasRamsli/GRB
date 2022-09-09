Notes regaring data extracted from FERMI GBM for GRB210619B 

>>Location
grb_ra, grb_dec = 319.7125, 33.8667 


TODO: Do a Cross correlation of Fermi/ASIM to find the proper tshift



>>Trigtime GBM
T0_GBM = 2021-06-19 23:59:25.604186
t0METgbm: <Met seconds = 645839970.604186>

>>Trigtime KW
T0_KW = 2021-06-19T23:59:28.157

>>Trig time ASIM
T0_ASIM = 2021-06-19T23:59:25.915550
t0METASIM:  <Met seconds = 645839970.915550>

>> ToF (seconds)

ToF_Fermi_ASIM = 0.0227
ToF_KW_ASIM = -2.6183 


t0MET = t0METASIM.add(ToF_Fermi_ASIM)
tshift = t0MET - t0METgbm

>>calculated t_shift ~ 0.334064



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


>> Energy range
NaI: 8-1000 keV
BGO: 150 keV - 40MeV

>>Background estimated from T0-130 to T0-5 s 

>>Spectra retrived from T0+1 to T0+1.7 s
src time does capture the max count rate of the burst

>>Grouping in xspec
used grppha to group the channels by grou min 20




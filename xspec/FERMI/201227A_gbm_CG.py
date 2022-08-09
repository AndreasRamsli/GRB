import numpy as np
import matplotlib.pyplot as plt
import os, re, sys
from astropy.io import fits, ascii
from astropy.time import Time

from gbm.data import TTE
from gbm.binning.unbinned import bin_by_time
from gbm.plot import Lightcurve, Spectrum
from gbm.background import BackgroundFitter
from gbm.background.binned import Polynomial
from gbm.data import RSP

# Give the following if you work with ipython rather than jupyter (otherwise: %matplotlib inline)
%matplotlib qt5

bn='bn201227635'
data_dir = '/home/guidorzi/ASIM/Fermi_GBM/GRB201227A/'
unit='all'


###### Find temporal offset between GBM trigger time and others

########## Find the angle of the GRB wrt the GBM units
from gbm.data import Trigdat
fn_trigdat = data_dir+'glg_trigdat_'+unit+'_'+bn+'_v01.fit'
trigdat = Trigdat.open(fn_trigdat)
print(trigdat)
print(trigdat.trigtime)

# Once extracted, it has the full capabilities of the [```Ctime```](./PhaiiData.ipynb) class.  You can also retrieve the sum of the detectors:
# the triggered detectors
trig_dets = trigdat.triggered_detectors
print(trig_dets)

grb_ra, grb_dec = 0.52857, -2.91893

all_dets=
np.array(['n0','n1','n2','n3','n4','n5','n6','n7','n8','n9','na','nb','b0','b1'])
point_dets = np.zeros(shape=(all_dets.size,2))
for i in range(all_dets.size):
   point_dets[i,:] = trigdat.detector_pointing(all_dets[i], trigdat.trigtime)

# Calculate the angular separation for all detectors
from astropy.coordinates.angle_utilities import angular_separation
ang_sep = np.zeros(all_dets.size)
for i in range(all_dets.size):
   ang_sep[i] = np.rad2deg(angular_separation(np.deg2rad(point_dets[i,0]),np.deg2rad(point_dets[i,1]),np.deg2rad(grb_ra),np.deg2rad(grb_dec)))

# Print dets with increasing angular separation from the GRB position
idx_sort_angsep = np.argsort(ang_sep)
print(all_dets[idx_sort_angsep])
print(ang_sep[idx_sort_angsep])
# Best illuminated units: n7, n6


###### Find temporal offset between GBM trigger time and others
from gbm.time import Met
import datetime

# Convert from MET to UTC
t0METgbm = Met(trigdat.trigtime)
print(t0METgbm)
t0METgbm.datetime

ToF_Fermi_ASIM = -0.0008
ToF_KW_ASIM = 0.7142
str_t0KW = '2020-12-27T15:14:06.705'
t0METKW = t0METgbm.from_iso(str_t0KW)
t0MET = t0METKW.add(ToF_KW_ASIM+ToF_Fermi_ASIM)  # To add seconds
tshift = t0MET - t0METgbm

########### Extract data from selected unit(s)+ ##################
#unit = all_dets[idx_sort_angsep][0]
unit = trig_dets[0]

# Read TTE of selected unit
fn_tte = data_dir+'glg_tte_'+unit+'_'+bn+'_v00.fit'

# Filename of RSP for the selected unit
fn_rsp = data_dir+'glg_cspec_'+unit+'_'+bn+'_v03.rsp2'

# open a TTE file
tte = TTE.open(fn_tte)
# bin to 2.048 s resolution, reference time is trigger time (coarse resolution to accurately model the bkg)
bint = 0.004
#phaii = tte.to_phaii(bin_by_time, bint, time_ref=0.0)
phaii = tte.to_phaii(bin_by_time, bint, time_ref=tshift)

erange = (8.0, 900.0)
lc_data = phaii.to_lightcurve(energy_range=erange)
lcplot = Lightcurve(data=lc_data)
lcplot.xlim = (-2,2)

# Fit background
bkgd_times = [(-5.0, -1.0), (1.0, 5.0)]
backfitter = BackgroundFitter.from_phaii(phaii, Polynomial, time_ranges=bkgd_times)
backfitter.fit(order=1)

bkgd = backfitter.interpolate_bins(phaii.data.tstart, phaii.data.tstop)
#type(bkgd)
lc_bkgd = bkgd.integrate_energy(*erange)
lcplot = Lightcurve(data=lc_data, background=lc_bkgd)
# zoom in to 5 seconds before to 20 s after the trigger time
view_range = (-1.0, 1.0)
lcplot.xlim = view_range

# Ok, the fit is done, but how do we know if it is a good fit?  You can return the fit statistic and degrees-of-freedom (DoF) for each energy channel fit, and try to figure out if it's a good fit based on that (Note: not always the best way to go).
backfitter.statistic/backfitter.dof

# Define normalised residuals and test their compatibility with a standardized normal distribution
isel = np.where( ((lc_data.centroids>bkgd_times[0][0]) & (lc_data.centroids<bkgd_times[0][1])) | ((lc_data.centroids>bkgd_times[1][0]) & (lc_data.centroids<bkgd_times[1][1])) )[0]
isel_bkg = np.where( ((lc_bkgd.time_centroids>bkgd_times[0][0]) & (lc_bkgd.time_centroids<bkgd_times[0][1])) | ((lc_bkgd.time_centroids>bkgd_times[1][0]) & (lc_bkgd.time_centroids<bkgd_times[1][1])) )[0]

if np.all(isel == isel_bkg):
   norm_res = (lc_data.counts[isel]-lc_bkgd.counts[isel_bkg])/np.sqrt(lc_bkgd.counts[isel_bkg])
   print("Normalised residuals: mean= {:.3g}  std= {:.3g}".format(norm_res.mean(),norm_res.std()))
   # QQ plot to test normality
   import pylab 
   import scipy.stats as stats
   plt.cla()
   stats.probplot(norm_res, dist="norm",plot=pylab)
   from scipy.stats import normaltest
   normaltest(norm_res)


# Now, we need to define a time interval of interest.  It could be a single bin, or it could be multiple bins.  Let's select the brightest two bins in this view.
# our lightcurve source selection
src_time = (-0.01, 0.06)
src_lc = phaii.to_lightcurve(time_range=src_time, energy_range=erange)

lcplot = Lightcurve(data=lc_data, background=lc_bkgd)
#lcplot.add_selection(src_lc)
lcplot.xlim = view_range

# The orange shading indicates the time bins you've selected as source signal.  You can also make a plot of the count spectrum during the selection  to see what the background model looks like in comparison to the data:
# the observed count spectrum during the source selection
spec_data = tte.to_spectrum(time_range=src_time)
#spec_data = phaii.to_spectrum(time_range=src_time)
# the background model integrated over the source selection time
spec_bkgd = bkgd.integrate_time(*src_time)
# and the energy range selection that was made
#spec_selection = phaii.to_spectrum(time_range=src_time, energy_range=erange)
specplot = Spectrum(data=spec_data, background=spec_bkgd)
#specplot.add_selection(spec_selection)

# Extract the corresponding PHA from source and bkg files
pha = tte.to_pha(time_ranges=src_time)
# the background spectrum
bak = bkgd.to_bak(time_range=src_time)

# So now you have a PHA and BAK object which can be written as fully-formed FITS files using the `.write()` methods:
# ```python
fn_spectral = 'GRB201227A_'+unit
bak.write('./', filename=fn_spectral+'.bak')
pha.write('./', filename=fn_spectral+'.pha', backfile=fn_spectral+'.bak')

# Read RSP function
rsp = RSP.open(fn_rsp)
# and interpolate response files to get DRMs at center of the source window
rsp_interp = rsp.interpolate(pha.tcent)

# Write response file
rsp_interp.write('./', filename=fn_spectral+'.rsp')

# It's advisable to set the RESPFILE keyword properly in the PHA file:
# fparkey GRB201227A_n7.rsp GRB201227A_n7.pha+2 RESPFILE



# Time intervals for spectra
# Add time shift due to GBM vs. KW reference times
fn_spec_times = '/home/guidorzi/ASIM/KW_LCs/GRB201227A_sp.txt'
spec_times = np.loadtxt(fn_spec_times, unpack=True) + tshift

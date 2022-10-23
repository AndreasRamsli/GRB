import sys
import numpy as np
from astropy.io import fits

def fits_dump(file_name):

    hdul = fits.open(file_name, uint=False)

    str_out = f'FITS file: {file_name}\n'
     
    for hdu in hdul:
        
        str_out += f'{hdu.name}\n'
        str_out += '-----------------\n'

        hdr_keys = hdu.header.keys()
        for s in hdr_keys:
            str_out += f'{s}, {hdu.header[s]}\n'

        str_out +='-----------------\n'
        str_out += f'{hdu.data}\n\n'

    with open('_'.join(file_name.split('.')) + '.txt', 'w') as f:
        f.write(str_out)

def print_array(a):

    for i in range(len(a)):
        print(a[i], type(a[i]))

def make_int_array(a):

    b = np.zeros(len(a), dtype=np.int32)
    for i in range(len(a)):
        b[i] = int(a[i])

    return b

def fix_asim(file_name):

   file_name_out = '{:s}_fixed.pha'.format(file_name.split('.')[0])

   hdul = fits.open(file_name, mode='update', lazy_load_hdus=False)

   data = hdul[1].data.copy()
   header = hdul[1].header

   del hdul[1]
   #print(data['COUNTS'].astype('uint16'))

   a = np.array(data['COUNTS'])
   #print_array(a)
   arr_counts = make_int_array(a)
   #print_array(arr_counts)

   arr_channel = data['CHANNEL']
   arr_cnt_err = data['STAT_ERR']
   arr_qual = data['QUALITY']
   arr_grp = data['GROUPING']

   col_channel = fits.Column(name='CHANNEL', array=arr_channel, format='I')
   col_counts = fits.Column(name='COUNTS', array=arr_counts, format='J')
   col_cnt_err = fits.Column(name='STAT_ERR', array=arr_cnt_err, format='E')
   col_qual =  fits.Column(name='QUALITY', array=arr_qual, format='I')
   col_grp = fits.Column(name='GROUPING', array=arr_grp, format='I')
   table_hdu = fits.BinTableHDU.from_columns([col_channel, col_counts, col_cnt_err, col_qual, col_grp])
   table_hdu.name = 'SPECTRUM'

   keys_old = header.keys()

   for key in keys_old:

       if table_hdu.header.get(key, None) is not None or key == 'TZERO2' or key == 'TSCAL2':
           continue

       if key != 'COMMENT' and key != 'HISTORY':

           table_hdu.header[key] = header[key]
           table_hdu.header.comments[key] = header.comments[key]

       elif key == 'COMMENT':
           lst_comments = header[key]
           for s in lst_comments:
               table_hdu.header.add_comment(s)

       elif key == 'HISTORY':
           lst_history = header[key]
           for s in lst_history:
               table_hdu.header.add_history(s)
   
   table_hdu.header.add_history('TZERO2 and TSCAL2 were removed.')
   table_hdu.header.add_history('COUNTS column was converted to 32 bit integer')
   table_hdu.header.add_history('similar to GBM spectra produced by the GBM tools')

   hdul.insert(1, table_hdu)

   #print(data['COUNTS'])

   hdul.writeto(file_name_out, overwrite=True)

def main():


    file_name = 'HED_PHA_1.fits'
    #fits_dump(file_name)

    fix_asim(file_name)
    

if __name__ == "__main__":
    main()
    